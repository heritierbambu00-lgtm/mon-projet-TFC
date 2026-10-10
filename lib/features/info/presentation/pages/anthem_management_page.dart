import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/anthem_entity.dart';

class AnthemManagementPage extends ConsumerStatefulWidget {
  const AnthemManagementPage({super.key});

  @override
  ConsumerState<AnthemManagementPage> createState() => _AnthemManagementPageState();
}

class _AnthemManagementPageState extends ConsumerState<AnthemManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  String _currentId = "";

  void _save() async {
    final anthem = AnthemEntity(
      id: _currentId,
      titre: _titleController.text.trim(),
      paroles: _lyricsController.text.trim(),
    );

    try {
      await ref.read(infoRepositoryProvider).updateAnthem(anthem);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hymne mis à jour !"), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final anthemAsync = ref.watch(anthemProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('GESTION DE L\'HYMNE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.premiumGold, fontFamily: 'Playfair Display')),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.premiumGold),
      ),
      body: anthemAsync.when(
        data: (anthem) {
          if (anthem != null && _currentId.isEmpty) {
            _currentId = anthem.id;
            _titleController.text = anthem.titre;
            _lyricsController.text = anthem.paroles;
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 30),
            child: Column(
              children: [
                _buildForm(),
                const SizedBox(height: 50),
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
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TITRE DE L'HYMNE", style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 15),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 30),
          const Text("PAROLES COMPLÈTES", style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 15),
          TextField(
            controller: _lyricsController,
            maxLines: 15,
            style: const TextStyle(color: Colors.white, height: 1.6),
            decoration: InputDecoration(filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.premiumGold, foregroundColor: AppColors.deepNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text('ENREGISTRER L\'HYMNE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
