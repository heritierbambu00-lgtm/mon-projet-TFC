import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/academic/domain/entities/promotion_entity.dart';

class FinancialReportsPage extends ConsumerWidget {
  const FinancialReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(allPaymentsProvider);
    final promosAsync = ref.watch(promotionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('RAPPORTS & BILANS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.print_rounded, color: Color(0xFF0F172A))),
          const SizedBox(width: 15),
        ],
      ),
      body: paymentsAsync.when(
        data: (payments) {
          double totalEncaisse = 0;
          for (var p in payments) totalEncaisse += (p['montant_paye'] ?? 0);
          double moyenne = payments.isNotEmpty ? totalEncaisse / payments.length : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(35),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildKPISection(totalEncaisse, payments.length, moyenne),
                    const SizedBox(height: 35),
                    _buildJournalCard(payments, promosAsync),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur rapports: $e")),
      ),
    );
  }

  Widget _buildKPISection(double total, int count, double avg) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        childAspectRatio: 3.2,
        children: [
          _kpiCard('Total Encaissé', '${NumberFormat('#,###').format(total)} \$', Icons.payments_rounded, Colors.green),
          _kpiCard('Nombre Transactions', count.toString(), Icons.swap_horiz_rounded, Colors.blue),
          _kpiCard('Versement Moyen', '${NumberFormat('#,###').format(avg)} \$', Icons.analytics_rounded, Colors.orange),
        ],
      );
    });
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(List<Map<String, dynamic>> payments, AsyncValue<List<PromotionEntity>> promosAsync) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 35, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(35),
            child: Text('JOURNAL GÉNÉRAL DES PAIEMENTS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1)),
          ),
          promosAsync.when(
            data: (promos) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                dividerThickness: 1,
                columns: const [
                  DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                  DataColumn(label: Text('MATRICULE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                  DataColumn(label: Text('ÉTUDIANT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                  DataColumn(label: Text('PROMOTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                  DataColumn(label: Text('MONTANT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                ],
                rows: payments.map((p) {
                  final PromotionEntity? promo = promos.where((pr) => pr.stableId == p['id_promo']?.toString()).firstOrNull;
                  final DateTime date = (p['date_paiement'] as dynamic)?.toDate() ?? DateTime.now();
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(date))),
                    DataCell(Text(p['matricule_etu'] ?? '?')),
                    DataCell(Text(p['nom_etu']?.toString().toUpperCase() ?? '?', style: const TextStyle(fontWeight: FontWeight.w800))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(6)),
                      child: Text(promo?.nomPromo ?? '?', style: const TextStyle(color: Color(0xFFC2410C), fontSize: 11, fontWeight: FontWeight.w900)),
                    )),
                    DataCell(Text('+ ${NumberFormat('#,###').format(p['montant_paye'])} \$', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w900))),
                  ]);
                }).toList(),
              ),
            ),
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (_, __) => const Text("Err promos"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
