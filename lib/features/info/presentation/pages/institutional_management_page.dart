import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'history_management_page.dart';
import 'mission_vision_management_page.dart';
import 'committee_management_page.dart';
import 'anthem_management_page.dart';
import 'statutes_management_page.dart';
import 'gallery_management_page.dart';
import 'news_management_page.dart';

class InstitutionalManagementPage extends StatelessWidget {
  const InstitutionalManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    const Color goldAccent = Color(0xFFC5A059);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('GESTION INSTITUTIONNELLE', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: goldAccent, fontFamily: 'Playfair Display', letterSpacing: 1)),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: goldAccent),
        shape: Border(bottom: BorderSide(color: goldAccent.withOpacity(0.1))),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF112240), Color(0xFF0A192F)],
            center: Alignment.topCenter,
            radius: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PremiumFadeIn(
                child: Text('CONSOLE D\'ÉDITION DE CONTENU (CMS)', 
                  style: TextStyle(color: goldAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 3)),
              ),
              const SizedBox(height: 35),
              _buildGrid(context, isMobile),
              const SizedBox(height: 60),
              _buildFooterInfo(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 1 : 4,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: isMobile ? 2.8 : 1.3,
      children: [
        _buildCompactCard(context, 'Historique', Icons.history_edu_rounded, Colors.orange, const HistoryManagementPage()),
        _buildCompactCard(context, 'Mission', Icons.track_changes_rounded, Colors.blue, const MissionVisionManagementPage()),
        _buildCompactCard(context, 'Comité', Icons.groups_3_rounded, Colors.teal, const CommitteeManagementPage()),
        _buildCompactCard(context, 'Actualités', Icons.newspaper_rounded, Colors.redAccent, const NewsManagementPage()),
        _buildCompactCard(context, 'Hymne', Icons.music_note_rounded, Colors.purple, const AnthemManagementPage()),
        _buildCompactCard(context, 'Statuts', Icons.gavel_rounded, Colors.blueGrey, const StatutesManagementPage()),
        _buildCompactCard(context, 'Galerie', Icons.photo_library_rounded, Colors.amber, const GalleryManagementPage()),
      ],
    );
  }

  Widget _buildCompactCard(BuildContext context, String title, IconData icon, Color color, Widget targetPage) {
    return PremiumFadeIn(
      child: _HoverScaleWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF112240),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage)),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(height: 20),
                    Text(title, 
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w900, 
                        fontSize: 14, 
                        letterSpacing: 0.5, 
                        fontFamily: 'Playfair Display'
                      )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.premiumGold.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.premiumGold, size: 24),
              ),
              const SizedBox(width: 25),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INTÉGRITÉ DU CONTENU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 5),
                    Text(
                      'Toute modification effectuée ici est répercutée en temps réel sur le site public et l\'application mobile des étudiants.',
                      style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            _smallInfoCard(Icons.security_rounded, "SÉCURISÉ", Colors.green),
            const SizedBox(width: 15),
            _smallInfoCard(Icons.cloud_done_rounded, "CLOUD SYNC", Colors.blue),
            const SizedBox(width: 15),
            _smallInfoCard(Icons.history_rounded, "LOGS", Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _smallInfoCard(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF112240),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 18),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _HoverScaleWrapper extends StatefulWidget {
  final Widget child;
  const _HoverScaleWrapper({required this.child});

  @override
  State<_HoverScaleWrapper> createState() => _HoverScaleWrapperState();
}

class _HoverScaleWrapperState extends State<_HoverScaleWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
