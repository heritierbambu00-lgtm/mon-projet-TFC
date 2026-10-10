import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/mission_vision_entity.dart';

class MissionVisionManagementPage extends ConsumerStatefulWidget {
  const MissionVisionManagementPage({super.key});

  @override
  ConsumerState<MissionVisionManagementPage> createState() => _MissionVisionManagementPageState();
}

class _MissionVisionManagementPageState extends ConsumerState<MissionVisionManagementPage> {
  final TextEditingController _missionController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final TextEditingController _valeursController = TextEditingController();
  String _currentId = "";

  void _save() async {
    final mv = MissionVisionEntity(
      id: _currentId,
      mission: _missionController.text.trim(),
      vision: _visionController.text.trim(),
      valeurs: _valeursController.text.trim(),
    );

    try {
      await ref.read(infoRepositoryProvider).updateMissionVision(mv);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Valeurs institutionnelles mises à jour !"), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mvAsync = ref.watch(missionVisionProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('CMS : MISSION & VISION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.premiumGold, fontFamily: 'Playfair Display')),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.premiumGold),
      ),
      body: mvAsync.when(
        data: (mv) {
          if (mv != null && _currentId.isEmpty) {
            _currentId = mv.id;
            _missionController.text = mv.mission;
            _visionController.text = mv.vision;
            _valeursController.text = mv.valeurs;
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 30),
            child: Column(
              children: [
                _buildFieldCard("NOTRE MISSION", _missionController, 5, Icons.flag_rounded, Colors.blue),
                const SizedBox(height: 20),
                _buildFieldCard("NOTRE VISION", _visionController, 5, Icons.visibility_rounded, Colors.orange),
                const SizedBox(height: 20),
                _buildFieldCard("NOS VALEURS", _valeursController, 5, Icons.stars_rounded, Colors.teal),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.premiumGold, foregroundColor: AppColors.deepNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text('METTRE À JOUR LE CAP', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.premiumGold)),
        error: (e, _) => Center(child: Text("Erreur : $e")),
      ),
    );
  }

  Widget _buildFieldCard(String label, TextEditingController controller, int lines, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLines: lines,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
            decoration: InputDecoration(filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
        ],
      ),
    );
  }
}
