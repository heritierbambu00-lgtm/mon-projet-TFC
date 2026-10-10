import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';

class CollectFeesPage extends ConsumerStatefulWidget {
  const CollectFeesPage({super.key});

  @override
  ConsumerState<CollectFeesPage> createState() => _CollectFeesPageState();
}

class _CollectFeesPageState extends ConsumerState<CollectFeesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  EtudiantEntity? _selectedStudent;
  Map<String, dynamic>? _fraisConfig;
  double _totalPaye = 0;
  bool _isSearching = false;
  bool _isSaving = false;

  Future<void> _searchStudent() async {
    final search = _searchController.text.trim();
    if (search.isEmpty) return;

    setState(() {
      _isSearching = true;
      _selectedStudent = null;
      _fraisConfig = null;
      _totalPaye = 0;
    });

    try {
      final student = await ref.read(academicRepositoryProvider).findStudentByMatricule(search);
      if (student != null) {
        // Load config and payments
        final config = await ref.read(academicRepositoryProvider).getStudentFraisConfig(student.idPromo).first;
        final payments = await ref.read(academicRepositoryProvider).getStudentPayments(student.id).first;
        
        double paid = 0;
        for (var p in payments) paid += (p['montant_paye'] ?? 0);

        setState(() {
          _selectedStudent = student;
          _fraisConfig = config;
          _totalPaye = paid;
        });
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aucun étudiant trouvé."), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _validatePayment() async {
    if (_selectedStudent == null || _amountController.text.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final double montant = double.tryParse(_amountController.text.trim()) ?? 0;
      if (montant <= 0) throw "Montant invalide";

      await ref.read(academicRepositoryProvider).recordPayment({
        'id_etu': _selectedStudent!.id,
        'matricule_etu': _selectedStudent!.matriculeEtu,
        'nom_etu': _selectedStudent!.nomEtu,
        'id_promo': _selectedStudent!.idPromo,
        'montant_paye': montant,
        'type_frais': 'Frais Académiques',
        'annee_acad': _fraisConfig?['annee_acad'] ?? '2025-2026',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Encaissement validé avec succès !"), backgroundColor: Colors.green));
        _amountController.clear();
        _searchStudent(); // Refresh data
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('PERCEVOIR ET ENCAISSER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Responsive(
              mobile: Column(
                children: [
                  _buildSearchCard(),
                  const SizedBox(height: 30),
                  _buildPaymentCard(),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSearchCard()),
                  const SizedBox(width: 35),
                  Expanded(child: _buildPaymentCard()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
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
          _sectionTitle(Icons.person_search_rounded, 'IDENTIFICATION ÉTUDIANT'),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: _inputDecoration(hint: 'Matricule...'),
                  onSubmitted: (_) => _searchStudent(),
                ),
              ),
              const SizedBox(width: 15),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSearching ? null : _searchStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSearching ? const CircularProgressIndicator(color: Colors.white) : const Text('VÉRIFIER', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          if (_selectedStudent != null) ...[
            const SizedBox(height: 35),
            const Divider(),
            const SizedBox(height: 20),
            Text('${_selectedStudent!.nomEtu} ${_selectedStudent!.prenomEtu}'.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),
            const SizedBox(height: 15),
            _buildStatLine('Matricule :', _selectedStudent!.matriculeEtu),
            _buildStatLine('Frais Globaux :', '${NumberFormat('#,###.00').format(_fraisConfig?['montant_total'] ?? 0)} \$'),
            _buildStatLine('Total Déjà Versé :', '${NumberFormat('#,###.00').format(_totalPaye)} \$', color: Colors.green),
            const Divider(),
            _buildStatLine('Reste à payer :', '${NumberFormat('#,###.00').format((_fraisConfig?['montant_total'] ?? 0) - _totalPaye)} \$', color: Colors.red, isLarge: true),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
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
          _sectionTitle(Icons.account_balance_wallet_rounded, 'ENREGISTRER LE VERSEMENT'),
          const SizedBox(height: 30),
          const Text('TYPE DE FRAIS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 10),
          TextField(
            enabled: false,
            decoration: _inputDecoration(hint: 'Frais Académiques'),
          ),
          const SizedBox(height: 20),
          const Text('MONTANT À ENCAISSER (\$)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            enabled: _selectedStudent != null,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.green),
            decoration: _inputDecoration(hint: 'Ex: 150.00'),
          ),
          const SizedBox(height: 45),
          SizedBox(
            width: double.infinity,
            height: 70,
            child: ElevatedButton(
              onPressed: (_selectedStudent == null || _isSaving) ? null : _validatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                shadowColor: Colors.green.withOpacity(0.4),
              ),
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('VALIDER L\'ENCAISSEMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
            ),
          ),
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

  Widget _buildStatLine(String label, String value, {Color? color, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: isLarge ? 18 : 14)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
  );
}
