import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';

import '../utils/responsive.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.deepNavy,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              AppColors.deepNavy,
              Color(0xFF020617),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background abstract shapes
            Positioned(
              top: -100,
              right: -100,
              child: _buildOrb(300, AppColors.primaryBlue.withOpacity(0.1)),
            ),
            Positioned(
              bottom: -50,
              left: -80,
              child: _buildOrb(250, AppColors.accentYellow.withOpacity(0.05)),
            ),
            
            // Logo background watermark
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset('assets/images/logo.jpg', width: isMobile ? 300 : 400),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 30),
                child: PremiumFadeIn(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isMobile ? 30 : 40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 25 : 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(isMobile ? 30 : 40),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon with Pulse Effect
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: isMobile ? 80 : 100,
                                  height: isMobile ? 80 : 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentYellow.withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(isMobile ? 18 : 25),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accentYellow.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.wifi_off_rounded,
                                    size: isMobile ? 35 : 50,
                                    color: AppColors.accentYellow,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 35),
                            
                            // Pre-title
                            Text(
                              'INTERRUPTION RÉSEAU',
                              style: TextStyle(
                                color: AppColors.accentYellow,
                                fontSize: isMobile ? 8 : 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            // Main Title
                            Text(
                              'Connexion Perdue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 24 : 32,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Playfair Display',
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Description
                            Text(
                              "Pour garantir l'excellence et la sécurité de vos données, ISTM MAHAGI nécessite une connexion internet stable.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: isMobile ? 12 : 14,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 45),
                            
                            // Premium Action Button
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: AppColors.premiumGradient,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: onRetry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.refresh_rounded, size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        'RÉESSAYER LA CONNEXION',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                          fontSize: isMobile ? 11 : 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: PremiumFadeIn(
                delay: const Duration(seconds: 1),
                child: Column(
                  children: [
                    const Text(
                      'ISTM MAHAGI • SYSTEM CONNECT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 30,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }
}
