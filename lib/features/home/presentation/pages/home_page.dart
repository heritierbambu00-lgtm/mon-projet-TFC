import 'dart:async';
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
              // Top Information Bar (Modèle UAC avec onglet bleu biseauté)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF2D3E50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Avez-vous une question ? +243 814 313 997',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (!Responsive.isMobile(context))
                        ClipPath(
                          clipper: _AngledTabClipper(),
                          child: Container(
                            color: const Color(0xFF0088FF),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                            child: Row(
                              children: [
                                _HoverTopBarPortail(onSelectRole: _openLogin),
                                const Text('  |  ', style: TextStyle(color: Colors.white70)),
                                _topBarIconLink(Icons.menu_book_rounded, 'Bibliothèque', () => _navigateTo(const ELearningPage())),
                                const Text('  |  ', style: TextStyle(color: Colors.white70)),
                                _topBarIconLink(Icons.local_fire_department_rounded, 'Étincelle', () => _navigateTo(const ELearningPage())),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Main Navigation Header (Navbar identique avec survol automatique)
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
                        _HoverNavItem(icon: Icons.home_rounded, title: 'ACCUEIL', onTap: () {}),
                        _HoverNavDropdown(
                          icon: Icons.inbox_rounded,
                          title: 'À PROPOS',
                          items: {
                            'Galerie photos': const GalleryPage(),
                            'Personnel': const CommitteePage(),
                            'Calendrier': const CalendarPage(),
                            'Hymne': const AnthemPage(),
                            'Historique': const HistoryPage(),
                            'Mission et Vision': const MissionVisionPage(),
                            'Statuts': const StatutesPage(),
                          },
                          onSelect: _navigateTo,
                        ),
                        _HoverNavItem(icon: Icons.access_time_rounded, title: 'HORAIRE', onTap: () => _navigateTo(const CourseSchedulePage())),
                        _HoverNavDropdown(
                          icon: Icons.school_rounded,
                          title: 'DOMAINE',
                          items: {
                            'Sciences de l\'Homme et de la Société': const ELearningPage(),
                            'Sciences Economiques et de Gestion': const ELearningPage(),
                            'Sciences Agronomiques et Environnement': const ELearningPage(),
                            'Sciences et Technologie': const ELearningPage(),
                            'Sciences Psychologiques de l\'Education': const ELearningPage(),
                          },
                          onSelect: _navigateTo,
                        ),
                        _HoverNavDropdown(
                          icon: Icons.laptop_chromebook_rounded,
                          title: 'E-LEARNING',
                          items: {
                            'Portail Enseignant': const ELearningPage(),
                            'Portail Etudiant': const ELearningPage(),
                          },
                          onSelect: _navigateTo,
                        ),
                        _HoverNavDropdown(
                          icon: Icons.vpn_key_rounded,
                          title: 'INTRANET',
                          items: {
                            'Décanat': const ELearningPage(),
                            'Staff': const ELearningPage(),
                          },
                          onSelect: _navigateTo,
                        ),
                        _HoverNavItem(icon: Icons.email_rounded, title: 'CONTACT', onTap: () => _navigateTo(const ContactPage())),
                        
                        // Bouton de recherche bleu carré comme sur la capture
                        Container(
                          margin: const EdgeInsets.only(left: 8, right: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0088FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IconButton(
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            icon: Icon(_isSearchOpen ? Icons.close : Icons.search_rounded, color: Colors.white, size: 18),
                            onPressed: () => setState(() => _isSearchOpen = !_isSearchOpen),
                          ),
                        ),
                      ],
                    ),
                  // Pas de menu burger sur écran d'ordinateur (desktop)
                  if (!Responsive.isDesktop(context)) ...[
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppColors.primaryBlue, size: 30),
                      onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                    const SizedBox(width: 10),
                  ],
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

              // Quick Action Buttons Bar (4 Boutons)
              SliverToBoxAdapter(
                child: _QuickButtonsBar(),
              ),

              // Nouvelles Récentes Section (100% Dynamique Firestore)
              SliverToBoxAdapter(
                child: _NewsSection(),
              ),

              // Gallery Strip Section (100% Dynamique Firestore)
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
                                    _buildStatCard(Icons.history_toggle_off, stats['annees'] ?? '...', 'Années d\'expérience', context),
                                    _buildStatCard(Icons.school_outlined, stats['etudiants'] ?? '...', 'Étudiants formés', context),
                                    _buildStatCard(Icons.account_tree_outlined, stats['departements'] ?? '...', 'Départements actifs', context),
                                    _buildStatCard(Icons.verified_user_outlined, stats['homologation'] ?? '...', 'Diplômes homologués', context),
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

              // Domains / Nos Domaines Section (100% Dynamique Firestore)
              SliverToBoxAdapter(
                child: _DomainsSection(),
              ),

              // Committee Section (100% Dynamique Firestore - Masqué si vide)
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

  Widget _topBarIconLink(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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

// Widget pour les éléments de la navigation principale avec effet de survol (Hover) & soulignement bleu (Image 3)
class _HoverNavDropdown extends StatefulWidget {
  final IconData icon;
  final String title;
  final Map<String, Widget> items;
  final Function(Widget) onSelect;

  const _HoverNavDropdown({
    required this.icon,
    required this.title,
    required this.items,
    required this.onSelect,
  });

  @override
  State<_HoverNavDropdown> createState() => _HoverNavDropdownState();
}

class _HoverNavDropdownState extends State<_HoverNavDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;
  Timer? _closeTimer;

  void _showOverlay() {
    _closeTimer?.cancel();
    if (_overlayEntry != null) return;

    setState(() => _isHovered = true);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 240,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 36),
          child: MouseRegion(
            onEnter: (_) => _cancelCloseTimer(),
            onExit: (_) => _scheduleClose(),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.items.entries.map((entry) {
                    return _HoverSubMenuItem(
                      title: entry.key,
                      onTap: () {
                        _removeOverlay();
                        widget.onSelect(entry.value);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 150), () {
      _removeOverlay();
    });
  }

  void _cancelCloseTimer() {
    _closeTimer?.cancel();
  }

  void _removeOverlay() {
    _closeTimer?.cancel();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isHovered = false);
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _scheduleClose(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 14, color: _isHovered ? AppColors.primaryBlue : const Color(0xFF2D3E50)),
                  const SizedBox(width: 4),
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: _isHovered ? AppColors.primaryBlue : AppColors.textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _isHovered ? AppColors.primaryBlue : AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 2,
                width: _isHovered ? 35 : 0,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverNavItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HoverNavItem({required this.icon, required this.title, required this.onTap});

  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 14, color: _isHovered ? AppColors.primaryBlue : const Color(0xFF2D3E50)),
                  const SizedBox(width: 4),
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: _isHovered ? AppColors.primaryBlue : AppColors.textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 2,
                width: _isHovered ? 35 : 0,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverSubMenuItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HoverSubMenuItem({required this.title, required this.onTap});

  @override
  State<_HoverSubMenuItem> createState() => _HoverSubMenuItemState();
}

class _HoverSubMenuItemState extends State<_HoverSubMenuItem> {
  bool _isItemHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isItemHovered = true),
      onExit: (_) => setState(() => _isItemHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _isItemHovered ? const Color(0xFFF1F5F9) : Colors.transparent,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: _isItemHovered ? FontWeight.bold : FontWeight.w500,
              color: _isItemHovered ? AppColors.primaryBlue : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

// Menu Portail avec déclenchement au survol (Hover)
class _HoverTopBarPortail extends StatefulWidget {
  final Function(String) onSelectRole;

  const _HoverTopBarPortail({required this.onSelectRole});

  @override
  State<_HoverTopBarPortail> createState() => _HoverTopBarPortailState();
}

class _HoverTopBarPortailState extends State<_HoverTopBarPortail> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _closeTimer;

  void _showOverlay() {
    _closeTimer?.cancel();
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 160,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 28),
          child: MouseRegion(
            onEnter: (_) => _cancelCloseTimer(),
            onExit: (_) => _scheduleClose(),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    'Étudiant',
                    'Enseignant',
                    'Staff',
                    'Décanat',
                    'Comptable',
                  ].map((role) => _HoverSubMenuItem(
                    title: role,
                    onTap: () {
                      _removeOverlay();
                      widget.onSelectRole(role);
                    },
                  )).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 150), () {
      _removeOverlay();
    });
  }

  void _cancelCloseTimer() {
    _closeTimer?.cancel();
  }

  void _removeOverlay() {
    _closeTimer?.cancel();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _scheduleClose(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person_rounded, color: Colors.white, size: 14),
            SizedBox(width: 5),
            Text(
              'Portail',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _AngledTabClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(22, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
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
              _quickButton('Alumni', isMobile, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsPage()))),
              _quickButton('CIAQ', isMobile, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatutesPage()))),
              _quickButton('Bibliothèque numérique', isMobile, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ELearningPage()))),
              _quickButton('E-Learning', isMobile, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ELearningPage()))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickButton(String title, bool isMobile, VoidCallback onTap) {
    return Container(
      width: isMobile ? (150) : 220,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF2D3E50),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: onTap,
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

class _NewsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return newsAsync.when(
      data: (articles) {
        if (articles.isEmpty) return const SizedBox.shrink();

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
                    children: articles.take(isMobile ? 1 : 3).map((article) {
                      final dateStr = "${article.date.day.toString().padLeft(2, '0')}/${article.date.month.toString().padLeft(2, '0')}";
                      final timeStr = "${article.date.hour.toString().padLeft(2, '0')}:${article.date.minute.toString().padLeft(2, '0')}";
                      return _newsItem(
                        context, 
                        article.title, 
                        dateStr, 
                        timeStr, 
                        'ISTM Mahagi', 
                        article.imageUrl, 
                        isMobile
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 50),
                  _buildSeeMoreButton(context, const NewsPage(), "VOIR TOUTES LES ACTUALITÉS"),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
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
                    image.startsWith('http') 
                      ? Image.network(
                          image, 
                          height: isMobile ? 200 : 240, 
                          width: double.infinity, 
                          fit: BoxFit.cover, 
                          errorBuilder: (_, __, ___) => _imagePlaceholder(isMobile)
                        )
                      : (image.isNotEmpty
                          ? Image.asset(
                              image, 
                              height: isMobile ? 200 : 240, 
                              width: double.infinity, 
                              fit: BoxFit.cover, 
                              errorBuilder: (_, __, ___) => _imagePlaceholder(isMobile)
                            )
                          : _imagePlaceholder(isMobile)),
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

  Widget _imagePlaceholder(bool isMobile) {
    return Container(
      height: isMobile ? 200 : 240,
      width: double.infinity,
      color: const Color(0xFF2D3E50),
      child: const Center(child: Icon(Icons.newspaper, color: Colors.white38, size: 48)),
    );
  }
}

class _GalleryBannerStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return galleryAsync.when(
      data: (items) {
        final List<String> images = items.map((i) => i.imageUrl).where((img) => img.isNotEmpty).toList();
        if (images.isEmpty) return const SizedBox.shrink();

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
                      children: images.map((img) => Padding(
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
                              backgroundImage: (img.startsWith('http'))
                                  ? NetworkImage(img)
                                  : AssetImage(img) as ImageProvider,
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
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DomainsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultiesAsync = ref.watch(homeFacultiesProvider);
    final isMobile = Responsive.isMobile(context);

    return facultiesAsync.when(
      data: (faculties) {
        if (faculties.isEmpty) return const SizedBox.shrink();

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
                    'L\'ISTM Mahagi organise les domaines principaux d\'enseignement. Dans chaque domaine, il y a les différentes filières de formation d\'élite. Cliquez afin de lire le détail.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 50),
                  Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: faculties.map((f) => _domainCard(
                      context, 
                      f.nomFaculte, 
                      'contact@istm-mahagi.edu', 
                      isMobile
                    )).toList(),
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
                      'Excellence - Rigueur - Santé',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _domainCard(BuildContext context, String title, String email, bool isMobile) {
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
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2D3E50),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded, color: AppColors.accentYellow, size: 64),
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
                      child: const Text('EN SAVOIR PLUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
    final committeeAsync = ref.watch(committeeStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return committeeAsync.when(
      data: (members) {
        if (members.isEmpty) return const SizedBox.shrink();

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
                    children: members.map((m) => _memberCard(
                      m.nomComplet, 
                      m.categorie, 
                      m.fonction, 
                      'contact@istm-mahagi.edu', 
                      m.photoMembre, 
                      isMobile
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
                child: image.startsWith('http')
                  ? Image.network(
                      image, 
                      height: 180, 
                      width: double.infinity, 
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                    )
                  : (image.isNotEmpty
                      ? Image.asset(
                          image,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                        )
                      : _avatarPlaceholder()),
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

  Widget _avatarPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFF2D3E50),
      child: const Center(child: Icon(Icons.person_rounded, color: Colors.white38, size: 56)),
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
