import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';

class FacultiesPage extends StatelessWidget {
  const FacultiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'NOS FACULTÉS',
            subtitle: "Domaines de formation d'élite",
            icon: Icons.school_rounded,
          ),
          SliverPadding(
            padding: EdgeInsets.all(Responsive.getPadding(context)),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.isDesktop(context) ? 3 : (Responsive.isTablet(context) ? 2 : 1),
                mainAxisSpacing: 30,
                crossAxisSpacing: 30,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildListDelegate([
                _buildFacultyCard(
                  Icons.local_hospital_rounded,
                  'SCIENCES INFIRMIÈRES',
                  'Soins Généraux, Pédiatrie, Chirurgie, Enseignement et Administration.',
                  ['L1, L2, L3 (Graduat)', 'M1, M2 (Licence LMD)'],
                  0,
                ),
                _buildFacultyCard(
                  Icons.biotech_rounded,
                  'TECHNIQUES DE LABO',
                  'Analyses biomédicales, Parasitologie, Microbiologie, Biochimie.',
                  ['L1, L2, L3 (Graduat)', 'Spécialisation Biotechnologie'],
                  1,
                ),
                _buildFacultyCard(
                  Icons.family_restroom_rounded,
                  'SAGE-FEMME',
                  'Obstétrique, Soins néonataux, Santé de la reproduction.',
                  ['L1, L2, L3 (Graduat)'],
                  2,
                ),
                _buildFacultyCard(
                  Icons.health_and_safety_rounded,
                  'SANTÉ PUBLIQUE',
                  'Épidémiologie, Nutrition, Gestion des services de santé.',
                  ['L1, L2, L3 (Graduat)', 'Master en Santé Publique'],
                  3,
                ),
                _buildFacultyCard(
                  Icons.healing_rounded,
                  'KINÉSITHÉRAPIE',
                  'Rééducation physique, Physiothérapie, Réadaptation.',
                  ['L1, L2, L3 (Graduat)'],
                  4,
                ),
                _buildFacultyCard(
                  Icons.medication_liquid_rounded,
                  'PHARMACIE',
                  'Officine, Pharmacologie, Gestion des stocks médicaux.',
                  ['L1, L2, L3 (Graduat)'],
                  5,
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  Widget _buildFacultyCard(IconData icon, String title, String desc, List<String> levels, int index) {
    return PremiumFadeIn(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 32),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 18, 
                color: AppColors.textMain,
                fontFamily: 'Playfair Display',
                letterSpacing: 0.5
              ),
            ),
            const SizedBox(height: 15),
            Text(
              desc,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 15),
            const Text(
              'CURSUS DISPONIBLES',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: AppColors.premiumGold, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: levels.map((l) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l, 
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMain)
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
