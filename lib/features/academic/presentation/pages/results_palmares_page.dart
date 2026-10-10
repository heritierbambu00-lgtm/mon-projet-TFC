import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/academic_providers.dart';
import '../../domain/entities/promotion_entity.dart';

class ResultsPalmaresPage extends ConsumerStatefulWidget {
  const ResultsPalmaresPage({super.key});

  @override
  ConsumerState<ResultsPalmaresPage> createState() => _ResultsPalmaresPageState();
}

class _ResultsPalmaresPageState extends ConsumerState<ResultsPalmaresPage> {
  String? _selectedPromoId;

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(promotionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PALMARÈS DES RÉSULTATS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1, color: Color(0xFF0F172A))),
            Text('Tableau analytique des performances par promotion', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 85,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded, color: AppColors.primaryBlue),
            onPressed: () {},
            tooltip: 'Exporter en PDF',
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                _buildHeaderBar(promosAsync),
                const SizedBox(height: 40),
                _buildSummaryStats(),
                const SizedBox(height: 50),
                _buildEmptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Row(
      children: [
        _miniStatCard('Taux de Réussite', '0%', Icons.analytics_rounded, Colors.green),
        const SizedBox(width: 20),
        _miniStatCard('Étudiants Inscrits', '0', Icons.people_rounded, AppColors.primaryBlue),
        const SizedBox(width: 20),
        _miniStatCard('Moyenne Générale', '0.0', Icons.star_rounded, Colors.orange),
      ],
    );
  }

  Widget _miniStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
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
              children: [
                Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepNavy, fontFamily: 'Playfair Display')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(AsyncValue<List<PromotionEntity>> promosAsync) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtrer le Palmarès', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),
          promosAsync.when(
            data: (list) => DropdownButtonFormField<String>(
              value: _selectedPromoId,
              hint: const Text("-- Choisissez une promotion --"),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p.id, child: Text(p.nomPromo))).toList(),
              onChanged: (v) => setState(() => _selectedPromoId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.bar_chart_outlined, size: 100, color: Colors.grey),
        const SizedBox(height: 25),
        const Text(
          'Aucune donnée trouvée',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        const Text(
          'Aucune note n\'a encore été saisie pour les critères sélectionnés.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
