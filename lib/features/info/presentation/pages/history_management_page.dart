import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/history_entity.dart';

class HistoryManagementPage extends ConsumerStatefulWidget {
  const HistoryManagementPage({super.key});

  @override
  ConsumerState<HistoryManagementPage> createState() => _HistoryManagementPageState();
}

class _HistoryManagementPageState extends ConsumerState<HistoryManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _currentId = "";

  void _save() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    final history = HistoryEntity(
      id: _currentId,
      titre: _titleController.text.trim(),
      contenu: _contentController.text.trim(),
      dateMaj: DateTime.now(),
    );

    try {
      await ref.read(infoRepositoryProvider).updateHistory(history);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Historique synchronisé !"), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('CMS : HISTORIQUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.premiumGold, fontFamily: 'Playfair Display')),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.premiumGold),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history != null && _currentId.isEmpty) {
            _currentId = history.id;
            _titleController.text = history.titre;
            _contentController.text = history.contenu;
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 30),
            child: Column(
              children: [
                _buildForm(),
                const SizedBox(height: 50),
                if (history != null) _buildCurrentVersionPreview(history),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.premiumGold)),
        error: (e, _) => Center(child: Text("Erreur : $e")),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.premiumGold.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MISE À JOUR DU RÉCIT", style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 25),
          _buildInput(_titleController, "Titre de la section"),
          const SizedBox(height: 15),
          _buildInput(_contentController, "Récit complet...", maxLines: 10),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.premiumGold, foregroundColor: AppColors.deepNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text('PUBLIER LES MODIFICATIONS', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true, fillColor: AppColors.deepNavy,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        hintText: hint, hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      ),
    );
  }

  Widget _buildCurrentVersionPreview(HistoryEntity h) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("VERSION ACTUELLE EN LIGNE", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 20),
          Text(h.titre, style: const TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(h.contenu, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
