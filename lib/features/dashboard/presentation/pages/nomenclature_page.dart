import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';

class NomenclaturePage extends ConsumerStatefulWidget {
  const NomenclaturePage({super.key});

  @override
  ConsumerState<NomenclaturePage> createState() => _NomenclaturePageState();
}

class _NomenclaturePageState extends ConsumerState<NomenclaturePage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedYear = '2025-2026';
  String? _selectedPromoId;
  bool _isSaving = false;

  Future<void> _saveConfig() async {
    if (_selectedPromoId == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Remplissez tous les champs."), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final double montant = double.tryParse(_amountController.text.trim()) ?? 0;
      
      await ref.read(academicRepositoryProvider).saveFraisConfig({
        'id_promo': _selectedPromoId,
        'annee_acad': _selectedYear,
        'montant_total': montant,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nomenclature configurée avec succès !"), backgroundColor: Colors.green));
        _amountController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosWithDetailsAsync = ref.watch(promotionsWithDetailsProvider);
    final grilleFraisAsync = ref.watch(fraisGrilleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('FIXER LA NOMENCLATURE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Responsive(
              mobile: Column(
                children: [
                  _buildFormCard(promosWithDetailsAsync),
                  const SizedBox(height: 30),
                  _buildGrilleCard(grilleFraisAsync, promosWithDetailsAsync),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildFormCard(promosWithDetailsAsync)),
                  const SizedBox(width: 35),
                  Expanded(flex: 3, child: _buildGrilleCard(grilleFraisAsync, promosWithDetailsAsync)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(AsyncValue<List<Map<String, dynamic>>> promosAsync) {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.settings_suggest_rounded, 'CONFIGURATION DES TARIFS'),
          const SizedBox(height: 30),
          _buildLabel('Année Académique'),
          DropdownButtonFormField<String>(
            value: _selectedYear,
            decoration: _inputDecoration(),
            items: ['2024-2025', '2025-2026', '2026-2027', '2027-2028'].map<DropdownMenuItem<String>>((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
            onChanged: (v) => setState(() => _selectedYear = v!),
          ),
          const SizedBox(height: 20),
          _buildLabel('Promotion Cible'),
          promosAsync.when(
            data: (list) => DropdownButtonFormField<String>(
              value: _selectedPromoId,
              hint: const Text('-- Choisir la promotion --'),
              decoration: _inputDecoration(),
              items: list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p['stableId'].toString(), child: Text(p['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
              onChanged: (v) => setState(() => _selectedPromoId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Erreur chargement'),
          ),
          const SizedBox(height: 20),
          _buildLabel('Montant Total Exigé (\$)'),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFFD97706)),
            decoration: _inputDecoration(hint: 'Ex: 460.00'),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
              ),
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('ENREGISTRER LA CONFIGURATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrilleCard(AsyncValue<List<Map<String, dynamic>>> grilleAsync, AsyncValue<List<Map<String, dynamic>>> promosAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(35),
            child: _sectionTitle(Icons.grid_view_rounded, 'GRILLE TARIFAIRE ENREGISTRÉE'),
          ),
          grilleAsync.when(
            data: (configs) => promosAsync.when(
              data: (promos) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('ANNÉE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                    DataColumn(label: Text('PROMOTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                    DataColumn(label: Text('MONTANT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey))),
                  ],
                  rows: configs.map((c) {
                    final Map<String, dynamic> promo = promos.firstWhere(
                      (p) => p['stableId'].toString() == c['id_promo'].toString(), 
                      orElse: () => <String, dynamic>{'nom': '?'}
                    );
                    return DataRow(cells: [
                      DataCell(Text(c['annee_acad'] ?? '?', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(promo['nom'] ?? '?', style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text('${NumberFormat('#,###', 'fr_FR').format(c['montant_total'])} \$', style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w900))),
                    ]);
                  }).toList(),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erreur promos'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur grille: $e')),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0F172A), size: 22),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A), letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1)));

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
  );
}
