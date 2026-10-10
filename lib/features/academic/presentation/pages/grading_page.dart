import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import '../providers/academic_providers.dart';
import '../../domain/entities/cours_entity.dart';
import '../../../auth/domain/entities/etudiant_entity.dart';

class GradingPage extends ConsumerStatefulWidget {
  const GradingPage({super.key});

  @override
  ConsumerState<GradingPage> createState() => _GradingPageState();
}

class _GradingPageState extends ConsumerState<GradingPage> {
  String? _selectedPromoId;
  String? _selectedCourseId;
  final Map<String, double> _points = {};
  final Map<String, TextEditingController> _controllers = {}; // Pour le pré-remplissage
  bool _isSaving = false;

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_selectedCourseId == null || _points.isEmpty) return;
    if (_selectedPromoId == null) return;
    
    final currentYear = ref.read(currentAcademicYearProvider).value ?? "2025-2026";
    
    setState(() => _isSaving = true);
    try {
      await ref.read(academicRepositoryProvider).saveGrades(
        _selectedCourseId!, 
        _selectedPromoId!,
        currentYear, 
        _points
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Toutes les cotes ont été synchronisées avec succès !"), backgroundColor: Colors.green),
        );
        setState(() {
          _selectedCourseId = null; 
          _points.clear();
          for (var c in _controllers.values) {
            c.clear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'enregistrement : $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosWithDetailsAsync = ref.watch(promotionsWithDetailsProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final studentsAsync = _selectedPromoId != null ? ref.watch(studentsByPromoProvider(_selectedPromoId)) : null;
    final currentYearAsync = ref.watch(currentAcademicYearProvider);
    final bool isMobile = Responsive.isMobile(context);

    final currentYear = currentYearAsync.value ?? "2025-2026";
    final notesPromoAsync = _selectedPromoId != null 
      ? ref.watch(notesByPromoProvider((idPromo: _selectedPromoId!, anneeAcad: currentYear)))
      : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Fond légèrement bleuté plus pro
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SAISIE DES NOTES (LMD)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1, color: AppColors.primaryBlue)),
            currentYearAsync.when(
              data: (year) => Text('Session Académique $year', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (_selectedCourseId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_done_rounded),
                label: const Text('ENREGISTRER TOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 15 : 35),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                PremiumFadeIn(child: _buildSelectors(promosWithDetailsAsync, coursesAsync, notesPromoAsync, studentsAsync, isMobile)),
                const SizedBox(height: 35),
                if (_selectedPromoId != null && _selectedCourseId != null)
                  PremiumFadeIn(delay: const Duration(milliseconds: 200), child: _buildStudentListCard(studentsAsync, notesPromoAsync, isMobile))
                else
                  _buildOpeningDesign(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectors(
    AsyncValue<List<Map<String, dynamic>>> promosAsync, 
    AsyncValue<List<CoursEntity>> coursesAsync,
    AsyncValue<List<Map<String, dynamic>>>? notesPromoAsync,
    AsyncValue<List<EtudiantEntity>>? studentsAsync,
    bool isMobile
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.tune_rounded, color: AppColors.primaryBlue, size: 18),
                  ),
                  const SizedBox(width: 15),
                  const Text("CONFIGURATION DE LA SESSION", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 11, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 30),
              isMobile 
                ? Column(children: [
                    _buildPromoDropdown(promosAsync),
                    const SizedBox(height: 15),
                    _buildCourseDropdown(coursesAsync, notesPromoAsync, studentsAsync),
                  ])
                : Row(children: [
                    Expanded(flex: 3, child: _buildPromoDropdown(promosAsync)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _buildCourseDropdown(coursesAsync, notesPromoAsync, studentsAsync)),
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoDropdown(AsyncValue<List<Map<String, dynamic>>> promosAsync) {
    return promosAsync.when(
      data: (list) => DropdownButtonFormField<String>(
        value: _selectedPromoId,
        isExpanded: true,
        hint: const Text("-- Promotion --", style: TextStyle(fontSize: 13, color: Colors.grey)),
        decoration: _inputDeco(Icons.school_rounded),
        items: list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p['stableId'].toString(), child: Text(p['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
        onChanged: (v) => setState(() { _selectedPromoId = v; _selectedCourseId = null; _points.clear(); }),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Erreur: $e'),
    );
  }

  Widget _buildCourseDropdown(
    AsyncValue<List<CoursEntity>> coursesAsync,
    AsyncValue<List<Map<String, dynamic>>>? notesPromoAsync,
    AsyncValue<List<EtudiantEntity>>? studentsAsync,
  ) {
    return coursesAsync.when(
      data: (list) {
        final filtered = list.where((c) => c.idPromo == _selectedPromoId).toList();
        final List<Map<String, dynamic>> notes = notesPromoAsync?.value ?? [];
        final int studentCount = studentsAsync?.value?.length ?? 0;

        final availableCourses = filtered.where((c) {
          final int noteCount = notes.where((n) => n['id_cours'] == c.id).length;
          return studentCount == 0 || noteCount < studentCount;
        }).toList();

        return DropdownButtonFormField<String>(
          value: _selectedCourseId,
          isExpanded: true,
          hint: const Text("-- Cours --", style: TextStyle(fontSize: 13, color: Colors.grey)),
          decoration: _inputDeco(Icons.auto_stories_rounded),
          items: availableCourses.map<DropdownMenuItem<String>>((c) {
            return DropdownMenuItem(
              value: c.id, 
              child: Text(c.intituleCours, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
            );
          }).toList(),
          onChanged: (v) => setState(() { _selectedCourseId = v; _points.clear(); }),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStudentListCard(
    AsyncValue<List<EtudiantEntity>>? studentsAsync, 
    AsyncValue<List<Map<String, dynamic>>>? notesPromoAsync,
    bool isMobile
  ) {
    if (studentsAsync == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 50, offset: const Offset(0, 20))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 25 : 40),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.list_alt_rounded, color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("LISTE DE SAISIE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    const Text("Enregistrement direct en base de données", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
                const Spacer(),
                if (studentsAsync.value != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: Text("${studentsAsync.value!.length} Étudiants", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
              ],
            ),
          ),
          studentsAsync.when(
            data: (students) {
              if (students.isEmpty) return _buildEmptyState("Aucun étudiant inscrit dans cette promotion.");
              
              // Récupérer les notes existantes pour ce cours
              final existingNotes = notesPromoAsync?.value?.where((n) => n['id_cours'] == _selectedCourseId).toList() ?? [];

              return ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 70,
                    dataRowHeight: 85,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF0F172A)),
                    horizontalMargin: isMobile ? 25 : 45,
                    dividerThickness: 0.5,
                    columns: const [
                      DataColumn(label: Text("ÉTUDIANT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))),
                      DataColumn(label: Text("MATRICULE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))),
                      DataColumn(label: Center(child: Text("NOTE / 20", style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)))),
                    ],
                    rows: students.map((e) {
                      // Chercher si une note existe pour cet étudiant
                      final existing = existingNotes.where((n) => n['id_etu'] == e.id).firstOrNull;
                      final double? initialVal = existing != null ? (existing['cote'] as num).toDouble() : null;

                      return DataRow(
                        cells: [
                          DataCell(Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFFF1F5F9),
                                backgroundImage: (e.photoProfil != 'default.jpg' && e.photoProfil.startsWith('http'))
                                  ? NetworkImage(e.photoProfil)
                                  : const AssetImage('assets/images/logo.jpg') as ImageProvider,
                              ),
                              const SizedBox(width: 15),
                              Text("${e.nomEtu} ${e.prenomEtu}".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B))),
                            ],
                          )),
                          DataCell(Text(e.matriculeEtu, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                          DataCell(Center(child: _buildGradeInput(e.id, initialVal))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator())),
            error: (e, _) => Text('Erreur: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeInput(String studentId, double? initialVal) {
    final controller = _controllers.putIfAbsent(studentId, () => TextEditingController(text: initialVal?.toString() ?? ''));
    
    // Si une valeur initiale existe, on l'ajoute à la map locale pour éviter de l'écraser par 0
    if (initialVal != null && !_points.containsKey(studentId)) {
      _points[studentId] = initialVal;
    }

    return Container(
      width: 80,
      height: 45,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          _points[studentId] = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
        },
        style: TextStyle(
          fontWeight: FontWeight.w900, 
          color: initialVal != null ? Colors.green : AppColors.primaryBlue
        ),
        decoration: InputDecoration(
          hintText: '-',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: initialVal != null ? Colors.green.withOpacity(0.05) : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), 
            borderSide: BorderSide(color: initialVal != null ? Colors.green.withOpacity(0.3) : const Color(0xFFCBD5E1))
          ),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
        ),
      ),
    );
  }

  Widget _buildOpeningDesign(bool isMobile) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _verticalStepCard(
          "Sélectionnez la Promotion", 
          "Étape 1", 
          Icons.school_rounded, 
          AppColors.primaryBlue
        ),
        _verticalStepCard(
          "Choisissez le Cours", 
          "Étape 2", 
          Icons.auto_stories_rounded, 
          Colors.green
        ),
        _verticalStepCard(
          "Saisissez les Notes", 
          "Étape 3", 
          Icons.edit_document, 
          AppColors.premiumGold
        ),
      ],
    );
  }

  Widget _verticalStepCard(String title, String step, IconData icon, Color color) {
    return Container(
      width: 180,
      height: 220,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 40),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(step.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Icon(Icons.edit_note_rounded, size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            Text(msg, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, size: 18, color: AppColors.primaryBlue),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
  );
}
