import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/utilisateur_entity.dart';
import 'package:istm_mahagi/features/dashboard/presentation/widgets/sidebar_menu.dart';
import 'package:istm_mahagi/features/dashboard/presentation/pages/collect_fees_page.dart';
import 'package:istm_mahagi/features/dashboard/presentation/pages/nomenclature_page.dart';
import 'package:istm_mahagi/features/dashboard/presentation/pages/financial_reports_page.dart';
import 'package:istm_mahagi/features/dashboard/presentation/pages/student_situation_page.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/academic/domain/entities/promotion_entity.dart';

class AccountantDashboard extends ConsumerStatefulWidget {
  const AccountantDashboard({super.key});

  @override
  ConsumerState<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends ConsumerState<AccountantDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSidebarExpanded = true;

  void _toggleSidebar() => setState(() => isSidebarExpanded = !isSidebarExpanded);

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final paymentsAsync = ref.watch(allPaymentsProvider);
    final promosAsync = ref.watch(promotionsProvider);
    final studentsAsync = ref.watch(studentsByPromoProvider(null)); // Load all
    
    final bool isMobile = Responsive.isMobile(context);

    return userAsync.when(
      data: (user) {
        if (user == null || user is! UtilisateurEntity) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final String comptableName = "${user.prenomUser} ${user.nomUser}";

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF1F5F9),
          drawer: isMobile ? _buildMobileDrawer(comptableName) : null,
          body: Row(
            children: [
              if (!isMobile)
                SidebarMenu(
                  isExpanded: isSidebarExpanded,
                  onToggle: _toggleSidebar,
                  userName: comptableName,
                  roleTitle: 'Comptabilité',
                  customItems: [
                    SidebarItem(icon: Icons.grid_view_rounded, title: 'Vue d\'ensemble', isActive: true),
                    SidebarItem(
                      icon: Icons.payments_rounded, 
                      title: 'Percevoir des Frais',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectFeesPage())),
                    ),
                    SidebarItem(
                      icon: Icons.settings_applications_rounded, 
                      title: 'Fixer la Nomenclature',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NomenclaturePage())),
                    ),
                    SidebarItem(
                      icon: Icons.trending_up_rounded, 
                      title: 'Rapports & Bilans',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialReportsPage())),
                    ),
                    SidebarItem(
                      icon: Icons.person_search_rounded, 
                      title: 'Situation par Étudiant',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentSituationPage())),
                    ),
                  ],
                ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopNavbar(isMobile, comptableName),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeHeader(comptableName),
                            const SizedBox(height: 45),
                            _buildActionsGrid(),
                            const SizedBox(height: 45),
                            paymentsAsync.when(
                              data: (payments) {
                                double total = 0;
                                for(var p in payments) total += (p['montant_paye'] ?? 0);
                                
                                return studentsAsync.when(
                                  data: (students) => _buildMetricsGrid(
                                    NumberFormat('#,###', 'fr_FR').format(total) + " \$",
                                    "${students.length} inscrits"
                                  ),
                                  loading: () => _buildMetricsGrid("...", "..."),
                                  error: (_, __) => _buildMetricsGrid("Err", "Err"),
                                );
                              },
                              loading: () => _buildMetricsGrid("...", "..."),
                              error: (_, __) => _buildMetricsGrid("Err", "Err"),
                            ),
                            const SizedBox(height: 45),
                            _buildPromoTable(paymentsAsync, promosAsync),
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

  Widget _buildMobileDrawer(String comptableName) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SidebarMenu(
        isExpanded: true,
        onToggle: () {},
        userName: comptableName,
        roleTitle: 'Comptabilité',
        customItems: [
          _drawerItem(context, Icons.grid_view_rounded, 'Vue d\'ensemble', null, isActive: true),
          _drawerItem(context, Icons.payments_rounded, 'Percevoir des Frais', const CollectFeesPage()),
          _drawerItem(context, Icons.settings_applications_rounded, 'Fixer la Nomenclature', const NomenclaturePage()),
          _drawerItem(context, Icons.trending_up_rounded, 'Rapports & Bilans', const FinancialReportsPage()),
          _drawerItem(context, Icons.person_search_rounded, 'Situation par Étudiant', const StudentSituationPage()),
        ],
      ),
    );
  }

  SidebarItem _drawerItem(BuildContext context, IconData icon, String title, Widget? page, {bool isActive = false}) {
    return SidebarItem(
      icon: icon,
      title: title,
      isActive: isActive,
      onTap: () {
        if (page != null) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
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
          const Text('ESPACE COMPTABILITÉ', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 2, fontSize: 13)),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded, color: Colors.grey, size: 26),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identification agent,',
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
          child: const Text(
            'Panneau de gestion financière de l\'ISTM • Session 2026',
            style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      int count = constraints.maxWidth > 1000 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        childAspectRatio: 2.8,
        children: [
          _actionCard('📥 Percevoir Frais', const Color(0xFF2563EB), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectFeesPage()))),
          _actionCard('⚙️ Nomenclature', const Color(0xFFD97706), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NomenclaturePage()))),
          _actionCard('📊 Rapports', const Color(0xFF16A34A), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialReportsPage()))),
          _actionCard('🔍 Solde Étudiant', const Color(0xFF4F46E5), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentSituationPage()))),
        ],
      );
    });
  }

  Widget _actionCard(String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color, letterSpacing: 0.5)),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(String total, String count) {
    return Row(
      children: [
        _metricCard(total, 'Recettes Totales', Icons.account_balance_wallet_rounded, Colors.green),
        const SizedBox(width: 30),
        _metricCard(count, 'État de Perception', Icons.people_alt_rounded, Colors.blue),
      ],
    );
  }

  Widget _metricCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 35, offset: const Offset(0, 12))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 5),
                Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoTable(AsyncValue<List<Map<String, dynamic>>> paymentsAsync, AsyncValue<List<PromotionEntity>> promosAsync) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Répartition par Promotion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                Text('Aperçu global des encaissements par salle', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          promosAsync.when(
            data: (promos) => paymentsAsync.when(
              data: (payments) => Table(
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                    children: [
                      _th('Promotion'), _th('Total Perçu'),
                    ],
                  ),
                  ...promos.map((PromotionEntity p) {
                    double totalPromo = 0;
                    for(var pay in payments) {
                      // Filter by promo ID
                      if (pay['id_promo']?.toString() == p.stableId) {
                        totalPromo += (pay['montant_paye'] ?? 0);
                      }
                    }
                    return _tr(p.nomPromo, NumberFormat('#,###', 'fr_FR').format(totalPromo) + " \$");
                  }).toList(),
                ],
              ),
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, _) => Text('Erreur paiements: $e'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur promos: $e'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  static Widget _th(String label) => Padding(padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20), child: Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1.5)));
  TableRow _tr(String p, String t) => TableRow(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25), child: Text(p, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)))), Padding(padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 15)))]);
}
