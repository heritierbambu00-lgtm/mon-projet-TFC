import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';

class FinanceTrackingPage extends StatelessWidget {
  const FinanceTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Suivi Financier', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryKPIs(context),
            const SizedBox(height: 30),
            _buildChartSection(context),
            const SizedBox(height: 30),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryKPIs(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.isMobile(context) ? 1 : 3,
      childAspectRatio: 2.5,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _buildKPICard('Revenus Totaux', '124,500 \$', Icons.trending_up, Colors.green),
        _buildKPICard('Dépenses', '45,200 \$', Icons.trending_down, Colors.red),
        _buildKPICard('Balance Net', '79,300 \$', Icons.account_balance_wallet, AppColors.primaryBlue),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Évolution des Recettes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: 'Mensuel',
                  items: ['Hebdo', 'Mensuel', 'Annuel'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 60, color: Colors.grey),
                    Text('Graphique Interactif (Simulation)', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transactions Récentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: index.isEven ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Icon(index.isEven ? Icons.arrow_downward : Icons.arrow_upward, 
                    color: index.isEven ? Colors.green : Colors.red, size: 18),
                ),
                title: Text(index.isEven ? 'Frais Académiques - L1' : 'Maintenance Laboratoire'),
                subtitle: const Text('14 Août 2026 • 12:45'),
                trailing: Text('${index.isEven ? "+" : "-"}${250 * (index + 1)} \$', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: index.isEven ? Colors.green : Colors.red)),
              ),
            );
          },
        ),
      ],
    );
  }
}
