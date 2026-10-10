import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/academic/domain/entities/cours_entity.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';

class TeacherEvaluationPage extends ConsumerStatefulWidget {
  final CoursEntity course;
  final String teacherName;

  const TeacherEvaluationPage({
    super.key,
    required this.course,
    required this.teacherName,
  });

  @override
  ConsumerState<TeacherEvaluationPage> createState() => _TeacherEvaluationPageState();
}

class _TeacherEvaluationPageState extends ConsumerState<TeacherEvaluationPage> {
  final Map<int, String> _responses = {};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _options = [
    'Très satisfait',
    'Satisfait',
    'Ni satisfait ni non satisfait',
    'Non satisfait',
    'D\'accord'
  ];

  final List<Map<String, dynamic>> _defaultCriteria = [
    {'id_critere': 1, 'libelle_critere': 'Ponctualité et régularité de l\'enseignant'},
    {'id_critere': 2, 'libelle_critere': 'Présentation claire du plan de cours'},
    {'id_critere': 3, 'libelle_critere': 'Clarté des objectifs pédagogiques'},
    {'id_critere': 4, 'libelle_critere': 'Maîtrise du sujet par l\'enseignant'},
    {'id_critere': 5, 'libelle_critere': 'Capacité à expliquer des concepts complexes'},
    {'id_critere': 6, 'libelle_critere': 'Qualité et pertinence des supports fournis'},
    {'id_critere': 7, 'libelle_critere': 'Utilisation efficace du temps de cours'},
    {'id_critere': 8, 'libelle_critere': 'Interaction et dynamisme durant les séances'},
    {'id_critere': 9, 'libelle_critere': 'Qualité des réponses aux questions'},
    {'id_critere': 10, 'libelle_critere': 'Respect du volume horaire prévu'},
    {'id_critere': 11, 'libelle_critere': 'Lien entre la théorie et la pratique'},
    {'id_critere': 12, 'libelle_critere': 'Actualité des connaissances transmises'},
    {'id_critere': 13, 'libelle_critere': 'Clarté des critères d\'évaluation'},
    {'id_critere': 14, 'libelle_critere': 'Pertinence des travaux pratiques (TP)'},
    {'id_critere': 15, 'libelle_critere': 'Accessibilité et disponibilité de l\'enseignant'},
    {'id_critere': 16, 'libelle_critere': 'Utilisation des technologies (Tics)'},
    {'id_critere': 17, 'libelle_critere': 'Encouragement de la réflexion critique'},
    {'id_critere': 18, 'libelle_critere': 'Clarté de la voix et de l\'élocution'},
    {'id_critere': 19, 'libelle_critere': 'Respect envers les étudiants'},
    {'id_critere': 20, 'libelle_critere': 'Équilibre entre les différents chapitres'},
    {'id_critere': 21, 'libelle_critere': 'Capacité à susciter l\'intérêt pour la matière'},
    {'id_critere': 22, 'libelle_critere': 'Organisation générale des enseignements'},
    {'id_critere': 23, 'libelle_critere': 'Pertinence des exemples utilisés'},
    {'id_critere': 24, 'libelle_critere': 'Niveau de satisfaction globale du cours'},
  ];

  Future<void> _submit() async {
    if (_responses.length < 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez répondre à tous les 24 critères.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) throw Exception("Utilisateur non connecté.");

      // Vérifier si déjà évalué (Double sécurité)
      final existing = await ref.read(academicRepositoryProvider).getStudentEvaluations(user.id).first;
      final alreadyDone = existing.any((e) => e['id_cours']?.toString() == widget.course.idCours.toString());
      
      if (alreadyDone) {
        throw Exception("Vous avez déjà évalué ce cours.");
      }

      await ref.read(academicRepositoryProvider).submitEvaluation({
        'id_etu': user?.id,
        'id_cours': widget.course.idCours.toString(),
        'id_ens': widget.course.idEns,
        'commentaire_general': _commentController.text,
        'details': _responses,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("✅ Opération réussie"),
            content: const Text("Merci d'avoir évalué l'enseignant ! Votre avis compte pour l'excellence."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to courses
                }, 
                child: const Text("RETOUR À MES COURS"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: CustomScrollView(
        slivers: [
          PremiumInfoAppBar(
            title: 'ÉVALUATION',
            subtitle: "Cours : ${widget.course.intituleCours}",
            icon: Icons.rate_review_rounded,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 15 : 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 30),
                  _buildEvaluationTable(isMobile),
                  const SizedBox(height: 40),
                  _buildCommentSection(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FORMULAIRE D'ÉVALUATION DE L'ENSEIGNANT",
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepNavy, fontSize: 16, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            "Enseignant : ${widget.teacherName.toUpperCase()}",
            style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 30),
          const Text(
            "Note : Vos réponses sont traitées de manière anonyme et servent uniquement à l'amélioration de la qualité de l'enseignement.",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          // Header of the "table"
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF455A64),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text('CARACTÉRISTIQUES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                if (!isMobile)
                  ..._options.map((opt) => Expanded(
                    child: Text(opt, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  )).toList(),
              ],
            ),
          ),
          // Criteria Rows
          ..._defaultCriteria.map((c) => _buildCriteriaRow(c, isMobile)),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(Map<String, dynamic> c, bool isMobile) {
    final int id = c['id_critere'];
    final String label = c['libelle_critere'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: isMobile 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$id. $label", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.deepNavy)),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _options.map((opt) => Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: opt,
                            groupValue: _responses[id],
                            onChanged: (val) => setState(() => _responses[id] = val!),
                            activeColor: AppColors.primaryBlue,
                          ),
                          Text(opt, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text("$id. $label", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.deepNavy)),
                ),
                ..._options.map((opt) => Expanded(
                  child: Radio<String>(
                    value: opt,
                    groupValue: _responses[id],
                    onChanged: (val) => setState(() => _responses[id] = val!),
                    activeColor: AppColors.primaryBlue,
                  ),
                )).toList(),
              ],
            ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMMENTAIRE LIBRE',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF455A64), fontSize: 12, letterSpacing: 1),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _commentController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "Écrivez ici vos remarques supplémentaires...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        child: _isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('ENVOYER L\'ÉVALUATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}
