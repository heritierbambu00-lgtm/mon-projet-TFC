import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import '../providers/info_providers.dart';

class AnthemPage extends ConsumerStatefulWidget {
  const AnthemPage({super.key});

  @override
  ConsumerState<AnthemPage> createState() => _AnthemPageState();
}

class _AnthemPageState extends ConsumerState<AnthemPage> {
  bool isPlaying = false;
  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    final anthemAsync = ref.watch(anthemProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'HYMNE DE L\'ISTM',
            subtitle: "La voix de notre engagement",
            icon: Icons.music_note_rounded,
          ),
          SliverToBoxAdapter(
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
                child: anthemAsync.when(
                  data: (anthem) => Column(
                    children: [
                      PremiumFadeIn(child: _buildPlayerCard()),
                      const SizedBox(height: 80),
                      PremiumFadeIn(
                        delay: const Duration(milliseconds: 300),
                        child: _buildLyricsSection(anthem?.paroles ?? "Paroles en cours de chargement...")
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.premiumGold)),
                  error: (e, _) => Center(child: Text("Erreur : $e", style: const TextStyle(color: Colors.redAccent))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'LECTEUR AUDIO PREMIUM',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.accentYellow,
              fontSize: 10,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, size: 32),
                onPressed: () {},
                color: Colors.white24,
              ),
              const SizedBox(width: 30),
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.premiumGold.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 45),
                  onPressed: () => setState(() => isPlaying = !isPlaying),
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, size: 32),
                onPressed: () {},
                color: Colors.white24,
              ),
            ],
          ),
          const SizedBox(height: 45),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.premiumGold,
              inactiveTrackColor: Colors.white.withOpacity(0.05),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: progress,
              onChanged: (v) => setState(() => progress = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0:00', style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('3:45', style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection(String paroles) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.premiumGold.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 45),
        const Text(
          'LES PAROLES DE L\'EXCELLENCE',
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 11, 
            color: Colors.white38,
            letterSpacing: 4
          ),
        ),
        const SizedBox(height: 45),
        Text(
          paroles,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            height: 2.2, 
            color: Colors.white70,
            fontFamily: 'Playfair Display',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 60),
        const Icon(Icons.auto_awesome_rounded, color: goldAccentAlpha, size: 30),
      ],
    );
  }
}

const Color goldAccentAlpha = Color(0x33C5A059);
