import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/domain/entities/enseignant_entity.dart';

class TeachersPage extends ConsumerWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'CORPS ENSEIGNANT',
            subtitle: "L'élite académique de l'ISTM",
            bgImage: 'assets/images/slider3.jpg',
          ),
          teachersAsync.when(
            data: (list) => list.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: Text("Aucun enseignant enregistré pour le moment.")),
                  )
                : SliverPadding(
                    padding: EdgeInsets.all(Responsive.getPadding(context)),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 2 : 1),
                        mainAxisSpacing: 30,
                        crossAxisSpacing: 30,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => PremiumFadeIn(
                          delay: Duration(milliseconds: 100 * index),
                          child: _buildTeacherCard(list[index]),
                        ),
                        childCount: list.length,
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(EnseignantEntity ens) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04), 
            blurRadius: 40, 
            offset: const Offset(0, 20)
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.premiumGold.withOpacity(0.3), width: 1),
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryBlue.withOpacity(0.15), blurRadius: 20),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: (ens.photoEns != 'default.jpg' && ens.photoEns.startsWith('http'))
                      ? Image.network(ens.photoEns, fit: BoxFit.cover)
                      : Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            '${ens.nomEns} ${ens.postnomEns}'.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              color: AppColors.textMain,
              fontFamily: 'Playfair Display'
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              ens.specialite.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryBlue, 
                fontWeight: FontWeight.w900, 
                fontSize: 10,
                letterSpacing: 1
              ),
            ),
          ),
          const Spacer(),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.premiumGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ens.emailPro,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
