import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import '../../domain/entities/cours_entity.dart';
import 'teacher_evaluation_page.dart';

class StudentResultsPage extends ConsumerStatefulWidget {
  const StudentResultsPage({super.key});

  @override
  ConsumerState<StudentResultsPage> createState() => _StudentResultsPageState();
}

class _StudentResultsPageState extends ConsumerState<StudentResultsPage> {
  String? _selectedYearOverride;
  String _selectedSemester = 'ALL';

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final currentYearAsync = ref.watch(currentAcademicYearProvider);
    final deptsAsync = ref.watch(departmentsProvider);
    final promosAsync = ref.watch(promotionsProvider);

    return userDataAsync.when(
      data: (user) {
        if (user == null || user is! EtudiantEntity) return const Scaffold(body: Center(child: Text("Accès refusé.")));

        return deptsAsync.when(
          data: (depts) => promosAsync.when(
            data: (promos) {
              // 1. Vérification réactive de l'accès
              final promo = promos.where((p) => p.stableId == user.idPromo).firstOrNull;
              final dept = depts.where((d) => d.id == promo?.idDept).firstOrNull;

              if (dept == null) return _buildStatusScreen("Configuration académique introuvable.", isError: true);
              if (!dept.resultatsOuverts) return _buildStatusScreen("La consultation des résultats n'est pas encore activée pour votre département.", isError: false);

              // 2. Vérification financière
              final double threshold = promo?.seuilFinance ?? 0;
              return ref.watch(getStudentPaymentsProvider(user.id)).when(
                data: (payments) {
                  double totalPaid = 0;
                  for (var p in payments) totalPaid += (p['montant_paye'] ?? 0);

                  if (threshold > 0 && totalPaid < threshold) {
                    return _buildStatusScreen("Accès bloqué. Pour votre promotion, le seuil de paiement minimum est de $threshold \$. (Votre total actuel : $totalPaid \$)", isError: false, isLocked: true);
                  }

                  // 3. Vérification des évaluations si activé
                  if (dept.evalProfsOuverte) {
                    return ref.watch(studentEvaluationsProvider(user.id)).when(
                      data: (evals) {
                        // On récupère les cours de la promo actuelle
                        return ref.watch(getStudentCoursesProvider((promoId: user.idPromo, anneeAcad: null))).when(
                          data: (courses) {
                            final evaluatedCourseIds = evals.map((e) => e['id_cours']?.toString()).toSet();
                            final missingEvaluations = courses.where((c) => !evaluatedCourseIds.contains(c.idCours.toString())).toList();

                            if (missingEvaluations.isNotEmpty) {
                              return _buildEvaluationRequiredScreen(missingEvaluations);
                            }
                            
                            return _buildResultsContent(user, currentYearAsync);
                          },
                          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                          error: (e, _) => Scaffold(body: Center(child: Text("Erreur cours : $e"))),
                        );
                      },
                      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                      error: (e, _) => Scaffold(body: Center(child: Text("Erreur évaluations : $e"))),
                    );
                  }

                  // 4. Affichage des résultats
                  return _buildResultsContent(user, currentYearAsync);
                },
                loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                error: (e, _) => Scaffold(body: Center(child: Text("Erreur financière : $e"))),
              );
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, _) => Scaffold(body: Center(child: Text("Erreur promo : $e"))),
          ),
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text("Erreur département : $e"))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Erreur utilisateur : $e"))),
    );
  }

  Widget _buildResultsContent(EtudiantEntity user, AsyncValue<String> currentYearAsync) {
    final resultsAsync = ref.watch(getStudentResultsProvider(user.id));
    final promosAsync = ref.watch(promotionsProvider);
    final currentYear = currentYearAsync.value ?? '';

    return resultsAsync.when(
      data: (notes) {
        // Détecter toutes les années et promotions associées
        final Map<String, String> yearToPromoId = {};
        final Set<String> yearsSet = {currentYear};
        
        // 1. Depuis l'historique d'inscriptions de l'étudiant
        for (var h in user.historiqueInscriptions) {
          final y = h['annee_academique']?.toString();
          final pId = h['id_promo']?.toString();
          if (y != null && y.isNotEmpty && pId != null && pId.isNotEmpty) {
            yearsSet.add(y);
            yearToPromoId[y] = pId;
          }
        }

        // 2. Depuis les notes enregistrées
        for (var n in notes) {
          final y = n['annee_academique']?.toString();
          final pId = n['id_promo']?.toString();
          if (y != null && y.isNotEmpty) {
            yearsSet.add(y);
            if (!yearToPromoId.containsKey(y) && pId != null && pId.isNotEmpty) {
              yearToPromoId[y] = pId;
            }
          }
        }

        if (!yearToPromoId.containsKey(currentYear)) {
          yearToPromoId[currentYear] = user.idPromo;
        }
        
        final List<String> sortedYears = yearsSet.toList()..sort((a, b) => b.compareTo(a));
        
        // Logique de bascule automatique si la session actuelle est vide
        String initialYear = currentYear;
        if (_selectedYearOverride == null) {
          final currentYearNotes = notes.where((n) => n['annee_academique'] == currentYear).toList();
          if (currentYearNotes.isEmpty && sortedYears.length > 1) {
            // On prend l'année la plus récente qui a des notes
            initialYear = sortedYears.firstWhere((y) => y != currentYear, orElse: () => currentYear);
          }
        }
        
        final activeYear = _selectedYearOverride ?? initialYear;
        final activePromoId = yearToPromoId[activeYear] ?? user.idPromo;

        // Filtrer les notes pour l'année active
        final activeNotes = notes.where((n) => n['annee_academique'] == activeYear).toList();

        // Charger les cours de cette promo pour cette année
        final coursesAsync = ref.watch(getStudentCoursesProvider((promoId: activePromoId, anneeAcad: activeYear)));

        return promosAsync.when(
          data: (allPromos) {
            final promoMap = { for (var p in allPromos) p.stableId : p.nomPromo };
            
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Column(
                  children: [
                    Text('RÉSULTATS SEMESTRIELS', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    Text('$activeYear • ${promoMap[activePromoId] ?? "Promotion"}', 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ],
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                actions: [
                  if (sortedYears.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: TextButton.icon(
                        onPressed: () => _showYearPicker(context, sortedYears, activeYear, promoMap, yearToPromoId, user.idPromo),
                        icon: const Icon(Icons.history_rounded, size: 18, color: AppColors.accentYellow),
                        label: const Text('HISTORIQUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.primaryBlue)),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                ],
              ),
              body: coursesAsync.when(
                data: (courses) {
                  List<CoursEntity> displayCourses = courses;
                  if (_selectedSemester == 'S1') {
                    displayCourses = courses.where((c) => c.semestre == 'S1' || c.semestre == '1').toList();
                  } else if (_selectedSemester == 'S2') {
                    displayCourses = courses.where((c) => c.semestre == 'S2' || c.semestre == '2').toList();
                  }

                  double sommePonderee = 0;
                  int totalCreditsInscrits = 0;
                  int totalCreditsSaisis = 0;
                  
                  final List<Map<String, dynamic>> finalData = [];
                  
                  for (var course in displayCourses) {
                    final note = activeNotes.where((n) {
                      final noteCourseId = n['id_cours']?.toString();
                      return noteCourseId == course.id || noteCourseId == course.idCours.toString();
                    }).firstOrNull;
                    
                    if (note != null) {
                      final double cote = (note['cote'] ?? 0.0).toDouble();
                      sommePonderee += (cote * course.credits);
                      totalCreditsSaisis += course.credits;
                      finalData.add({
                        'code': course.codeCours,
                        'intitule': course.intituleCours,
                        'credits': course.credits,
                        'cote': cote,
                        'ponderation': cote * course.credits,
                        'obs': cote >= 10 ? 'ADM' : 'COMP',
                      });
                    }
                    totalCreditsInscrits += course.credits;
                  }

                  double moyenne = totalCreditsSaisis > 0 ? (sommePonderee / totalCreditsSaisis) : 0;
                  double pourcentage = totalCreditsSaisis > 0 ? (sommePonderee / (totalCreditsSaisis * 20)) * 100 : 0;
                  
                  bool isSessionComplete = totalCreditsInscrits > 0 && totalCreditsSaisis >= (totalCreditsInscrits * 0.8);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 20,
                              runSpacing: 15,
                              children: [
                                _buildHeader(activeYear, isSessionComplete),
                                _buildSemesterSegmentSelector(),
                              ],
                            ),
                            const SizedBox(height: 30),
                            if (finalData.isEmpty) 
                              _buildEmptyResultsState(activeYear)
                            else ...[
                              _buildResultsTable(finalData, sommePonderee, totalCreditsSaisis, moyenne, pourcentage),
                              const SizedBox(height: 45),
                              if (isSessionComplete) 
                                _buildDecisionBox(pourcentage, _selectedSemester)
                              else
                                _buildPartialInfoBox(),
                              const SizedBox(height: 60),
                              _buildResultsExtensions(context, pourcentage, isSessionComplete),
                            ],
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Erreur cours: $e")),
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text("Erreur promotions: $e"))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Erreur notes: $e"))),
    );
  }

  void _showYearPicker(BuildContext context, List<String> years, String activeYear, Map<String, String> promoMap, Map<String, String> yearToPromoId, String currentPromoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 5, 
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 25),
            const Text(
              'HISTORIQUE ACADÉMIQUE',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: years.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final y = years[index];
                  final bool isSelected = y == activeYear;
                  final promoId = yearToPromoId[y] ?? currentPromoId;
                  final promoName = promoMap[promoId] ?? "Promotion";

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedYearOverride = y);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isSelected ? AppColors.primaryBlue.withOpacity(0.2) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.calendar_today_rounded,
                            color: isSelected ? AppColors.primaryBlue : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  y,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                    color: isSelected ? AppColors.primaryBlue : const Color(0xFF0F172A),
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  promoName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primaryBlue.withOpacity(0.7) : Colors.grey,
                                    letterSpacing: 0.5
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.stars_rounded, color: AppColors.accentYellow, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationRequiredScreen(List<CoursEntity> missingCourses) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('ÉVALUATIONS OBLIGATOIRES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 30),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ACCÈS RESTREINT", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF92400E))),
                        const SizedBox(height: 5),
                        Text(
                          "Vous devez évaluer tous vos cours de la promotion actuelle avant de consulter vos résultats.",
                          style: TextStyle(color: Colors.amber.shade900, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("COURS À ÉVALUER :", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, color: Colors.grey)),
            ),
            const SizedBox(height: 15),
            ...missingCourses.map((c) => _buildMissingEvalCard(c)).toList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingEvalCard(CoursEntity course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.intituleCours, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.deepNavy)),
                Text(course.codeCours, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => TeacherEvaluationPage(
                    course: course, 
                    teacherName: "Enseignant du cours",
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            child: const Text("ÉVALUER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusScreen(String message, {bool isError = false, bool isLocked = false}) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30)]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocked ? Icons.lock_person_rounded : (isError ? Icons.error_outline_rounded : Icons.info_outline_rounded), 
                size: 100, 
                color: isLocked || isError ? const Color(0xFFDC2626) : AppColors.primaryBlue
              ),
              const SizedBox(height: 30),
              Text(
                isLocked ? 'ACCÈS BLOQUÉ' : (isError ? 'ERREUR' : 'INFORMATION'), 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))
              ),
              const SizedBox(height: 20),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => setState(() {}),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('ACTUALISER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultsState(String currentYear) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_empty_rounded, size: 80, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 30),
            Text('Session $currentYear', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 10),
            const Text('RÉSULTATS EN ATTENTE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
            const SizedBox(height: 15),
            const Text(
              'Vos notes sont en cours de traitement pour cette promotion.\nRevenez bientôt pour consulter votre relevé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.6, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String annee, bool isComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'RÉSULTAT SEMESTRIEL $annee',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A), letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isComplete ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            isComplete ? 'SESSION CLÔTURÉE' : 'SESSION EN COURS DE SAISIE',
            style: TextStyle(color: isComplete ? Colors.green : Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsTable(List<Map<String, dynamic>> data, double totalCotes, int totalCredits, double moyenne, double pourcentage) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE))
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF4A5666)),
            headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            horizontalMargin: 15,
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Code UE')),
              DataColumn(label: Text('Intitulé de l\'EC')),
              DataColumn(label: Text('Crédit')),
              DataColumn(label: Text('Cote/20')),
              DataColumn(label: Text('Cote Pondérée')),
              DataColumn(label: Text('Obs.')),
            ],
            rows: [
              ...data.map((d) => DataRow(cells: [
                DataCell(Text(d['code'], style: const TextStyle(fontSize: 12))),
                DataCell(Text(d['intitule'], style: const TextStyle(fontSize: 12))),
                DataCell(Text(d['credits'].toString())),
                DataCell(Text(d['cote'].toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(d['ponderation'].toStringAsFixed(1))),
                DataCell(Text(d['obs'], style: TextStyle(color: d['obs'] == 'ADM' ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 11))),
              ])).toList(),
              DataRow(
                color: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
                cells: [
                  DataCell(Text('TOTAL : ${totalCotes.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  const DataCell(SizedBox.shrink()),
                  DataCell(Text('CRÉDITS : $totalCredits', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  const DataCell(SizedBox.shrink()),
                  DataCell(Text('MOYENNE : ${moyenne.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataCell(Text('${pourcentage.toStringAsFixed(1)} %', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 11))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterSegmentSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentItem('Semestre 1', 'S1'),
          _segmentItem('Semestre 2', 'S2'),
          _segmentItem('Bilan Annuel', 'ALL'),
        ],
      ),
    );
  }

  Widget _segmentItem(String label, String value) {
    final bool isSelected = _selectedSemester == value;
    return InkWell(
      onTap: () => setState(() => _selectedSemester = value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionBox(double p, String selectedSemester) {
    String title = "BILAN ANNUEL CONSOLIDÉ";
    String mention = "Ajourné";
    if (p >= 80) mention = "Grande Distinction";
    else if (p >= 70) mention = "Distinction";
    else if (p >= 60) mention = "Satisfaction";
    else if (p >= 50) mention = "Passable";

    if (selectedSemester == 'S1') {
      title = "DÉCISION SEMESTRE 1";
    } else if (selectedSemester == 'S2') {
      title = "DÉCISION SEMESTRE 2";
    }

    final bool isAdmis = p >= 50;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isAdmis ? Colors.blue.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAdmis ? Colors.blue.shade200 : Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: isAdmis ? Colors.blue.shade900 : Colors.red.shade900)),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Décision du jury : ${isAdmis ? (selectedSemester == 'ALL' ? "ADM (Admis en promotion supérieure)" : "SEMESTRE VALIDÉ") : "ÉCHEC (Ajourné)"}',
              style: TextStyle(fontWeight: FontWeight.w900, color: isAdmis ? Colors.blue.shade800 : Colors.red.shade800, fontSize: 18),
            ),
          ),
          const SizedBox(height: 8),
          Text('Mention / Statut : $mention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isAdmis ? Colors.blue.shade800 : Colors.red.shade800)),
        ],
      ),
    );
  }

  Widget _buildPartialInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.shade200)),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.amber),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "Le calcul de la mention globale sera disponible une fois la session clôturée.",
              style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsExtensions(BuildContext context, double p, bool isComplete) {
    return Column(
      children: [
        PremiumFadeIn(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: AppColors.deepGradient,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [BoxShadow(color: AppColors.deepNavy.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: Column(
              children: [
                const Text(
                  'PRÉDICTION DE RÉUSSITE ANNUELLE',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 3, color: AppColors.accentYellow),
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: p / 100,
                        strokeWidth: 15,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(p >= 50 ? const Color(0xFF10B981) : Colors.redAccent),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${p.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Playfair Display'),
                        ),
                        Text(
                          !isComplete ? 'MOYENNE PARTIELLE' : (p >= 50 ? 'MOYENNE FINALE' : 'SOUS LE SEUIL'), 
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.5), letterSpacing: 1)
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.accentYellow, size: 28),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          p >= 50 
                            ? 'Continuez ainsi pour viser la ${p >= 70 ? "Grande Distinction" : "Distinction"} !'
                            : 'Courage, redoublez d\'efforts pour valider le semestre !',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        PremiumFadeIn(
          delay: const Duration(milliseconds: 400),
          child: SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.history_edu_rounded, color: AppColors.deepNavy),
              label: const Text('DEMANDER UN RELEVÉ OFFICIEL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumGold,
                foregroundColor: AppColors.deepNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                shadowColor: AppColors.premiumGold.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
