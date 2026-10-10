import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';

class StudentSituationPage extends ConsumerStatefulWidget {
  const StudentSituationPage({super.key});

  @override
  ConsumerState<StudentSituationPage> createState() => _StudentSituationPageState();
}

class _StudentSituationPageState extends ConsumerState<StudentSituationPage> {
  final TextEditingController _searchController = TextEditingController();
  EtudiantEntity? _student;
  Map<String, dynamic>? _config;
  List<Map<String, dynamic>> _payments = [];
  bool _isSearching = false;

  Future<void> _fetchSituation() async {
    final search = _searchController.text.trim();
    if (search.isEmpty) return;

    setState(() {
      _isSearching = true;
      _student = null;
      _config = null;
      _payments = [];
    });

    try {
      final student = await ref.read(academicRepositoryProvider).findStudentByMatricule(search);
      if (student != null) {
        final config = await ref.read(academicRepositoryProvider).getStudentFraisConfig(student.idPromo).first;
        final payments = await ref.read(academicRepositoryProvider).getStudentPayments(student.id).first;
        
        setState(() {
          _student = student;
          _config = config;
          _payments = payments;
        });
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Étudiant introuvable."), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('SITUATION FINANCIÈRE ÉTUDIANT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildSearchBox(),
                if (_student != null) ...[
                  const SizedBox(height: 35),
                  _buildProfileCard(),
                  const SizedBox(height: 35),
                  _buildHistoryCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Saisir Matricule ou Nom...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _fetchSituation(),
            ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _fetchSituation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isSearching ? const CircularProgressIndicator(color: Colors.white) : const Text('RECHERCHER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    double totalPaid = 0;
    for (var p in _payments) totalPaid += (p['montant_paye'] ?? 0);
    final double fixe = (_config?['montant_total'] ?? 0).toDouble();
    final double reste = fixe - totalPaid;

    return Container(
      padding: const EdgeInsets.all(40),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_student!.nomEtu.toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 5),
                  Text('Matricule : ${_student!.matriculeEtu}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Divider(),
          const SizedBox(height: 30),
          Row(
            children: [
              _metric('FIXÉS', fixe, const Color(0xFF0F172A)),
              _metric('VERSÉS', totalPaid, const Color(0xFF16A34A)),
              _metric('SOLDE', reste, reste > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, double val, Color col) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 5),
          Text('${NumberFormat('#,###').format(val)} \$', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: col)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(30),
            child: Text('HISTORIQUE DES TRANSACTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
          ),
          if (_payments.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Aucun paiement enregistré.')))
          else
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                columns: const [
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('MOTIF')),
                  DataColumn(label: Text('MONTANT')),
                ],
                rows: _payments.map((p) {
                  final date = (p['date_paiement'] as dynamic)?.toDate() ?? DateTime.now();
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(date))),
                    DataCell(Text(p['type_frais'] ?? 'Frais')),
                    DataCell(Text('+ ${NumberFormat('#,###').format(p['montant_paye'])} \$', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
