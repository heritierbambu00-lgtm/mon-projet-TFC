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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchOpen = false;

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
              // Top Information Bar (Modèle UAC)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF2D3E50),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Avez-vous une question ? +243 994 345 975',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          if (!Responsive.isMobile(context))
                            Row(
                              children: [
                                _headerTopLink('Alumni', 'https://alumni.uaconline.edu.cd/public/'),
                                const Text(' | ', style: TextStyle(color: Colors.white38)),
                                _headerTopLink('Mail Pro', 'https://webmail.extrahoster.com/'),
                                const Text(' | ', style: TextStyle(color: Colors.white38)),
                                _headerTopLink('Portail Étudiant', () => _openLogin('Étudiant')),
                                const Text(' | ', style: TextStyle(color: Colors.white38)),
                                _headerTopLink('Portail Enseignant', () => _openLogin('Enseignant')),
                              ],
                            ),
                        ],
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
                              child: const Text('📚 Bibliothèque Numérique', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const Text('|', style: TextStyle(color: Colors.white70)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('✨ Revue Étincelle', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Navigation Header
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                elevation: 2,
                backgroundColor: Colors.white.withOpacity(0.95),
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
                          'Alumni': const NewsPage(),
                          'Galerie photos': const GalleryPage(),
                          'Personnel': const CommitteePage(),
                          'Calendrier': const CalendarPage(),
                          'Hymne': const AnthemPage(),
                          'Historique': const HistoryPage(),
                          'Mission et Vision': const MissionVisionPage(),
                          'Statuts': const StatutesPage(),
                        }),
                        _navItem('HORAIRE', onTap: () => _navigateTo(const CourseSchedulePage())),
                        _navDropdown('DOMAINE', {
                          'Sciences de l\'Homme et de la Société': const ELearningPage(),
                          'Sciences Economiques et de Gestion': const ELearningPage(),
                          'Sciences Agronomiques et Environnement': const ELearningPage(),
                          'Sciences et Technologie': const ELearningPage(),
                          'Sciences Psychologiques de l\'Education': const ELearningPage(),
                        }),
                        _navDropdown('E-LEARNING', {
                          'Portail Enseignant': const ELearningPage(),
                          'Portail Etudiant': const ELearningPage(),
                        }),
                        _navDropdown('INTRANET', {
                          'Décanat': const ELearningPage(),
                          'Staff': const ELearningPage(),
                        }),
                        _navItem('CONTACT', onTap: () => _navigateTo(const ContactPage())),
                      ],
                    ),
                  IconButton(
                    icon: Icon(_isSearchOpen ? Icons.close : Icons.search_rounded, color: AppColors.primaryBlue),
                    onPressed: () => setState(() => _isSearchOpen = !_isSearchOpen),
                  ),
                  const SizedBox(width: 5),
                  _portalButton(),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.primaryBlue, size: 30),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),

              // Search Overlay Bar
              if (_isSearchOpen)
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF2D3E50),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Rechercher sur le site (cours, actualités, événements)...',
                            hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: AppColors.accentYellow),
                              onPressed: () {},
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Hero Slider / Carousel
              SliverToBoxAdapter(
                child: HeroSlider(
                  isLoginVisible: showLogin,
                  onLoginClick: _openLogin,
                ),
              ),

              // Quick Action Buttons Bar (4 Buttons like Reference Site)
              SliverToBoxAdapter(
                child: _QuickButtonsBar(),
              ),

              // Annonce Section (Modèle UAC - Fond sombre)
              SliverToBoxAdapter(
                child: _AnnouncementSection(),
              ),

              // Nouvelles Récentes Section
              SliverToBoxAdapter(
                child: _NewsSection(),
              ),

              // Gallery Strip Section (Défilé Photos)
              SliverToBoxAdapter(
                child: _GalleryBannerStrip(),
              ),

              // Stats Section (L'Institut en Chiffres)
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final statsAsync = ref.watch(globalStatsProvider);
                    final isMobile = Responsive.isMobile(context);
                    
                    return statsAsync.when(
                      data: (stats) => Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 90, horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D3E50),
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
                                const SizedBox(height: 50),
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

              // Domains / Nos Domaines Section
              SliverToBoxAdapter(
                child: _DomainsSection(),
              ),

              // Committee Section (Membres du COGE)
              SliverToBoxAdapter(
                child: _CommitteeSection(),
              ),

              // Values Section
              SliverToBoxAdapter(
                child: _ValuesSection(),
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

  Widget _headerTopLink(String text, dynamic target) {
    return InkWell(
      onTap: () {
        if (target is Widget) _navigateTo(target);
        if (target is Function) target();
      },
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
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
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
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
          fontSize: 12,
          letterSpacing: 0.5
        ),
      ),
    );
  }

  Widget _navDropdown(String title, Map<String, Widget> items) {
    return PopupMenuButton<Widget>(
      offset: const Offset(0, 45),
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
      onSelected: (page) => _navigateTo(page),
      itemBuilder: (context) => items.entries.map((entry) {
        return PopupMenuItem<Widget>(
          value: entry.value,
          child: Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        );
      }).toList(),
    );
  }

  Widget _portalButton() {
    final bool isMobile = Responsive.isMobile(context);

    return PopupMenuButton<String>(
      offset: Offset(0, isMobile ? 40 : 50),
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 18, 
          vertical: isMobile ? 8 : 10
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3E50),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, color: Colors.white, size: isMobile ? 16 : 18),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              'PORTAIL',
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w900, 
                fontSize: isMobile ? 11 : 12,
                letterSpacing: 1.0,
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
      ].map((role) => PopupMenuItem<String>(
        value: role,
        child: Text(role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      )).toList(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 320,
      backgroundColor: Colors.white,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2D3E50),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.jpg'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ISTM MAHAGI',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 2),
                  ),
                  const Text(
                    'L\'EXCELLENCE MÉDICALE',
                    style: TextStyle(color: AppColors.accentYellow, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3),
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
                  childrenPadding: const EdgeInsets.only(left: 20),
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  children: [
                    _drawerItem(Icons.photo_library_rounded, 'Galerie photos', onTap: () => _navigateTo(const GalleryPage())),
                    _drawerItem(Icons.music_note_rounded, 'Hymne', onTap: () => _navigateTo(const AnthemPage())),
                    _drawerItem(Icons.history_edu_rounded, 'Historique', onTap: () => _navigateTo(const HistoryPage())),
                    _drawerItem(Icons.track_changes_rounded, 'Mission et Vision', onTap: () => _navigateTo(const MissionVisionPage())),
                    _drawerItem(Icons.description_rounded, 'Statuts', onTap: () => _navigateTo(const StatutesPage())),
                  ],
                ),
                _drawerItem(Icons.alarm_rounded, 'HORAIRE', onTap: () => _navigateTo(const CourseSchedulePage())),
                _drawerItem(Icons.event_note_rounded, 'CALENDRIER', onTap: () => _navigateTo(const CalendarPage())),
                _drawerItem(Icons.local_library_rounded, 'E-Bibliothèque', onTap: () => _navigateTo(const ELearningPage())),
                _drawerItem(Icons.school_rounded, 'E-LEARNING', onTap: () => _navigateTo(const ELearningPage())),
                _drawerItem(Icons.alternate_email_rounded, 'CONTACT', onTap: () => _navigateTo(const ContactPage())),
                const Divider(height: 40, indent: 20, endIndent: 20),
                _drawerItem(Icons.vpn_key_rounded, 'PORTAIL', isHighlight: true, onTap: () => _openLogin('Étudiant')),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('ISTM-MAHAGI 2026', style: TextStyle(color: Color(0xFF2D3E50), fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Tous droits réservés', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: isActive ? AppColors.primaryBlue : (isHighlight ? AppColors.accentYellow : AppColors.textMain), size: 20),
        title: Text(title, style: TextStyle(color: isActive ? AppColors.primaryBlue : AppColors.textMain, fontWeight: isActive || isHighlight ? FontWeight.w900 : FontWeight.w600, fontSize: 13)),
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

class _QuickButtonsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 25 : 35, horizontal: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Wrap(
            spacing: 20,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: [
              _quickButton('Alumni', isMobile),
              _quickButton('CIAQ', isMobile),
              _quickButton('Bibliothèque numérique', isMobile),
              _quickButton('Étincelle', isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickButton(String title, bool isMobile) {
    return Container(
      width: isMobile ? (150) : 220,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF2D3E50),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ),
    );
  }
}

class _AnnouncementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFF2D3E50),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 50 : 80, horizontal: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text(
                'Annonce',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Playfair Display'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)],
                ),
                child: const Text(
                  'DÉBUT EFFECTIF DES COURS À L’ISTM MAHAGI',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 35),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  'À l’ensemble de la communauté estudiantine de notre Alma Mater, l’ISTM Mahagi.\n\n'
                  'Nous vous rappelons que les enseignements débutent effectivement ce lundi 02 novembre 2026 dans toutes les promotions de l’ISTM Mahagi.\n\n'
                  'Vous êtes invités à consulter le site web et l\'application mobile de l’institution afin de prendre connaissance des horaires des cours et des auditoires attribués à vos promotions respectives.\n\n'
                  'Nous comptons sur votre présence, votre ponctualité et votre engagement dès le premier jour des enseignements.\n\n'
                  'Bon début de cours à toutes et à tous !',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: isMobile ? 13 : 15, height: 1.7, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);

    // Actualités Référence UAC
    final List<Map<String, String>> referenceNews = [
      {
        'title': 'ISTM Mahagi : Nomination des membres du personnel technique et ouvrier pour l’année 2026-2027...',
        'date': '02 Nov',
        'time': '10:52:15',
        'location': 'Cabinet du Recteur',
        'image': 'https://uaconline.edu.cd/imagenews/NN18.jpeg',
      },
      {
        'title': 'Rectorat : Affectation des autorités décanales pour l’année académique 2026-2027...',
        'date': '02 Nov',
        'time': '10:48:50',
        'location': 'Cabinet du Recteur',
        'image': 'https://uaconline.edu.cd/imagenews/NN14.jpeg',
      },
      {
        'title': 'Encadrements pédagogiques : Des Alumni transmettent le flambeau de l’expérience aux jeunes étudiants...',
        'date': '02 Nov',
        'time': '10:46:39',
        'location': 'Cabinet du Recteur',
        'image': 'https://uaconline.edu.cd/imagenews/NN11.jpeg',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 90, horizontal: 20),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'ACTUALITÉS ÉTUDIANTES & INSTITUTIONNELLES',
                title: 'Nouvelles Récentes',
                isDark: false,
              ),
              const SizedBox(height: 50),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: referenceNews
                    .map((article) => _newsItem(
                      context, 
                      article['title']!, 
                      article['date']!, 
                      article['time']!, 
                      article['location']!, 
                      article['image']!, 
                      isMobile
                    ))
                    .toList(),
              ),
              const SizedBox(height: 50),
              _buildSeeMoreButton(context, const NewsPage(), "VOIR TOUTES LES ACTUALITÉS"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsItem(BuildContext context, String title, String date, String time, String location, String image, bool isMobile) {
    final double width = isMobile ? double.infinity : 370;

    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          width: width,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      image, 
                      height: isMobile ? 200 : 240, 
                      width: double.infinity, 
                      fit: BoxFit.cover, 
                      errorBuilder: (_, __, ___) => Container(
                        height: isMobile ? 200 : 240,
                        color: const Color(0xFF2D3E50),
                        child: const Center(child: Icon(Icons.newspaper, color: Colors.white38, size: 48)),
                      )
                    ),
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                        ),
                        child: Text(
                          date,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: isMobile ? 16 : 18, 
                        color: AppColors.textMain,
                        fontFamily: 'Playfair Display',
                        height: 1.3
                      )
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 5),
                        Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 15),
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 5),
                        Expanded(child: Text(location, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsPage())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3E50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('LIRE PLUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
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
}

class _GalleryBannerStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final List<String> galleryImages = [
      'https://uaconline.edu.cd/imagegalerie/rentreeacademique9.JPG',
      'https://uaconline.edu.cd/imagegalerie/rentreeacademique8.JPG',
      'https://uaconline.edu.cd/imagegalerie/rentreeacademique7.JPG',
      'https://uaconline.edu.cd/imagegalerie/rentreeacademique6.JPG',
      'https://uaconline.edu.cd/imagegalerie/rentreeacademique5.JPG',
      'https://uaconline.edu.cd/imagegalerie/rentreeacademique3.JPG',
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF2D3E50),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const Text('GALERIE EN IMAGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2)),
              const SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: galleryImages.map((img) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryPage())),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
                        ),
                        child: CircleAvatar(
                          radius: isMobile ? 45 : 65,
                          backgroundImage: NetworkImage(img),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DomainsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final List<Map<String, String>> domains = [
      {
        'id': 'SHS',
        'title': 'Sciences de l\'Homme et de la Société',
        'email': 'schommeetsociete@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagedomaine/lettres.jpg',
      },
      {
        'id': 'SEG',
        'title': 'Sciences Economiques et de Gestion',
        'email': 'sceconomiquesetgestion@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagedomaine/economie.jpg',
      },
      {
        'id': 'SAE',
        'title': 'Sciences Agronomiques et Environnement',
        'email': 'scdeveloppement@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagedomaine/developpement.jpg',
      },
      {
        'id': 'ST',
        'title': 'Sciences et Technologie',
        'email': 'scpolytechnique@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagedomaine/polytechnique.jpg',
      },
      {
        'id': 'SPE',
        'title': 'Sciences Psychologiques de l\'Education',
        'email': 'scpsychologiques@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagedomaine/psychologie.jpg',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 90, horizontal: 20),
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'ORGANISATION ACADÉMIQUE LMD',
                title: 'NOS DOMAINES',
              ),
              const SizedBox(height: 15),
              const Text(
                'L\'ISTM Mahagi organise 5 domaines principaux d\'enseignement. Dans chaque domaine, il y a les différentes filières de formation d\'élite. Cliquez afin de lire le détail.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: domains.map((d) => _domainCard(context, d['title']!, d['email']!, d['image']!, isMobile)).toList(),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3E50),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)],
                ),
                child: const Text(
                  'Noverim Me Noverim Te >>>',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _domainCard(BuildContext context, String title, String email, String image, bool isMobile) {
    final double width = isMobile ? double.infinity : 370;

    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          width: width,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  image, 
                  height: 200, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 200, color: const Color(0xFF2D3E50), child: const Icon(Icons.school, color: Colors.white38, size: 48)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textMain, fontFamily: 'Playfair Display')
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email, 
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3E50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('LIRE PLUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
}

class _CommitteeSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);

    final List<Map<String, String>> cogeMembers = [
      {
        'name': 'Dr. KAVULA MAWAZO Sikirivwa, PhD',
        'title': 'Professeur Associé',
        'role': 'Recteur',
        'email': 'rectorat@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagecoge/mawazo.jpg',
      },
      {
        'name': 'Dr. KANYORORO KISALI Jean-Chrysostome, PhD',
        'title': 'Professeur',
        'role': 'Secrétaire Général Académique',
        'email': 'academique@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagecoge/kanyororo.jpg',
      },
      {
        'name': 'Dr. KASEREKA KIBANDA Wilfrid, PhD',
        'title': 'Professeur',
        'role': 'Secrétaire Général de Recherche',
        'email': 'contact@ishango-uac.net',
        'image': 'https://uaconline.edu.cd/imagecoge/kibanda.jpg',
      },
      {
        'name': 'Dr. PALUKU KAMILI Jean-Paul, PhD',
        'title': 'Professeur Associé',
        'role': 'Secrétaire Général Administratif',
        'email': 'administratif@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagecoge/kamili.jpg',
      },
      {
        'name': 'Ir. KATEMBO KASOLENE Moïse',
        'title': 'Assistant Deux',
        'role': 'Administrateur de Budget',
        'email': 'administeur.budget@uaconline.edu.cd',
        'image': 'https://uaconline.edu.cd/imagecoge/kasolene.jpg',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 90, horizontal: 20),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'AUTORITÉS INSTITUTIONNELLES',
                title: 'Membres du COGE',
              ),
              const SizedBox(height: 50),
              Wrap(
                spacing: 25,
                runSpacing: 25,
                alignment: WrapAlignment.center,
                children: cogeMembers.map((m) => _memberCard(
                  m['name']!, 
                  m['title']!, 
                  m['role']!, 
                  m['email']!, 
                  m['image']!, 
                  isMobile
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _memberCard(String name, String title, String role, String email, String image, bool isMobile) {
    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          width: isMobile ? double.infinity : 230,
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  image, 
                  height: 180, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 180, color: const Color(0xFF2D3E50), child: const Icon(Icons.person, color: Colors.white38, size: 48)),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textMain),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
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
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 90, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3E50),
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
              const SizedBox(height: 50),
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
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 90, horizontal: 20),
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const _SectionHeader(
                subtitle: 'NOUS CONTACTER',
                title: 'À Votre Écoute',
              ),
              const SizedBox(height: 50),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _infoTile(Icons.location_on_rounded, 'Localisation', 'RDC, Ituri, Ville de Mahagi', isMobile),
                  _infoTile(Icons.phone_rounded, 'Ligne Directe', '+243 994 345 975', isMobile),
                  _infoTile(Icons.alternate_email_rounded, 'Email Officiel', 'contact@uaconline.edu.cd', isMobile),
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
          borderRadius: BorderRadius.circular(20),
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
      icon: const Icon(Icons.chevron_right_rounded, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D3E50),
        foregroundColor: Colors.white,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
