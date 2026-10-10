import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/academic/domain/entities/horaire_entity.dart';
import 'package:istm_mahagi/features/academic/domain/entities/cours_entity.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';

class StudentSchedulePage extends ConsumerWidget {
  const StudentSchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final List<String> joursSemaine = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('⏰ Mon Emploi du Temps', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003366)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userDataAsync.when(
        data: (user) {
          if (user == null || user is! EtudiantEntity) {
            return const Center(child: Text("Accès réservé aux étudiants."));
          }

          final schedulesAsync = ref.watch(schedulesProvider(user.idPromo.toString()));

          return schedulesAsync.when(
            data: (schedules) => coursesAsync.when(
              data: (courses) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: joursSemaine.map((jour) {
                        final seances = schedules.where((s) => s.jour == jour).toList();
                        seances.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));
                        return _buildDayCard(jour, seances, courses, context);
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur cours: $e")),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Erreur horaire: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur utilisateur: $e")),
      ),
    );
  }

  Widget _buildDayCard(String jour, List<HoraireEntity> seances, List<CoursEntity> courses, BuildContext context) {
    final double width = Responsive.isMobile(context) ? MediaQuery.of(context).size.width - 40 : 320;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFF003366), width: 8),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: const Color(0xFFF8F9FA),
            child: Text(
              jour.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF003366),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(15),
            child: seances.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Aucun cours',
                      style: TextStyle(color: Color(0xFFA0AEC0), fontStyle: FontStyle.italic),
                    ),
                  )
                : Column(
                    children: seances.map((s) {
                      final course = courses.firstWhere(
                        (c) => c.id == s.idCours,
                        orElse: () => CoursEntity(id: '', idCours: 0, codeCours: '', intituleCours: 'Non défini', credits: 0, idEns: '', idPromo: ''),
                      );
                      return _buildCourseSlot(s, course);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSlot(HoraireEntity s, CoursEntity course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDF2F7)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🕒 ${s.heureDebut.substring(0, 5)} - ${s.heureFin.substring(0, 5)}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF004A99),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            course.intituleCours,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF718096)),
              const SizedBox(width: 5),
              Text(
                'Salle : ${s.salle}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
