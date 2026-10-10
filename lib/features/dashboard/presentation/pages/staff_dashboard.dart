import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/staff_entity.dart';
import 'package:istm_mahagi/features/dashboard/presentation/widgets/sidebar_menu.dart';
import 'package:istm_mahagi/features/auth/presentation/pages/user_management_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/student_list_page.dart';
import 'package:istm_mahagi/features/finance/presentation/pages/finance_tracking_page.dart';
import 'package:istm_mahagi/features/social/presentation/pages/chat_page.dart';
import 'package:istm_mahagi/features/system/presentation/pages/system_config_page.dart';

class StaffDashboard extends ConsumerStatefulWidget {
  const StaffDashboard({super.key});

  @override
  ConsumerState<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends ConsumerState<StaffDashboard> {
  bool isSidebarExpanded = true;

  void _toggleSidebar() => setState(() => isSidebarExpanded = !isSidebarExpanded);

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final bool isMobile = Responsive.isMobile(context);

    return userAsync.when(
      data: (user) {
        if (user == null || user is! StaffEntity) return const SizedBox.shrink();

        final String staffName = "\${user.prenom} \${user.nom}";

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF7),
          body: Row(
            children: [
              if (!isMobile)
                SidebarMenu(
                  isExpanded: isSidebarExpanded,
                  onToggle: _toggleSidebar,
                  userName: staffName,
                  roleTitle: 'Direction',
                  customItems: [
                    SidebarItem(icon: Icons.grid_view_rounded, title: 'Tableau de Bord', isActive: true),
                    SidebarItem(
                      icon: Icons.person_search_rounded, 
                      title: 'Gestion du Personnel',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage())),
                    ),
                    SidebarItem(icon: Icons.people_alt_rounded, title: 'Gestion Enseignants'),
                    SidebarItem(icon: Icons.business_rounded, title: 'Gestion Staff'),
                    SidebarItem(
                      icon: Icons.school_rounded, 
                      title: 'Suivi Académique',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListPage())),
                    ),
                    SidebarItem(
                      icon: Icons.attach_money_rounded, 
                      title: 'Suivi Financier',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceTrackingPage())),
                    ),
                    SidebarItem(
                      icon: Icons.mark_email_unread_rounded, 
                      title: 'Courriers Arrivés',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
                    ),
                    SidebarItem(
                      icon: Icons.admin_panel_settings_rounded, 
                      title: 'Paramètres Système',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemConfigPage())),
                    ),
                  ],
                ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopNavbar(isMobile, staffName),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeHeader(staffName, user.fonction),
                            const SizedBox(height: 50),
                            _buildStatsGrid(),
                            const SizedBox(height: 50),
                            _buildModulesGrid(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: \$e'))),
    );
  }

  Widget _buildTopNavbar(bool isMobile, String name) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (!isMobile)
            IconButton(icon: const Icon(Icons.menu_open_rounded, color: Color(0xFF0F172A)), onPressed: _toggleSidebar),
          const SizedBox(width: 25),
          const Text('ESPACE DIRECTION', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 2)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: const Text('SESSION ACADÉMIQUE 2026', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String name, String fonction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bienvenue dans votre espace,',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        Text(
          name.toUpperCase(),
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
          child: Text(
            fonction.toUpperCase(),
            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      int count = constraints.maxWidth > 1000 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        mainAxisSpacing: 30,
        crossAxisSpacing: 30,
        childAspectRatio: 2.2,
        children: [
          _statCard('Enseignants', '42', const Color(0xFF2563EB), Icons.people_alt_rounded),
          _statCard('Étudiants', '1,250', const Color(0xFF16A34A), Icons.school_rounded),
          _statCard('Membres Staff', '18', const Color(0xFFD97706), Icons.badge_rounded),
          _statCard('Rapports', '3', const Color(0xFFDC2626), Icons.assignment_rounded),
        ],
      );
    });
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 25),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      int count = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        childAspectRatio: 3.2,
        children: [
          _moduleBtn('👤 Gestion Personnel', const Color(0xFF0F172A), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()))),
          _moduleBtn('🎓 Suivi Académique', const Color(0xFF2563EB), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListPage()))),
          _moduleBtn('💵 Suivi Financier', const Color(0xFF16A34A), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceTrackingPage()))),
          _moduleBtn('📊 Rapports Archives', const Color(0xFFD97706), () {}),
          _moduleBtn('✉️ Courriers Arrivés', const Color(0xFF7C3AED), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()))),
          _moduleBtn('⚙️ Paramètres Système', const Color(0xFF64748B), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemConfigPage()))),
        ],
      );
    });
  }

  Widget _moduleBtn(String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        hoverColor: color.withOpacity(0.03),
        child: Center(
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
