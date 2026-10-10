import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/admin_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/utilisateur_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/staff_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/enseignant_entity.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/faculty_management_page.dart';
import 'package:istm_mahagi/features/auth/presentation/pages/user_management_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/grading_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/results_palmares_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/student_list_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/enrollment_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/teacher_management_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/course_management_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/schedule_management_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/calendar_management_page.dart';
import 'package:istm_mahagi/features/info/presentation/pages/institutional_management_page.dart';
import 'package:istm_mahagi/features/system/presentation/pages/system_config_page.dart';
import 'package:istm_mahagi/features/dashboard/presentation/widgets/sidebar_menu.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/core/navigation/auth_wrapper.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSidebarExpanded = true;

  void _toggleSidebar() => setState(() => isSidebarExpanded = !isSidebarExpanded);

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final deptsAsync = ref.watch(departmentsProvider);
    final bool isMobile = Responsive.isMobile(context);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          Future.microtask(() {
            ref.read(authEntityProvider.notifier).state = null;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => AuthWrapper()),
              (route) => false,
            );
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        String userName = "";
        String userRoleLabel = "";
        String? deptId;
        String rawRole = "";

        if (user is AdminEntity) {
          userName = user.nomComplet;
          userRoleLabel = "Administrateur";
          rawRole = "administrateur";
        } else if (user is UtilisateurEntity) {
          userName = "${user.prenomUser} ${user.nomUser}";
          rawRole = user.role.toLowerCase();
          userRoleLabel = rawRole == 'secretaire' ? 'Secrétaire' : (rawRole == 'decanat' ? 'Décanat' : rawRole.toUpperCase());
          deptId = user.idDept;
        } else if (user is StaffEntity) {
          userName = "${user.prenom} ${user.nom}";
          userRoleLabel = "Direction";
          rawRole = "staff";
        } else if (user is EnseignantEntity) {
          userName = "Prof. ${user.nomEns}";
          userRoleLabel = "Enseignant";
          rawRole = "enseignant";
        } else {
          userName = "Utilisateur";
          userRoleLabel = "Agent";
        }

        return deptsAsync.when(
          data: (depts) {
            String deptNameLabel = "Administration Globale";
            if (deptId != null && deptId.isNotEmpty) {
              final dept = depts.where((d) => d.id == deptId).firstOrNull;
              if (dept != null) {
                deptNameLabel = "UAC - ${dept.nomDept}";
              }
            }

            final bool isAdmin = rawRole == 'administrateur' || rawRole == 'admin';
            final bool isSecretaryOrDecan = rawRole == 'secretaire' || rawRole == 'decanat' || rawRole == 'décanat';

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.surface,
              drawer: isMobile ? _buildMobileDrawer(userName, userRoleLabel) : null,
              body: Row(
                children: [
                  if (!isMobile)
                    SidebarMenu(
                      isExpanded: isSidebarExpanded,
                      onToggle: _toggleSidebar,
                      userName: userName,
                      roleTitle: userRoleLabel,
                      photoUrl: null, // Admin could have a photo too but let's keep it simple
                      customItems: _getSidebarActions(isAdmin, isSecretaryOrDecan),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        if (isMobile) 
                          Container(color: Colors.white, height: MediaQuery.of(context).padding.top),
                        _buildTopNavbar(isMobile, userName, userRoleLabel, deptNameLabel),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.getPadding(context), 
                              vertical: isMobile ? 20 : 30
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PremiumFadeIn(child: _buildWelcomeHeader(userName, deptNameLabel)),
                                const SizedBox(height: 35),
                                PremiumFadeIn(
                                  delay: const Duration(milliseconds: 200),
                                  child: _buildShortcutSection()
                                ),
                                const SizedBox(height: 40),
                                PremiumFadeIn(
                                  delay: const Duration(milliseconds: 400),
                                  child: _buildQuickInfoCard()
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
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Erreur départements: $e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur profil: $e'))),
    );
  }

  List<SidebarItem> _getSidebarActions(bool isAdmin, bool isSecretaryOrDecan) {
    return [
      SidebarItem(icon: Icons.grid_view_rounded, title: 'Tableau de Bord', isActive: true),
      if (isAdmin || isSecretaryOrDecan) ...[
        SidebarItem(
          icon: Icons.edit_document, 
          title: 'Saisie des Cotes',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradingPage())),
        ),
        SidebarItem(
          icon: Icons.analytics_rounded, 
          title: 'Résultats & Palmarès',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsPalmaresPage())),
        ),
        SidebarItem(
          icon: Icons.group_rounded, 
          title: 'Liste des Étudiants',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListPage())),
        ),
        SidebarItem(
          icon: Icons.person_add_rounded, 
          title: 'Inscription',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnrollmentPage())), 
        ),
        SidebarItem(
          icon: Icons.account_balance_rounded, 
          title: 'Facultés & Départements',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyManagementPage())),
        ),
        SidebarItem(
          icon: Icons.school_rounded, 
          title: 'Gestion Enseignants',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherManagementPage())),
        ),
        SidebarItem(
          icon: Icons.library_books_rounded, 
          title: 'Gestion des Cours',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseManagementPage())),
        ),
        SidebarItem(
          icon: Icons.account_balance_rounded, 
          title: 'Gestion Institutionnelle',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstitutionalManagementPage())),
        ),
      ],
      SidebarItem(
        icon: Icons.calendar_view_week_rounded, 
        title: 'Gestion Horaires',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleManagementPage())),
      ),
      SidebarItem(
        icon: Icons.event_note_rounded, 
        title: 'Calendrier Académique',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarManagementPage())),
      ),
      if (isAdmin) ...[
        SidebarItem(
          icon: Icons.settings_suggest_rounded, 
          title: 'Configuration Système',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemConfigPage())),
        ),
        SidebarItem(
          icon: Icons.admin_panel_settings_rounded, 
          title: 'Utilisateurs & Agents',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage())),
        ),
      ],
    ];
  }

  Widget _buildTopNavbar(bool isMobile, String name, String role, String deptName) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: isMobile ? 70 : 95,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 35),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
          ),
          child: Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.menu_rounded, color: AppColors.primaryBlue, size: 24),
                  ),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                )
              else
                IconButton(
                  icon: Icon(isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded, color: AppColors.deepNavy, size: 28),
                  onPressed: _toggleSidebar,
                ),
              SizedBox(width: isMobile ? 10 : 25),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMobile ? 'ADMIN' : 'CONSOLE DE GESTION',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, color: AppColors.deepNavy.withOpacity(0.4)),
                    ),
                    Text(
                      deptName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.deepNavy, fontSize: isMobile ? 9 : 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.notifications_none_rounded, color: AppColors.textMuted, size: 26),
              if (!isMobile) ...[
                const SizedBox(width: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                      const SizedBox(width: 10),
                      Text(
                        role.toUpperCase(),
                        style: const TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(String userName, String roleLabel) {
    // Determine admin status for mobile drawer logic
    final isAdmin = roleLabel.toLowerCase().contains('admin');
    final isSecretaryOrDecan = roleLabel.toLowerCase().contains('secretaire') || roleLabel.toLowerCase().contains('decanat');

    return Drawer(
      backgroundColor: AppColors.deepNavy,
      child: SidebarMenu(
        isExpanded: true,
        onToggle: () {},
        userName: userName,
        roleTitle: roleLabel,
        customItems: _getSidebarActions(isAdmin, isSecretaryOrDecan).map((item) {
          return SidebarItem(
            icon: item.icon,
            title: item.title,
            isActive: item.isActive,
            onTap: () {
              Navigator.pop(context);
              if (item.onTap != null) item.onTap!();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWelcomeHeader(String userName, String deptName) {
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
            userName.toUpperCase(),
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
          child: Text(
            'Unité active : $deptName • 2026',
            style: const TextStyle(color: AppColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = Responsive.isMobile(context);
      final bool isTablet = Responsive.isTablet(context);

      double aspectRatio = 3.5; 
      int crossAxisCount = 3;
      
      if (isMobile) {
        crossAxisCount = 1;
        aspectRatio = 3.8;
      } else if (isTablet) {
        crossAxisCount = 2;
        aspectRatio = 3.2;
      }

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: aspectRatio,
        children: [
          _buildShortcutCard(
            title: 'Saisie des Fiches Cotes',
            desc: 'Gestion des points professeurs.',
            color: Colors.orange.shade800,
            icon: Icons.edit_document,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradingPage())),
          ),
          _buildShortcutCard(
            title: 'Publication Résultats',
            desc: 'Visibilité publique des notes.',
            color: Colors.blue.shade800,
            icon: Icons.visibility_rounded,
            badge: 'Masqué',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemConfigPage())),
          ),
          _buildShortcutCard(
            title: 'Gestion Horaires',
            desc: 'Planning des cours par filière.',
            color: Colors.green.shade800,
            icon: Icons.calendar_view_week_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleManagementPage())),
          ),
          _buildShortcutCard(
            title: 'Contenu Institutionnel',
            desc: 'Gérer les pages "A Propos".',
            color: AppColors.premiumGold,
            icon: Icons.account_balance_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstitutionalManagementPage())),
          ),
        ],
      );
    });
  }

  Widget _buildShortcutCard({
    required String title,
    required String desc,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color, width: 6)), 
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 30, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(icon, color: color, size: 20),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withOpacity(0.2))),
                              child: Text(
                                badge.toUpperCase(), 
                                style: const TextStyle(color: Colors.redAccent, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.deepNavy, fontFamily: 'Playfair Display')
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard() {
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
            child: const Icon(Icons.security_rounded, size: 40, color: AppColors.accentYellow),
          ),
          const SizedBox(height: 25),
          const Text(
            'PANNEAU DE CONTRÔLE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: Colors.white, 
              fontFamily: 'Playfair Display',
              letterSpacing: 1
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Gérez les accès, supervisez les inscriptions et publiez les résultats académiques en toute sécurité.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
