import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';

class PremiumInfoAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? bgImage;
  final IconData? icon;

  const PremiumInfoAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.bgImage,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SliverAppBar(
      expandedHeight: isMobile ? 220.0 : 280.0,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.7),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 20),
        title: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Playfair Display',
                    letterSpacing: 1.5,
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.deepGradient,
              ),
            ),
            if (bgImage != null)
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  bgImage!,
                  fit: BoxFit.cover,
                ),
              ),
            if (icon != null && bgImage == null)
              Center(
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
