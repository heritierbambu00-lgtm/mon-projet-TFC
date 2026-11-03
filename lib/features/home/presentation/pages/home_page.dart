import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/info/presentation/pages/news_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/gallery_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/anthem_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/history_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/mission_vision_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/statutes_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/course_schedule_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/elearning_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/calendar_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/contact_page.dart';
import 'package:istm_mahagi/features/home/presentation/widgets/hero_slider.dart';
import 'package:istm_mahagi/features/home/presentation/widgets/custom_footer.dart';
import 'package:istm_mahagi/features/home/presentation/widgets/login_overlay.dart';
import 'package:istm_mahagi/features/home/presentation/providers/home_providers.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';

import '../../../info/presentation/pages/committee_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openLogin(String role) {
    ref.read(loginOverlayProvider.notifier).state = role;
  }

  void _closeLogin() {
    ref.read(loginOverlayProvider.notifier).state = null;
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = ref.watch(loginOverlayProvider);
    final showLogin = selectedRole != null;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildDrawer(),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Top Information Bars
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppColors.darkGrey,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Avez-vous une question ? +243 814 313 997',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _navigateTo(const ELearningPage()),
                              child: const Text('📚 E-Bibliothèque', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            const Text('|', style: TextStyle(color: Colors.white)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('✨ Étincelle', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Premium Sliver AppBar
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white.withOpacity(0.85),
                automaticallyImplyLeading: false,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: CircleAvatar(
                        radius: Responsive.isMobile(context) ? 18 : 22,
                        backgroundImage: const AssetImage('assets/images/logo.jpg'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ISTM MAHAGI',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                        fontSize: Responsive.isMobile(context) ? 16 : 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (Responsive.isDesktop(context))
                    Row(
                      children: [
                        _navItem('ACCUEIL', onTap: () {}),
                        _navDropdown('À PROPOS', {
                          'Galerie': const GalleryPage(),
                          'Hymne': const AnthemPage(),
                          'Historique': const HistoryPage(),
                          'Mission': const MissionVisionPage(),
                          'Statuts': const StatutesPage(),
                        }),
                        _navItem('HORAIRE', onTap: () => _navigateTo(const CourseSchedulePage())),
                        _navItem('CALENDRIER', onTap: () => _navigateTo(const CalendarPage())),
                        _navItem('E-LEARNING', onTap: () => _navigateTo(const ELearningPage())),
                        _navItem('CONTACT', onTap: () => _navigateTo(const ContactPage())),
                      ],
                    ),
                  const SizedBox(width: 10),
                  _portalButton(),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.primaryBlue, size: 30),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),

              // Hero Slider
              SliverToBoxAdapter(
                child: HeroSlider(
                  isLoginVisible: showLogin,
                  onLoginClick: _openLogin,
                ),
              ),

              // News Section
              SliverToBoxAdapter(
                child: _NewsSection(),
              ),

              // Gallery Section
              SliverToBoxAdapter(
                child: _GalleryPreviewSection(),
              ),

              // Stats Section (Prestige / Chiffres)
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final statsAsync = ref.watch(globalStatsProvider);
                    final isMobile = Responsive.isMobile(context);
                    
                    return statsAsync.when(
                      data: (stats) => Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 60 : 100, 
                          horizontal: 20
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.deepNavy,
                          image: DecorationImage(
                            image: AssetImage('assets/images/slider2.jpg'),
                            fit: BoxFit.cover,
                            opacity: 0.08,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: Column(
                              children: [
                                const _SectionHeader(
                                  subtitle: 'PRESTIGE ET EXCELLENCE',
                                  title: 'L\'Institut en Chiffres',
                                  isDark: true,
                                ),
                                const SizedBox(height: 60),
                                Wrap(
                                  spacing: 25,
                                  runSpacing: 25,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildStatCard(Icons.history_toggle_off, stats['annees']!, 'Années d\'expérience', context),
                                    _buildStatCard(Icons.school_outlined, stats['etudiants']!, 'Étudiants formés', context),
                                    _buildStatCard(Icons.account_tree_outlined, stats['departements']!, 'Départements actifs', context),
                                    _buildStatCard(Icons.verified_user_outlined, stats['homologation']!, 'Diplômes homologués', context),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.accentYellow))),
                      error: (e, _) => const SizedBox.shrink(),
                    );
                  },
                ),
              ),

              // Departments Section
              SliverToBoxAdapter(
                child: _DepartmentsSection(),
              ),

              // Values Section
              SliverToBoxAdapter(
                child: _ValuesSection(),
              ),

              // Comité (COGE) Section
              SliverToBoxAdapter(
                child: _CommitteeSection(),
              ),

              // Footer
              const SliverToBoxAdapter(
                child: Column(
                  children: [
                    _ContactQuickInfo(),
                    CustomFooter(),
                  ],
                ),
              ),
            ],
          ),
          
          if (showLogin)
            LoginOverlay(
              key: ValueKey('login_$selectedRole'),
              role: selectedRole,
              onClose: _closeLogin,
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    
    double width = 260;
    if (isMobile) {
      width = MediaQuery.of(context).size.width * 0.42;
    } else if (isTablet) {
      width = 220;
    }

    return PremiumFadeIn(
      child: Container(
        width: width,
        padding: EdgeInsets.all(isMobile ? 18 : 28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accentYellow, size: isMobile ? 24 : 32),
            ),
            const SizedBox(height: 18),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 38,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 9 : 11,
                color: Colors.white70,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String title, {VoidCallback? onTap}) {
    return TextButton(
      onPressed: onTap ?? () {},
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMain,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5
        ),
      ),
    );
  }

  Widget _navDropdown(String title, Map<String, Widget> items) {
    final Map<String, IconData> icons = {
      'Galerie': Icons.photo_library_outlined,
      'Hymne': Icons.music_note_outlined,
      'Historique': Icons.history_edu_outlined,
      'Mission': Icons.track_changes_outlined,
      'Statuts': Icons.description_outlined,
    };

    return PopupMenuButton<Widget>(
      offset: const Offset(0, 45),
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
      onSelected: (page) => _navigateTo(page),
      itemBuilder: (context) => items.entries.map((entry) {
        return _buildPopupMenuItem<Widget>(
          value: entry.value,
          icon: icons[entry.key] ?? Icons.info_outline_rounded,
          text: entry.key,
        );
      }).toList(),
    );
  }

  Widget _portalButton() {
    final bool isMobile = Responsive.isMobile(context);
    final Map<String, IconData> portalIcons = {
      'Étudiant': Icons.school_outlined,
      'Enseignant': Icons.person_outline,
      'Staff': Icons.badge_outlined,
      'Décanat': Icons.gavel_outlined,
      'Comptable': Icons.account_balance_wallet_outlined,
    };

    return PopupMenuButton<String>(
      offset: Offset(0, isMobile ? 40 : 50),
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 22, 
          vertical: isMobile ? 8 : 12
        ),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person_outlined, color: Colors.white, size: isMobile ? 16 : 18),
            SizedBox(width: isMobile ? 6 : 10),
            Text(
              'PORTAIL',
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w900, 
                fontSize: isMobile ? 11 : 13,
                letterSpacing: isMobile ? 1.0 : 1.5,
              ),
            ),
          ],
        ),
      ),
      onSelected: _openLogin,
      itemBuilder: (context) => [
        'Étudiant',
        'Enseignant',
        'Staff',
        'Décanat',
        'Comptable'
      ].map((role) => _buildPopupMenuItem<String>(
        value: role,
        icon: portalIcons[role] ?? Icons.login_rounded,
        text: role,
      )).toList(),
    );
  }

  PopupMenuItem<T> _buildPopupMenuItem<T>({required T value, required IconData icon, required String text}) {
    return PopupMenuItem<T>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 320,
      backgroundColor: Colors.white,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Premium Header
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
              image: DecorationImage(
                image: AssetImage('assets/images/slider1.jpg'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/images/logo.jpg'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'ISTM MAHAGI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'L\'EXCELLENCE MÉDICALE',
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _drawerItem(Icons.home_rounded, 'ACCUEIL', isActive: true),
                const SizedBox(height: 10),
                ExpansionTile(
                  leading: const Icon(Icons.info_rounded, color: AppColors.primaryBlue),
                  title: const Text('À PROPOS', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMain, fontSize: 14)),
                  childrenPadding: const EdgeInsets.only(left: 25),
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  children: [
                    _drawerItem(Icons.photo_library_rounded, 'Galerie', onTap: () => _navigateTo(const GalleryPage())),
                    _drawerItem(Icons.music_note_rounded, 'Hymne', onTap: () => _navigateTo(const AnthemPage())),
                    _drawerItem(Icons.history_edu_rounded, 'Historique', onTap: () => _navigateTo(const HistoryPage())),
                    _drawerItem(Icons.track_changes_rounded, 'Mission', onTap: () => _navigateTo(const MissionVisionPage())),
                    _drawerItem(Icons.description_rounded, 'Statuts', onTap: () => _navigateTo(const StatutesPage())),
                  ],
                ),
                const SizedBox(height: 5),
                _drawerItem(Icons.calendar_today_rounded, 'HORAIRE', onTap: () => _navigateTo(const CourseSchedulePage())),
                _drawerItem(Icons.event_note_rounded, 'CALENDRIER', onTap: () => _navigateTo(const CalendarPage())),
                _drawerItem(Icons.local_library_rounded, 'E-Bibliothèque', onTap: () => _navigateTo(const ELearningPage())),
                _drawerItem(Icons.health_and_safety_rounded, 'Portail Santé', onTap: () {}),
                _drawerItem(Icons.school_rounded, 'E-LEARNING', onTap: () => _navigateTo(const ELearningPage())),
                _drawerItem(Icons.alternate_email_rounded, 'CONTACT', onTap: () => _navigateTo(const ContactPage())),
                const Divider(height: 50, indent: 20, endIndent: 20),
                _drawerItem(Icons.vpn_key_rounded, 'PORTAIL', isHighlight: true, onTap: () => _openLogin('Étudiant')),
              ],
            ),
          ),
          
          // Bottom Version
          Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Text(
                  'ISTM-MAHAGI 2026',
                  style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  'Application Premium v1.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {bool isHighlight = false, bool isActive = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive 
          ? AppColors.primaryBlue.withOpacity(0.08) 
          : (isHighlight ? AppColors.accentYellow.withOpacity(0.15) : Colors.transparent),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(
          icon, 
          color: isActive ? AppColors.primaryBlue : (isHighlight ? AppColors.accentYellow.withAlpha(200) : AppColors.textMain),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primaryBlue : AppColors.textMain,
            fontWeight: isActive || isHighlight ? FontWeight.w900 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade300),
        onTap: () {
          if (onTap != null) {
            Navigator.pop(context);
            onTap();
          }
        },
      ),
    );
  }
}

class _NewsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
      color: const Color(0xFFF1F5F9), // Soft slate background
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'ACTUALITÉS ÉTUDIANTES & INSTITUTIONNELLES',
                title: 'Les Dernières de l\'Institut',
                isDark: false,
              ),
              const SizedBox(height: 50),
              newsAsync.when(
                data: (articles) {
                  if (articles.isEmpty) return const Text("Aucune actualité pour le moment.", style: TextStyle(color: AppColors.textMuted));
                  final int count = isMobile ? 1 : 3;
                  final visibleArticles = articles.take(count).toList();
                  return Column(
                    children: [
                      Wrap(
                        spacing: 30,
                        runSpacing: 30,
                        alignment: WrapAlignment.center,
                        children: visibleArticles
                            .map((article) => _newsItem(
                              context, 
                              article.title, 
                              "${article.date.day}/${article.date.month}/${article.date.year}", 
                              article.imageUrl, 
                              isMobile
                            ))
                            .toList(),
                      ),
                      const SizedBox(height: 50),
                      _buildSeeMoreButton(context, const NewsPage(), "VOIR TOUTES LES ACTUALITÉS"),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Erreur : $e", style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsItem(BuildContext context, String title, String date, String image, bool isMobile) {
    final double width = isMobile ? double.infinity : 440;

    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          width: width,
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.06),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Stack(
                  children: [
                    image.startsWith('http') 
                      ? Image.network(image, height: isMobile ? 200 : 260, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder(isMobile))
                      : Image.asset(image, height: isMobile ? 200 : 260, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder(isMobile)),
                    Positioned(
                      top: 18,
                      left: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                        ),
                        child: Text(
                          date,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: isMobile ? 17 : 22, 
                        color: AppColors.textMain,
                        fontFamily: 'Playfair Display',
                        height: 1.25
                      )
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsPage())),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LIRE LA SUITE', 
                            style: TextStyle(
                              color: AppColors.primaryBlue, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 11,
                              letterSpacing: 1.5
                            )
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryBlue),
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(bool isMobile) {
    return Container(
      height: isMobile ? 200 : 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.deepGradient,
      ),
      child: const Center(
        child: Icon(Icons.newspaper_rounded, color: Colors.white38, size: 48),
      ),
    );
  }
}

class _GalleryPreviewSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'DOCUMENTATION VISUELLE',
                title: 'L\'Institut en Images',
              ),
              const SizedBox(height: 50),
              galleryAsync.when(
                data: (items) => items.isEmpty
                    ? const Text("La galerie est vide pour le moment.", style: TextStyle(color: AppColors.textMuted))
                    : Column(
                      children: [
                        Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          alignment: WrapAlignment.center,
                          children: items.take(isMobile ? 2 : 3).map((item) => _galleryCard(
                            context,
                            item.legende,
                            "${item.date.day}/${item.date.month}/${item.date.year}",
                            item.imageUrl,
                            isMobile
                          )).toList(),
                        ),
                        const SizedBox(height: 50),
                        _buildSeeMoreButton(context, const GalleryPage(), "VOIR TOUTE LA GALERIE"),
                      ],
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Erreur : $e", style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _galleryCard(BuildContext context, String title, String date, String image, bool isMobile) {
    final double width = isMobile ? double.infinity : 480;

    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          width: width,
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Stack(
                  children: [
                    image.startsWith('http') 
                      ? Image.network(image, height: isMobile ? 210 : 300, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder(isMobile))
                      : Image.asset(image, height: isMobile ? 210 : 300, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder(isMobile)),
                    Positioned(
                      top: 18,
                      left: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                        ),
                        child: Text(
                          date,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: isMobile ? 18 : 22, 
                        color: AppColors.textMain,
                        fontFamily: 'Playfair Display',
                        height: 1.25
                      )
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryPage())),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VOIR L\'IMAGE', 
                            style: TextStyle(
                              color: AppColors.primaryBlue, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 11,
                              letterSpacing: 1.5
                            )
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryBlue),
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(bool isMobile) {
    return Container(
      height: isMobile ? 210 : 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.deepGradient,
      ),
      child: const Center(
        child: Icon(Icons.photo_library_rounded, color: Colors.white38, size: 56),
      ),
    );
  }
}

class _DepartmentsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultiesAsync = ref.watch(homeFacultiesProvider);
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
      color: const Color(0xFFF8FAFC), // Soft off-white surface
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'NOS FILIÈRES D\'EXCELLENCE',
                title: 'Programmes de Haut Niveau',
              ),
              const SizedBox(height: 60),
              facultiesAsync.when(
                data: (faculties) {
                  if (faculties.isEmpty) {
                    return const Text("Aucun domaine de formation enregistré pour le moment.", style: TextStyle(color: AppColors.textMuted));
                  }
                  return Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: faculties.map((f) => _deptCard(
                      Icons.school_rounded, 
                      f.nomFaculte, 
                      "Formation d'élite en ${f.nomFaculte} avec un encadrement académique rigoureux.",
                      isMobile
                    )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Erreur : $e", style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deptCard(IconData icon, String title, String desc, bool isMobile) {
    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          width: isMobile ? double.infinity : 380,
          constraints: const BoxConstraints(minHeight: 290, maxWidth: 420),
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.05),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: AppColors.primaryBlue, size: 28),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 20, 
                      color: AppColors.textMain,
                      fontFamily: 'Playfair Display'
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textMuted, 
                      fontSize: 14, 
                      height: 1.6,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Icon(Icons.arrow_right_alt_rounded, color: AppColors.primaryBlue, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommitteeSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final committeeAsync = ref.watch(committeeStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'COMITÉ DE GESTION (COGE)',
                title: 'Les Garants de l\'Excellence',
              ),
              const SizedBox(height: 60),
              committeeAsync.when(
                data: (members) {
                  if (members.isEmpty) return const Text("Information bientôt disponible.", style: TextStyle(color: AppColors.textMuted));
                  final visibleMembers = members.take(3).toList();
                  return Column(
                    children: [
                      Wrap(
                        spacing: 40,
                        runSpacing: 40,
                        alignment: WrapAlignment.center,
                        children: visibleMembers.map((m) => _memberCard(
                          context,
                          m.fonction, 
                          m.nomComplet, 
                          m.photoMembre,
                          isMobile
                        )).toList(),
                      ),
                      const SizedBox(height: 50),
                      _buildSeeMoreButton(context, const CommitteePage(), "VOIR TOUT LE COMITÉ"),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Erreur : $e", style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _memberCard(BuildContext context, String role, String name, String image, bool isMobile) {
    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          width: isMobile ? double.infinity : 320,
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle, 
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.08), 
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    )
                  ]
                ),
                child: CircleAvatar(
                  radius: isMobile ? 55 : 75,
                  backgroundColor: Colors.white,
                  backgroundImage: (image.isNotEmpty && image.startsWith('http')) 
                      ? NetworkImage(image) 
                      : const AssetImage('assets/images/logo.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: isMobile ? 15 : 17, 
                  color: AppColors.textMain, 
                  fontFamily: 'Playfair Display',
                  letterSpacing: 0.5
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primaryBlue, 
                    fontSize: isMobile ? 9 : 11, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommitteePage())),
                child: const Text(
                  'VOIR FICHE',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.5
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValuesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.deepNavy,
        image: DecorationImage(
          image: AssetImage('assets/images/slider3.jpg'),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'NOTRE ADN INSTITUTIONNEL',
                title: 'Des Valeurs d\'Excellence',
                isDark: true,
              ),
              const SizedBox(height: 60),
              Wrap(
                spacing: 40,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  _valueItem(Icons.verified_user_rounded, 'Rigueur Scientifique', 'Une formation médicale exigeante et de pointe basée sur le système LMD.', isMobile),
                  _valueItem(Icons.favorite_rounded, 'Éthique Humaine', 'Le respect sacré de la vie au cœur de toutes nos actions pédagogiques.', isMobile),
                  _valueItem(Icons.auto_awesome_rounded, 'Innovation', 'Une adaptation constante aux technologies médicales et de la santé.', isMobile),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _valueItem(IconData icon, String title, String desc, bool isMobile) {
    return PremiumFadeIn(
      child: Container(
        width: isMobile ? double.infinity : 350,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Icon(icon, color: AppColors.accentYellow, size: isMobile ? 32 : 44),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w900, 
                fontSize: isMobile ? 20 : 24,
                fontFamily: 'Playfair Display'
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70, 
                fontSize: isMobile ? 13 : 15, 
                height: 1.6,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.025 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}

class _ContactQuickInfo extends StatelessWidget {
  const _ContactQuickInfo();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
      color: const Color(0xFFF1F5F9), // Soft slate
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'NOUS CONTACTER',
                title: 'À Votre Écoute',
              ),
              const SizedBox(height: 60),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _infoTile(Icons.location_on_rounded, 'Localisation', 'RDC, Ituri, Ville de Mahagi', isMobile),
                  _infoTile(Icons.phone_rounded, 'Ligne Directe', '+243 814 313 997', isMobile),
                  _infoTile(Icons.alternate_email_rounded, 'Email Officiel', 'info@istm-mahagi.edu', isMobile),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value, bool isMobile) {
    return PremiumFadeIn(
      child: Container(
        width: isMobile ? double.infinity : 350,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 28),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final bool isDark;

  const _SectionHeader({
    required this.subtitle,
    required this.title,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        PremiumFadeIn(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.accentYellow : AppColors.primaryBlue).withOpacity(0.12),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              subtitle.toUpperCase(),
              style: TextStyle(
                fontSize: isMobile ? 10 : 11,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.accentYellow : AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PremiumFadeIn(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textMain,
              fontFamily: 'Playfair Display',
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 14),
        PremiumFadeIn(
          child: Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.goldGradient : AppColors.premiumGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildSeeMoreButton(BuildContext context, Widget target, String label) {
  return PremiumFadeIn(
    child: ElevatedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: AppColors.primaryBlue.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
