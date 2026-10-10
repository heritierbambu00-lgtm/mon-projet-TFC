import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/academic/domain/entities/cours_entity.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';

class CourseDocumentsPage extends ConsumerWidget {
  final CoursEntity course;
  final String type; // 'TP' or 'Note de cours'

  const CourseDocumentsPage({
    super.key,
    required this.course,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(courseDocumentsProvider((idCours: course.idCours.toString(), type: type)));
    final bool isTP = type == 'TP';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          PremiumInfoAppBar(
            title: isTP ? 'TRAVAUX PRATIQUES' : 'NOTES DE COURS',
            subtitle: course.intituleCours,
            icon: isTP ? Icons.assignment_rounded : Icons.menu_book_rounded,
          ),
          docsAsync.when(
            data: (docs) => docs.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: Text("Aucun document disponible pour le moment.")),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDocCard(context, ref, docs[index], isTP),
                        childCount: docs.length,
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text("Erreur: $e"))),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, WidgetRef ref, Map<String, dynamic> doc, bool isTP) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isTP ? Colors.orange : Colors.green).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isTP ? Icons.description_rounded : Icons.picture_as_pdf_rounded, 
            color: isTP ? Colors.orange : Colors.green
          ),
        ),
        title: Text(
          doc['titre_doc'] ?? 'Document sans titre',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy),
        ),
        subtitle: Text(
          "Publié le : ${doc['date_publication'] ?? 'N/A'}",
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download_rounded, color: AppColors.primaryBlue),
              onPressed: () {
                // Simuler téléchargement
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Téléchargement du support lancé..."))
                );
              },
            ),
            if (isTP)
              ElevatedButton(
                onPressed: () => _showSubmitDialog(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD35400),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                child: const Text('DÉPOSER'),
              ),
          ],
        ),
      ),
    );
  }

  void _showSubmitDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déposer votre TP', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Veuillez sélectionner le fichier de votre travail pratique."),
            SizedBox(height: 20),
            Icon(Icons.upload_file_rounded, size: 50, color: Colors.grey),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(academicRepositoryProvider).submitTP(
                  course.idCours.toString(), 
                  user.id, 
                  "tp_response_${DateTime.now().millisecondsSinceEpoch}.pdf"
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ TP déposé avec succès !"), backgroundColor: Colors.green)
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ $e"), backgroundColor: Colors.red)
                  );
                }
              }
            },
            child: const Text('ENVOYER'),
          ),
        ],
      ),
    );
  }
}
