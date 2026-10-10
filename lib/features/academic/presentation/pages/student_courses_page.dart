import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/course_documents_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/teacher_evaluation_page.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/enseignant_entity.dart';
import 'package:istm_mahagi/features/academic/domain/entities/cours_entity.dart';

class StudentCoursesPage extends ConsumerWidget {
  const StudentCoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final teachersAsync = ref.watch(teachersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(Responsive.isMobile(context) ? 'MES COURS' : 'MES COURS ACADÉMIQUES', 
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: userDataAsync.when(
        data: (user) {
          if (user == null || user is! EtudiantEntity) return const Center(child: Text("Accès refusé."));

          final coursesAsync = ref.watch(getStudentCoursesProvider((promoId: user.idPromo, anneeAcad: null)));
          final evalsAsync = ref.watch(studentEvaluationsProvider(user.id));
          final libraryAsync = ref.watch(libraryDocumentsProvider(user.idPromo));
          final bool isMobile = Responsive.isMobile(context);

          return coursesAsync.when(
            data: (courses) => evalsAsync.when(
              data: (evals) {
                final evaluatedCourseIds = evals.map((e) => e['id_cours']?.toString()).toSet();
                
                return teachersAsync.when(
                  data: (teachers) => SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 15 : 30),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMainTable(context, courses, teachers, evaluatedCourseIds, isMobile),
                            const SizedBox(height: 50),
                            _buildLibrarySection(libraryAsync),
                            const SizedBox(height: 40),
                            _buildQuizWidget(),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Erreur enseignants: $e")),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur évaluations: $e")),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Erreur cours: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur utilisateur: $e")),
      ),
    );
  }

  Widget _buildMainTable(BuildContext context, List<CoursEntity> courses, List<EnseignantEntity> teachers, Set<String?> evaluatedCourseIds, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 25),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'PROGRAMME DE L\'ANNÉE ACADÉMIQUE 2025-2026',
                style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF455A64), fontSize: isMobile ? 13 : 15, letterSpacing: 1),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFF455A64)),
                headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text('N°')),
                  DataColumn(label: Text('CODE UE')),
                  DataColumn(label: Text('INTITULÉ DE L\'EC')),
                  DataColumn(label: Text('CRÉDIT')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: List.generate(courses.length, (index) {
                  final c = courses[index];
                  final EnseignantEntity teacher = teachers.firstWhere(
                    (t) => t.id == c.idEns, 
                    orElse: () => teachers.isNotEmpty ? teachers.first : EnseignantEntity(id: '', matriculeEns: '', nomEns: 'Inconnu', postnomEns: '', specialite: '', emailPro: '', photoEns: 'default.jpg'),
                  );
                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(c.codeCours, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(c.intituleCours, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(c.credits.toString())),
                      DataCell(_buildActionMenu(context, c, teacher, evaluatedCourseIds.contains(c.idCours.toString()))),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySection(AsyncValue<List<Map<String, dynamic>>> libraryAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📚 BIBLIOTHÈQUE SUGGÉRÉE (Fichiers Réels)',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textMuted, fontSize: 10, letterSpacing: 3),
        ),
        const SizedBox(height: 25),
        libraryAsync.when(
          data: (docs) {
            if (docs.isEmpty) return const Text("Aucun livre suggéré pour le moment.", style: TextStyle(color: Colors.grey, fontSize: 12));
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: docs.map((doc) => _buildBookCard(
                  doc['titre_doc'] ?? 'Inconnu', 
                  doc['auteur'] ?? 'ISTM', 
                  AppColors.primaryBlue
                )).toList(),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text("Erreur bibliothèque: $e"),
        ),
      ],
    );
  }

  Widget _buildBookCard(String title, String author, Color color) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.menu_book_rounded, color: color, size: 45),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.deepNavy, fontFamily: 'Playfair Display'), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text(author.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildQuizWidget() {
    return PremiumFadeIn(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.deepNavy,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.psychology_rounded, color: AppColors.accentYellow, size: 35),
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('QUIZZ D\'AUTO-ÉVALUATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text('Testez vos acquis sur les chapitres vus récemment.', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {}, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.deepNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
              ),
              child: const Text('DÉMARRER'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, CoursEntity course, EnseignantEntity teacher, bool isEvaluated) {
    final String teacherName = "${teacher.nomEns} ${teacher.postnomEns}";
    
    return PopupMenuButton<dynamic>(
      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFF1976D2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDocumentsPage(course: course, type: 'TP'))),
          child: _menuItem(Icons.build_outlined, 'Travaux Pratiques', Colors.black87),
        ),
        PopupMenuItem(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDocumentsPage(course: course, type: 'Note de cours'))),
          child: _menuItem(Icons.analytics_outlined, 'Voir mes notes', const Color(0xFF27AE60)),
        ),
        PopupMenuItem(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDocumentsPage(course: course, type: 'Note de cours'))),
          child: _menuItem(Icons.description_outlined, 'Supports de Cours', const Color(0xFF1976D2)),
        ),
        PopupMenuItem(
          enabled: !isEvaluated,
          onTap: isEvaluated ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherEvaluationPage(course: course, teacherName: teacherName))),
          child: isEvaluated 
            ? _menuItem(Icons.check_circle_rounded, 'Vous avez déjà évalué ce cours', Colors.green)
            : _menuItem(Icons.rate_review_outlined, 'Évaluer l\'enseignement', const Color(0xFFD35400)),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enseignant :', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(teacherName.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
