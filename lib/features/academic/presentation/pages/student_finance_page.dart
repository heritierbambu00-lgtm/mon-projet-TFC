import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';

class StudentFinancePage extends ConsumerWidget {
  const StudentFinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('MES FINANCES ACADÉMIQUES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: userDataAsync.when(
        data: (user) {
          if (user == null || user is! EtudiantEntity) return const Center(child: Text("Accès refusé."));

          final configAsync = ref.watch(getStudentFraisConfigProvider(user.idPromo));
          final paymentsAsync = ref.watch(getStudentPaymentsProvider(user.id));

          return configAsync.when(
            data: (config) => paymentsAsync.when(
              data: (payments) {
                final double montantFixe = (config?['montant_total'] ?? 0).toDouble();
                final String anneeAcad = config?['annee_acad'] ?? "Non définie";

                double totalPaye = 0;
                for (var p in payments) {
                  totalPaye += (p['montant_paye'] ?? 0).toDouble();
                }

                final double reste = montantFixe - totalPaye;
                final double pourcentage = montantFixe > 0 ? (totalPaye / montantFixe) * 100 : 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(anneeAcad),
                          const SizedBox(height: 30),
                          _buildStatsGrid(montantFixe, totalPaye, reste),
                          const SizedBox(height: 30),
                          _buildProgressBox(pourcentage),
                          const SizedBox(height: 40),
                          _buildHistoryTable(payments),
                          const SizedBox(height: 60),
                          _buildFinanceExtensions(context, reste, totalPaye, montantFixe),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur paiements: $e")),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Erreur config frais: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur utilisateur: $e")),
      ),
    );
  }

  Widget _buildHeader(String annee) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💰 RÉCAPITULATIF FINANCIER', 
                style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A2A6C), fontSize: 13, letterSpacing: 1)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFF1A2A6C).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Année Académique : $annee', 
                    style: const TextStyle(color: Color(0xFF1A2A6C), fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(double fixe, double paye, double reste) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 600;
      int count = constraints.maxWidth > 750 ? 3 : 1;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: isMobile ? 3.8 : (count == 3 ? 2.2 : 4.0),
        children: [
          _statCard('Montant Prévu', fixe, const Color(0xFF3498DB)),
          _statCard('Total Payé', paye, const Color(0xFF27AE60)),
          _statCard('Solde Débiteur', reste, const Color(0xFFB21F1F)),
        ],
      );
    });
  }

  Widget _statCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('${NumberFormat('#,###', 'fr_FR').format(value)} \$', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color == const Color(0xFFB21F1F) ? color : const Color(0xFF1A2A6C))),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBox(double p) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Progression globale de vos versements', 
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2C3E50), fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Text('${p.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.w900, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: p / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE9ECEF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(List<Map<String, dynamic>> payments) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(25),
            child: Text('🗂️ HISTORIQUE DES VERSEMENTS', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A2A6C), fontSize: 14, letterSpacing: 1)),
          ),
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('Aucune transaction enregistrée pour le moment.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFD)),
                  columns: const [
                    DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                    DataColumn(label: Text('MOTIF / LIBELLÉ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                    DataColumn(label: Text('MONTANT VERSÉ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                    DataColumn(label: Text('STATUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                  ],
                  rows: payments.map((p) {
                    final date = (p['date_paiement'] as dynamic).toDate();
                    return DataRow(cells: [
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(p['type_frais'] ?? 'Frais Académiques', style: const TextStyle(color: Colors.grey))),
                      DataCell(Text('+ ${NumberFormat('#,###', 'fr_FR').format(p['montant_paye'])} \$', style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.w900))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Validé', style: TextStyle(color: Color(0xFF27AE60), fontSize: 10, fontWeight: FontWeight.w900)),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinanceExtensions(BuildContext context, double reste, double paye, double total) {
    return Column(
      children: [
        // augmented: Solvability Status
        PremiumFadeIn(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('STATUT DE SOLVABILITÉ', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepNavy, fontSize: 11, letterSpacing: 2)),
                      const SizedBox(height: 15),
                      Text(
                        paye >= (total * 0.5) ? 'ÉLIGIBLE AUX EXAMENS' : 'NON ÉLIGIBLE (MIN 50%)',
                        style: TextStyle(
                          color: paye >= (total * 0.5) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Playfair Display',
                          fontSize: 20
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Basé sur les critères du Secrétariat Général.',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(
                  paye >= (total * 0.5) ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  color: paye >= (total * 0.5) ? Colors.green : Colors.red,
                  size: 45,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        PremiumFadeIn(
          delay: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              gradient: AppColors.deepGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.calculate_rounded, color: AppColors.accentYellow, size: 28),
                    SizedBox(width: 15),
                    const Text(
                      'PLANIFICATEUR DE PAIEMENT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  'Simulez votre solde futur :',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(color: AppColors.accentYellow),
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.accentYellow, size: 20),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Votre reste à payer après ce versement : ${(reste > 0 ? reste : 0).toStringAsFixed(1)} \$',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        PremiumFadeIn(
          delay: const Duration(milliseconds: 400),
          child: Column(
            children: [
              const Text(
                'BANQUES PARTENAIRES',
                style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textMuted, fontSize: 10, letterSpacing: 3),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PartnerLogo(name: 'EQUITY BCDC'),
                  _PartnerLogo(name: 'TMB BANK'),
                  _PartnerLogo(name: 'RAWBANK'),
                ],
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.help_outline_rounded, color: AppColors.textMuted, size: 40),
                    const SizedBox(height: 20),
                    const Text(
                      'ASSISTANCE TRÉSORERIE',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepNavy, fontSize: 12, letterSpacing: 2),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Pour toute réclamation sur un versement non listé, veuillez vous présenter à la comptabilité avec votre bordereau original de versement bancaire.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('VOIR LES COORDONNÉES BANCAIRES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PartnerLogo extends StatelessWidget {
  final String name;
  const _PartnerLogo({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey),
      ),
    );
  }
}

// Providers
final getStudentFraisConfigProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, idPromo) {
  return ref.watch(academicRepositoryProvider).getStudentFraisConfig(idPromo);
});

final getStudentPaymentsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, etuId) {
  return ref.watch(academicRepositoryProvider).getStudentPayments(etuId);
});
