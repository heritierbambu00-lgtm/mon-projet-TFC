import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/enseignant_entity.dart';
import 'package:istm_mahagi/features/dashboard/presentation/widgets/sidebar_menu.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/course_support_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/grading_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/course_schedule_page.dart';
import 'package:istm_mahagi/features/academic/presentation/pages/tp_management_page.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  bool isSidebarExpanded = true;

  void _toggleSidebar() => setState(() => isSidebarExpanded = !isSidebarExpanded);

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final bool isMobile = Responsive.isMobile(context);

    return userAsync.when(
      data: (user) {
        if (user == null || user is! EnseignantEntity) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final String profName = "Prof. ${user.nomEns} ${user.postnomEns}";

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Row(
            children: [
              if (!isMobile)
                SidebarMenu(
                  isExpanded: isSidebarExpanded,
                  onToggle: _toggleSidebar,
                  userName: profName,
                  roleTitle: 'Enseignant',
                  photoUrl: user.photoEns,
                  customItems: [
                    SidebarItem(
                      icon: Icons.grid_view_rounded, 
                      title: 'Tableau de Bord', 
                      isActive: true,
                    ),
                    SidebarItem(
                      icon: Icons.cloud_upload_rounded, 
                      title: 'Supports de Cours',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseSupportPage())),
                    ),
                    SidebarItem(
                      icon: Icons.fact_check_rounded, 
                      title: 'Saisie des Notes',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradingPage())),
                    ),
                    SidebarItem(
                      icon: Icons.calendar_month_rounded, 
                      title: 'Mon Horaire',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseSchedulePage())),
                    ),
                    SidebarItem(
                      icon: Icons.assignment_turned_in_rounded, 
                      title: 'TP des Étudiants',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TpManagementPage())),
                    ),
                  ],
                ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopNavbar(isMobile, profName),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeHeader(profName, user.specialite),
                            const SizedBox(height: 45),
                            _buildStatsGrid(),
                            const SizedBox(height: 45),
                            _buildCoursesSection(user),
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
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }

  Widget _buildTopNavbar(bool isMobile, String name) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (!isMobile)
            IconButton(
              icon: Icon(isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded, color: const Color(0xFF0F172A), size: 28),
              onPressed: _toggleSidebar,
            ),
          const SizedBox(width: 25),
          const Text('CONSONLE ACADÉMIQUE', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 2, fontSize: 13)),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded, color: Colors.grey, size: 26),
          const SizedBox(width: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Colors.green),
                SizedBox(width: 10),
                Text('SESSION 2026', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String name, String specialite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heureux de vous revoir,',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
        ),
        Text(
          name.toUpperCase(),
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08), 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
          ),
          child: Text(
            'Expertise : $specialite • Statut : Personnel Actif',
            style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      int count = constraints.maxWidth > 1000 ? 3 : 1;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        mainAxisSpacing: 30,
        crossAxisSpacing: 30,
        childAspectRatio: 3.2,
        children: [
          _statCard('Moyenne Pédagogique', '4.8', Icons.auto_graph_rounded, Colors.indigo),
          _statCard('Participations Cours', '92%', Icons.pie_chart_rounded, const Color(0xFF10B981)),
          _statCard('Score Scientifique', 'Premium', Icons.verified_rounded, Colors.orange),
        ],
      );
    });
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(EnseignantEntity user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mes Cours & Attributions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  Text('Suivi des enseignements par promotion', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('IMPRIMER LISTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9), foregroundColor: Colors.black87, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
          const SizedBox(height: 35),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  _tableHeader('COURS'),
                  _tableHeader('PROMOTION'),
                  _tableHeader('GESTION'),
                ],
              ),
              _courseRow('Anatomie Humaine', 'L1 Sciences Infirmières'),
              _courseRow('Physiologie Cardiaque', 'L2 Sage-Femme'),
              _courseRow('Biochimie Clinique', 'L3 Laboratoire'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B), fontSize: 11, letterSpacing: 1.5)),
    );
  }

  TableRow _courseRow(String course, String promo) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), 
          child: Text(course, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)))
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Text(promo, style: const TextStyle(color: Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w700))
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            children: [
              _actionBtn(Icons.edit_note_rounded, const Color(0xFF0F172A), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradingPage()))),
              const SizedBox(width: 10),
              _actionBtn(Icons.file_present_rounded, const Color(0xFF10B981), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseSupportPage()))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
