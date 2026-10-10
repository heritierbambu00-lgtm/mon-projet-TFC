import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/student_schedule_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/student_courses_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/student_results_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/student_finance_page.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import 'package:istm_mahagi/features/social/presentation/pages/chat_page.dart';
import 'package:istm_mahagi/features/dashboard/presentation/pages/student_situation_page.dart';
import 'package:istm_mahagi/features/auth/presentation/pages/student_card_page.dart';
import 'package:istm_mahagi/features/auth/presentation/pages/profile_page.dart';
import 'package:istm_mahagi/features/dashboard/presentation/widgets/sidebar_menu.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showSplash = true;
  bool isSidebarExpanded = true;

  void _closeSplash() => setState(() => showSplash = false);
  void _toggleSidebar() => setState(() => isSidebarExpanded = !isSidebarExpanded);

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final promosAsync = ref.watch(promotionsProvider);
    final bool isMobile = Responsive.isMobile(context);

    return userAsync.when(
      data: (user) {
        if (user == null || user is! EtudiantEntity) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final String civilite = user.sexe == 'M' ? "Monsieur" : "Mademoiselle";
        final String nomComplet = "${user.prenomEtu} ${user.nomEtu} ${user.postnomEtu}";

        return promosAsync.when(
          data: (promos) {
            final promo = promos.where((p) => p.stableId == user.idPromo).firstOrNull;
            final String promoLabel = promo?.nomPromo ?? "Promotion ${user.idPromo}";

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.surface,
              drawer: isMobile ? _buildMobileDrawer(user, promoLabel) : null,
              body: Stack(
                children: [
                  Row(
                    children: [
                      if (!isMobile)
                        SidebarMenu(
                          isExpanded: isSidebarExpanded,
                          onToggle: _toggleSidebar,
                          userName: user.nomEtu,
                          roleTitle: 'Étudiant',
                          photoUrl: user.photoProfil,
                          customItems: _getMenuActions(context),
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            if (isMobile) 
                              Container(color: Colors.white, height: MediaQuery.of(context).padding.top),
                            _buildTopNavbar(isMobile, context, civilite, user.nomEtu, promoLabel),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.getPadding(context), 
                                  vertical: isMobile ? 20 : 30
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PremiumFadeIn(child: _buildWelcomeHeader(user, civilite, promoLabel)),
                                    const SizedBox(height: 25),
                                    PremiumFadeIn(
                                      delay: const Duration(milliseconds: 200),
                                      child: _buildShortcutGrid()
                                    ),
                                    const SizedBox(height: 30),
                                    PremiumFadeIn(
                                      delay: const Duration(milliseconds: 400),
                                      child: _buildInfoCard(user, promoLabel)
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showSplash)
                    _buildWelcomeSplash(user, civilite, nomComplet, promoLabel),
                ],
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Erreur promos: $e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }

  List<SidebarItem> _getMenuActions(BuildContext context) {
    return [
      SidebarItem(
        icon: Icons.person_outline_rounded, 
        title: 'Mon Profil',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
      ),
      SidebarItem(
        icon: Icons.book_outlined, 
        title: 'Mes Cours',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentCoursesPage())),
      ),
      SidebarItem(
        icon: Icons.access_time_rounded, 
        title: 'Horaires',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentSchedulePage())),
      ),
      SidebarItem(
        icon: Icons.account_balance_wallet_outlined, 
        title: 'Finance & Solde',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFinancePage())),
      ),
      SidebarItem(
        icon: Icons.analytics_outlined, 
        title: 'Mes Résultats',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentResultsPage())),
      ),
      SidebarItem(
        icon: Icons.badge_outlined, 
        title: 'Carte Étudiant',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentCardPage())),
      ),
      SidebarItem(
        icon: Icons.forum_outlined, 
        title: 'Forum Sciences',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
      ),
    ];
  }

  Widget _buildMobileDrawer(EtudiantEntity user, String promoLabel) {
    return Drawer(
      backgroundColor: AppColors.deepNavy,
      child: SidebarMenu(
        isExpanded: true,
        onToggle: () {},
        userName: user.nomEtu,
        roleTitle: 'Étudiant',
        photoUrl: user.photoProfil,
        customItems: _getMenuActions(context),
      ),
    );
  }

  Widget _buildTopNavbar(bool isMobile, BuildContext context, String civilite, String nom, String promo) {
    return Container(
      height: isMobile ? 110 : 100,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 35),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
        border: const Border(bottom: BorderSide(color: AppColors.premiumGold, width: 2)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (isMobile)
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.premiumGold.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.menu_rounded, color: AppColors.accentYellow, size: 24),
                ),
              )
            else
              IconButton(
                icon: Icon(isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded, color: Colors.white, size: 28),
                onPressed: _toggleSidebar,
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESPACE ÉTUDIANT SÉCURISÉ', 
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      color: AppColors.premiumGold.withOpacity(0.8), 
                      letterSpacing: 2.5, 
                      fontSize: 9
                    )
                  ),
                  Text(
                    promo.toUpperCase(), 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 0.5,
                      fontFamily: 'Playfair Display'
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppColors.accentYellow, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(EtudiantEntity user, String civilite, String promo) {
    final bool isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heureux de vous revoir,',
          style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600, color: AppColors.textMuted),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            user.nomEtu.toUpperCase(),
            style: TextStyle(
              fontSize: isMobile ? 32 : 42, 
              fontWeight: FontWeight.w900, 
              color: AppColors.deepNavy, 
              fontFamily: 'Playfair Display',
              letterSpacing: -1
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08), 
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                isMobile ? 'Inscrit en $promo' : 'Session Académique 2026 • $promo',
                style: const TextStyle(color: AppColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = Responsive.isMobile(context);
      final bool isTablet = Responsive.isTablet(context);
      
      int count = 3;
      double aspectRatio = 3.2;

      if (isMobile) {
        count = 2; 
        aspectRatio = 1.0; // Increased height to prevent bottom overflow
      } else if (isTablet) {
        count = 2;
        aspectRatio = 2.8;
      }
      
      final shortcuts = [
        {'title': 'Profil', 'color': AppColors.deepNavy, 'icon': Icons.person_outline_rounded, 'page': const ProfilePage()},
        {'title': 'Cours', 'color': const Color(0xFF2563EB), 'icon': Icons.book_rounded, 'page': const StudentCoursesPage()},
        {'title': 'Horaires', 'color': const Color(0xFF10B981), 'icon': Icons.access_time_filled_rounded, 'page': const StudentSchedulePage()},
        {'title': 'Résultats', 'color': const Color(0xFFD97706), 'icon': Icons.analytics_rounded, 'page': const StudentResultsPage()},
        {'title': 'Finance', 'color': const Color(0xFFDC2626), 'icon': Icons.account_balance_wallet_rounded, 'page': const StudentFinancePage()},
        {'title': 'Carte', 'color': const Color(0xFF7C3AED), 'icon': Icons.badge_rounded, 'page': const StudentCardPage()},
      ];

      return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: aspectRatio,
        ),
        itemCount: shortcuts.length,
        itemBuilder: (context, index) {
          final s = shortcuts[index];
          return _shortcutCard(
            s['title'] as String, 
            s['color'] as Color, 
            s['icon'] as IconData,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => s['page'] as Widget)),
            isMobile
          );
        },
      );
    });
  }

  Widget _shortcutCard(String title, Color color, IconData icon, VoidCallback onTap, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04), 
            blurRadius: 20, 
            offset: const Offset(0, 8)
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: isMobile 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08), 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 9, 
                        color: AppColors.deepNavy, 
                        letterSpacing: 1
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.deepNavy, letterSpacing: 0.5),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(EtudiantEntity user, String promo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: AppColors.deepGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppColors.deepNavy.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, size: 40, color: AppColors.accentYellow),
          ),
          const SizedBox(height: 25),
          Text(
            'PRÊT POUR L\'EXCELLENCE ?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: Colors.white, 
              fontFamily: 'Playfair Display',
              letterSpacing: 1
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Accédez instantanément à vos ressources pédagogiques de $promo et suivez votre progression académique.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSplash(EtudiantEntity user, String civilite, String nomComplet, String promoLabel) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return InkWell(
      onTap: _closeSplash,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: isMobile ? size.width * 0.85 : 480,
                padding: EdgeInsets.all(isMobile ? 35 : 55),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(isMobile ? 40 : 50),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 50)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('BIENVENUE', 
                      style: TextStyle(color: AppColors.deepNavy, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 5)),
                    const SizedBox(height: 15),
                    Text('À L\'ISTM MAHAGI', 
                      style: TextStyle(color: AppColors.deepNavy, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Playfair Display')),
                    const SizedBox(height: 35),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 20)]),
                      child: CircleAvatar(
                        radius: isMobile ? 50 : 65,
                        backgroundColor: Colors.white,
                        backgroundImage: const AssetImage('assets/images/logo.jpg'),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text(civilite.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(nomComplet.toUpperCase(), textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w900, color: AppColors.deepNavy, fontFamily: 'Playfair Display')),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2))
                      ),
                      child: Text(promoLabel.toUpperCase(), style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 45),
                    const Text('TOUCHEZ POUR ACCÉDER AU PORTAIL', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
