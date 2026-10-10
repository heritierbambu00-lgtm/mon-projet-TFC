import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/core/widgets/premium_info_appbar.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/comite_entity.dart';

class CommitteePage extends ConsumerWidget {
  const CommitteePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final committeeAsync = ref.watch(committeeProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: CustomScrollView(
        slivers: [
          const PremiumInfoAppBar(
            title: 'NOS DIRIGEANTS',
            subtitle: "Le leadership de l'institution",
            bgImage: 'assets/images/slider2.jpg',
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF112240), Color(0xFF0A192F)],
                  center: Alignment.topCenter,
                  radius: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 80, horizontal: Responsive.getPadding(context)),
                child: Column(
                  children: [
                    PremiumFadeIn(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.premiumGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.premiumGold.withOpacity(0.2)),
                        ),
                        child: const Text(
                          'COMITÉ DE GESTION (COGE)',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w900,
                            color: AppColors.premiumGold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const PremiumFadeIn(
                      delay: Duration(milliseconds: 200),
                      child: Text(
                        'L\'excellence au service du futur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.white,
                          fontFamily: 'Playfair Display'
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                    committeeAsync.when(
                      data: (members) => _buildMembersGrid(context, members),
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.premiumGold)),
                      error: (e, _) => Center(child: Text("Erreur: $e", style: const TextStyle(color: Colors.redAccent))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersGrid(BuildContext context, List<ComiteEntity> members) {
    return Wrap(
      spacing: 40,
      runSpacing: 50,
      alignment: WrapAlignment.center,
      children: members.asMap().entries.map((entry) => PremiumFadeIn(
        delay: Duration(milliseconds: 100 * entry.key),
        child: _buildMemberCard(context, entry.value)
      )).toList(),
    );
  }

  Widget _buildMemberCard(BuildContext context, ComiteEntity member) {
    final bool isMobile = Responsive.isMobile(context);
    final double width = isMobile ? MediaQuery.of(context).size.width - 40 : 380;

    return Container(
      width: width,
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20)),
        ],
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.premiumGold.withOpacity(0.3), width: 2),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: AppColors.deepNavy,
              backgroundImage: (member.photoMembre.isNotEmpty && member.photoMembre.startsWith('http')) 
                  ? NetworkImage(member.photoMembre) 
                  : const AssetImage('assets/images/logo.jpg') as ImageProvider,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            member.nomComplet.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 18, 
              color: Colors.white,
              fontFamily: 'Playfair Display',
              letterSpacing: 0.5
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.premiumGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              member.fonction.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.premiumGold, fontSize: 10, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 35),
          const Divider(color: Colors.white10),
          const SizedBox(height: 25),
          const Text(
            "Leadership dévoué à la vision de l'excellence académique et au rayonnement de l'institution.",
            style: TextStyle(color: Colors.white38, height: 1.8, fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.email_outlined),
              const SizedBox(width: 25),
              _socialIcon(Icons.link_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, color: AppColors.premiumGold, size: 22),
    );
  }
}
