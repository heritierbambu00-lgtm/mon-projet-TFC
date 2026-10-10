import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/home/presentation/providers/home_providers.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'ACTUALITÉS',
            subtitle: "Les dernières nouvelles de l'ISTM",
            icon: Icons.newspaper_rounded,
          ),
          newsAsync.when(
            data: (articles) => SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PremiumFadeIn(
                    delay: Duration(milliseconds: 100 * index),
                    child: _buildNewsCard(context, articles[index]),
                  ),
                  childCount: articles.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.premiumGold))),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text("Erreur : $e"))),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, dynamic article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  article.imageUrl, 
                  height: 250, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Playfair Display'),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      article.content,
                      style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
