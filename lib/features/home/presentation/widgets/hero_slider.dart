import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import '../../../../core/constants/app_colors.dart';

class HeroSlider extends StatelessWidget {
  final bool isLoginVisible;
  final Function(String) onLoginClick;

  const HeroSlider({
    super.key,
    required this.isLoginVisible,
    required this.onLoginClick,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    final List<String> imgList = [
      'assets/images/slider1.jpg',
      'assets/images/slider2.jpg',
      'assets/images/slider3.jpg',
    ];

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: isMobile ? 450.0 : (isTablet ? 550.0 : 650.0),
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          items: imgList.map((assetPath) {
            return Container(
              width: size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetPath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        if (!isLoginVisible)
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        PremiumFadeIn(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: AppColors.accentYellow.withOpacity(0.3)),
                            ),
                            child: Text(
                              'EXCELLENCE ACADÉMIQUE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.accentYellow,
                                fontSize: isMobile ? 10 : 12,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Science, Prestige',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 42 : (isTablet ? 65 : 85),
                            height: 1.0,
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          '& Santé',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 52 : (isTablet ? 80 : 100),
                            height: 0.9,
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        PremiumFadeIn(
                          child: Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'L\'INSTITUT SUPÉRIEUR DES TECHNIQUES MÉDICALES DE MAHAGI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isMobile ? 10 : 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
