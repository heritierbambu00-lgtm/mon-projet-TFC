import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/info/presentation/providers/info_providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'NOTRE HISTOIRE',
            subtitle: "Un héritage d'excellence",
            bgImage: 'assets/images/slider2.jpg',
          ),
          historyAsync.when(
            data: (history) {
              if (history == null) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white38)),
                  ),
                );
              }
              return SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color(0xFF112240), Color(0xFF0A192F)],
                      center: Alignment.topCenter,
                      radius: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PremiumFadeIn(
                          child: Text(
                            history.titre.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: AppColors.premiumGold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        PremiumFadeIn(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: const Color(0xFF112240).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.premiumGold.withOpacity(0.1)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)],
                            ),
                            child: Text(
                              history.contenu,
                              style: const TextStyle(
                                fontSize: 17, 
                                height: 1.9, 
                                color: Colors.white70,
                                fontFamily: 'Playfair Display',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        PremiumFadeIn(
                          delay: const Duration(milliseconds: 400),
                          child: Container(
                            width: double.infinity,
                            height: 350,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/slider1.jpg'),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: AppColors.premiumGold.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(color: AppColors.premiumGold.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
}
