import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/info/presentation/providers/info_providers.dart';

class MissionVisionPage extends ConsumerWidget {
  const MissionVisionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'MISSION & VISION',
            subtitle: "Notre cap vers l'avenir",
            icon: Icons.track_changes_rounded,
          ),
          Consumer(builder: (context, ref, _) {
            final mvAsync = ref.watch(missionVisionProvider);
            return mvAsync.when(
              data: (mv) {
                if (mv == null) return const SliverFillRemaining(child: Center(child: Text('Aucune donnée', style: TextStyle(color: Colors.white24))));
                
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 60),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildPremiumCard('NOTRE MISSION', mv.mission, Icons.track_changes_rounded, Colors.blue),
                      const SizedBox(height: 40),
                      _buildPremiumCard('NOTRE VISION', mv.vision, Icons.visibility_rounded, AppColors.premiumGold, isHighlight: true),
                      const SizedBox(height: 40),
                      _buildPremiumCard('NOS VALEURS', mv.valeurs, Icons.diamond_rounded, Colors.teal),
                    ]),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.premiumGold))),
              error: (err, _) => SliverFillRemaining(child: Center(child: Text('Erreur: $err'))),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(String title, String content, IconData icon, Color accentColor, {bool isHighlight = false}) {
    return PremiumFadeIn(
      child: Container(
        padding: const EdgeInsets.all(45),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFF112240) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            if (isHighlight) BoxShadow(color: accentColor.withOpacity(0.05), blurRadius: 50, offset: const Offset(0, 20)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 45, color: accentColor),
            ),
            const SizedBox(height: 35),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accentColor, fontFamily: 'Playfair Display', letterSpacing: 2)),
            const SizedBox(height: 25),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.white70, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
