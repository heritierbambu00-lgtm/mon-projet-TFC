import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/info/presentation/providers/info_providers.dart';
import 'package:istm_mahagi/features/info/domain/entities/statute_entity.dart';

class StatutesPage extends ConsumerWidget {
  const StatutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statutesAsync = ref.watch(statutesProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'STATUTS & TEXTES',
            subtitle: "Cadre légal et institutionnel",
            icon: Icons.description_rounded,
          ),
          statutesAsync.when(
            data: (statutes) {
              if (statutes.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucun document disponible',
                      style: TextStyle(color: Colors.white24),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            PremiumFadeIn(child: _buildInfoBanner()),
                            const SizedBox(height: 40),
                            PremiumFadeIn(
                              delay: const Duration(milliseconds: 200),
                              child: _buildStatuteItem(statutes[index])
                            ),
                          ],
                        );
                      }
                      return PremiumFadeIn(
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildStatuteItem(statutes[index])
                      );
                    },
                    childCount: statutes.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.premiumGold)),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Erreur: $err', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        gradient: AppColors.deepGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 15)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentYellow.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.info_outline_rounded, color: AppColors.accentYellow, size: 28),
          ),
          const SizedBox(width: 25),
          const Expanded(
            child: Text(
              'Consultez les documents officiels régissant le fonctionnement de notre institution.',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatuteItem(StatuteEntity statute) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 28),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statute.titre.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900, 
                          color: Colors.white, 
                          fontFamily: 'Playfair Display',
                          fontSize: 15,
                          letterSpacing: 0.5
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statute.description, 
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.4)
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.premiumGold, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
