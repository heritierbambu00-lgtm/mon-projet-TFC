import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/home/presentation/providers/home_providers.dart';
import 'package:istm_mahagi/features/home/domain/entities/gallery_item.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF112240), Color(0xFF0A192F)],
            center: Alignment.topCenter,
            radius: 1.5,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            const PremiumInfoAppBar(
              title: 'GALERIE PHOTOS',
              subtitle: "Les moments forts de la vie universitaire",
              bgImage: 'assets/images/slider1.jpg',
            ),
            galleryAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('Aucune photo disponible dans la galerie.', style: TextStyle(color: Colors.white24))),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.all(Responsive.getPadding(context)),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 3 : 2),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PremiumFadeIn(
                        delay: Duration(milliseconds: 50 * index),
                        child: _buildGalleryCard(context, items[index], index),
                      ),
                      childCount: items.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.premiumGold))),
              error: (err, _) => SliverFillRemaining(child: Center(child: Text('Erreur: $err', style: const TextStyle(color: Colors.redAccent)))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context, GalleryItem item, int index) {
    return GestureDetector(
      onTap: () => _showFullImage(context, item.imageUrl, item.legende),
      child: Hero(
        tag: 'img_$index',
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF112240),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.imageUrl, 
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900, child: const Icon(Icons.broken_image, color: Colors.white12)),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  child: Text(
                    item.legende.toUpperCase(),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.premiumGold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String url, String legende) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(color: Colors.transparent, width: double.infinity, height: double.infinity)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(url, fit: BoxFit.contain)),
                const SizedBox(height: 25),
                if (legende.isNotEmpty)
                  PremiumFadeIn(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        legende, 
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14, fontFamily: 'Playfair Display')
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(top: 20, right: 20, child: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 35), onPressed: () => Navigator.pop(context))),
          ],
        ),
      ),
    );
  }
}
