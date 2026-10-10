import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'CONTACTEZ-NOUS',
            subtitle: "À votre entière disposition",
            icon: Icons.alternate_email_rounded,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Responsive.getPadding(context)),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: !isMobile 
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: PremiumFadeIn(child: _buildContactInfoCard())),
                              const SizedBox(width: 40),
                              Expanded(child: PremiumFadeIn(delay: const Duration(milliseconds: 200), child: _buildMessageFormCard())),
                            ],
                          )
                        : Column(
                            children: [
                              PremiumFadeIn(child: _buildContactInfoCard()),
                              const SizedBox(height: 40),
                              PremiumFadeIn(delay: const Duration(milliseconds: 200), child: _buildMessageFormCard()),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  PremiumFadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: _buildMapSection()
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04), 
            blurRadius: 40, 
            offset: const Offset(0, 20)
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          _infoItem(Icons.location_on_rounded, 'Notre Adresse',
              'RDC, Ituri, Ville de Mahagi\nProvince de l\'Ituri'),
          _infoItem(Icons.phone_iphone_rounded, 'Téléphone',
              'Secrétariat : +243 814 313 997\nApparitorat : +243 994 345 975'),
          _infoItem(Icons.email_rounded, 'Email Officiel',
              'info@istm-mahagi.edu\nrectorat@istm-mahagi.edu'),
          _infoItem(Icons.access_time_filled_rounded, 'Heures d\'ouverture',
              'Lun - Ven : 08h00 - 16h00\nSamedi : 08h00 - 12h00'),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.textMain,
                    fontFamily: 'Playfair Display'
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(color: AppColors.textMuted, height: 1.6, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFormCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.1), 
            blurRadius: 40, 
            offset: const Offset(0, 20)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Écrivez-nous',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Playfair Display'
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Votre message sera traité en priorité.',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
          const SizedBox(height: 40),
          _inputGroup('Nom Complet', 'Ex: Jean Mukala'),
          _inputGroup('Email Institutionnel', 'votre@email.com'),
          _inputGroup('Message', 'Comment pouvons-nous vous aider ?', maxLines: 5),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumGold,
                foregroundColor: AppColors.deepNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
              child: const Text('ENVOYER LE MESSAGE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputGroup(String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.accentYellow, letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          TextField(
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14, fontWeight: FontWeight.normal),
              contentPadding: const EdgeInsets.all(20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Stack(
            children: [
              Image.asset('assets/images/slider2.jpg', width: double.infinity, height: double.infinity, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.2)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 20)]),
                      child: const Icon(Icons.map_rounded, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'LOCALISATION SUR LA CARTE',
                      style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    const Text('Mahagi, Avenue de l\'Excellence, RDC', style: TextStyle(color: AppColors.textMuted)),
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
