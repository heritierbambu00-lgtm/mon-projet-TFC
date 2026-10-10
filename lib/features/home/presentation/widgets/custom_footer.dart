import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/features/info/presentation/pages/gallery_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/admission_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/calendar_page.dart';

import 'package:istm_mahagi/features/info/presentation/pages/teachers_page.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    return Column(
      children: [
        // Newsletter Section
        Container(
          width: double.infinity,
          color: AppColors.footerBg,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 40 : 60, 
            horizontal: 20
          ),
          child: Center(
            child: Container(
              width: isMobile ? double.infinity : (isTablet ? 500 : 600),
              padding: EdgeInsets.all(isMobile ? 25 : 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'NEWSLETTER',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24, 
                      fontWeight: FontWeight.w900, 
                      color: AppColors.darkBlue,
                      letterSpacing: 2
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Inscrivez-vous pour suivre les actualités de l\'ISTM.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14, 
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Votre adresse email institutionnelle',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'S\'INSCRIRE MAINTENANT', 
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Footer
        Container(
          width: double.infinity,
          color: AppColors.footerBg,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 50 : 80, 
            horizontal: 30
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 50,
                runSpacing: 50,
                alignment: WrapAlignment.center,
                children: [
                  // Logo & About
                  SizedBox(
                    width: isMobile ? double.infinity : 300,
                    child: Column(
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.health_and_safety_rounded, color: AppColors.accentYellow, size: 45),
                            const SizedBox(width: 15),
                            const Text(
                              'ISTM MAHAGI',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Institut Supérieur des Techniques Médicales de Mahagi. Une référence en formation médicale de prestige.',
                          textAlign: isMobile ? TextAlign.center : TextAlign.start,
                          style: TextStyle(color: Colors.grey.shade400, height: 1.6),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            _socialIcon(FontAwesomeIcons.facebookF),
                            _socialIcon(FontAwesomeIcons.instagram),
                            _socialIcon(FontAwesomeIcons.xTwitter),
                            _socialIcon(FontAwesomeIcons.whatsapp),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Contacts
                  SizedBox(
                    width: isMobile ? double.infinity : 250,
                    child: Column(
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONTACTS OFFICIELS', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)
                        ),
                        const SizedBox(height: 25),
                        _contactItem(Icons.phone_rounded, '+243 814 313 997', isMobile),
                        _contactItem(Icons.email_rounded, 'info@istm-mahagi.edu', isMobile),
                        _contactItem(Icons.language_rounded, 'www.istm-mahagi.edu', isMobile),
                        _contactItem(Icons.location_on_rounded, 'RDC, Ituri, Mahagi', isMobile),
                      ],
                    ),
                  ),

                  // Useful Links
                  SizedBox(
                    width: isMobile ? double.infinity : 200,
                    child: Column(
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LIENS UTILES', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)
                        ),
                        const SizedBox(height: 25),
                        _footerLink(context, 'Application mobile', null, isMobile),
                        _footerLink(context, 'Galerie photos', const GalleryPage(), isMobile),
                        _footerLink(context, 'Processus d\'Inscription', const AdmissionPage(), isMobile),
                        _footerLink(context, 'Corps Enseignant', const TeachersPage(), isMobile),
                        _footerLink(context, 'Calendrier Académique', const CalendarPage(), isMobile),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bottom Bar
        Container(
          width: double.infinity,
          color: const Color(0xFF020617),
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: Text(
            'Copyright © 2026 Tous droits réservés | ISTM-MAHAGI • Excellence & Santé',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _contactItem(IconData icon, String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.accentYellow),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _socialIcon(dynamic icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FaIcon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _footerLink(BuildContext context, String title, Widget? page, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          }
        },
        child: Text(
          title, 
          style: TextStyle(
            color: Colors.grey.shade400, 
            fontSize: 13, 
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none
          )
        ),
      ),
    );
  }
}
