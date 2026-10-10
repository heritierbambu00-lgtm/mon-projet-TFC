import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/academic/domain/entities/departement_entity.dart';
import 'package:istm_mahagi/features/academic/domain/entities/promotion_entity.dart';

class SystemConfigPage extends ConsumerStatefulWidget {
  const SystemConfigPage({super.key});

  @override
  ConsumerState<SystemConfigPage> createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends ConsumerState<SystemConfigPage> {
  final TextEditingController _globalThresholdController = TextEditingController();
  final TextEditingController _currentYearController = TextEditingController();
  final Map<String, TextEditingController> _promoControllers = {};
  bool _isApplyingGlobal = false;
  bool _isSavingYear = false;

  @override
  void dispose() {
    _globalThresholdController.dispose();
    _currentYearController.dispose();
    for (var c in _promoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCurrentYear() async {
    final year = _currentYearController.text.trim();
    if (year.isEmpty) return;

    setState(() => _isSavingYear = true);
    try {
      await ref.read(academicRepositoryProvider).setCurrentAcademicYear(year);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Année académique mise à jour !'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSavingYear = false);
    }
  }

  Future<void> _toggleResults(DepartementEntity dept) async {
    await ref.read(academicRepositoryProvider).updateDepartmentConfig(dept.id, {
      'resultats_ouverts': !dept.resultatsOuverts,
    });
  }

  Future<void> _toggleEval(DepartementEntity dept) async {
    await ref.read(academicRepositoryProvider).updateDepartmentConfig(dept.id, {
      'eval_profs_ouverte': !dept.evalProfsOuverte,
    });
  }

  Future<void> _applyGlobalThreshold() async {
    final double val = double.tryParse(_globalThresholdController.text.trim()) ?? 0;
    if (val <= 0) return;

    setState(() => _isApplyingGlobal = true);
    try {
      final promos = ref.read(promotionsProvider).value ?? [];
      for (var p in promos) {
        await ref.read(academicRepositoryProvider).updatePromotionThreshold(p.id, val);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seuil de $val \$ appliqué à toutes les promotions !'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isApplyingGlobal = false);
    }
  }

  Future<void> _savePromoThreshold(String id, String text) async {
    final double val = double.tryParse(text) ?? 0;
    await ref.read(academicRepositoryProvider).updatePromotionThreshold(id, val);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seuil mis à jour.'), backgroundColor: Colors.blue));
  }

  @override
  Widget build(BuildContext context) {
    final departmentsAsync = ref.watch(departmentsProvider);
    final promotionsAsync = ref.watch(promotionsProvider);
    final currentYearAsync = ref.watch(currentAcademicYearProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('CONFIGURATION SYSTÈME', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 35),
                const Text('1. PARAMÈTRES GLOBAUX DU SYSTÈME', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 15),
                _buildGlobalSettingsCard(currentYearAsync),
                const SizedBox(height: 45),
                const Text('2. ACTIVATION DES SERVICES PAR DÉPARTEMENT', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 15),
                departmentsAsync.when(
                  data: (list) {
                    if (list.isEmpty) return const Text('Aucun département trouvé.');
                    return Column(
                      children: list.map((dept) => _buildDeptConfigCard(dept)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erreur: $e'),
                ),
                const SizedBox(height: 45),
                const Text('3. GESTION DES SEUILS FINANCIERS', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 15),
                _buildGlobalThresholdTool(),
                const SizedBox(height: 25),
                promotionsAsync.when(
                  data: (list) => Column(
                    children: list.map((p) => _buildPromoThresholdCard(p)).toList(),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erreur promos: $e'),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚖️ Paramètres de Blocage & Activation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          SizedBox(height: 5),
          Text('Configurez les conditions d\'accès aux résultats semestriels.', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGlobalSettingsCard(AsyncValue<String> currentYearAsync) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ANNÉE ACADÉMIQUE COURANTE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 0.5)),
          const SizedBox(height: 15),
          currentYearAsync.when(
            data: (year) {
              if (_currentYearController.text.isEmpty) {
                _currentYearController.text = year;
              }
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currentYearController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Ex: 2025-2026',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: _isSavingYear ? null : _saveCurrentYear,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isSavingYear ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('METTRE À JOUR'),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: $e'),
          ),
          const SizedBox(height: 10),
          const Text('Cette année sera utilisée par défaut pour la saisie des notes.', style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGlobalThresholdTool() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Action Groupée : Fixer un seuil pour TOUTE L\'INSTITUTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E))),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _globalThresholdController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(hintText: 'Montant en USD (ex: 200)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: _isApplyingGlobal ? null : _applyGlobalThreshold,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: _isApplyingGlobal ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('APPLIQUER PARTOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoThresholdCard(PromotionEntity promo) {
    // On initialise avec la valeur actuelle du seuil si elle existe
    final controller = _promoControllers.putIfAbsent(promo.id, () {
      return TextEditingController(text: promo.seuilFinance > 0 ? promo.seuilFinance.toString() : ''); 
    });

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.nomPromo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const Text('Seuil financier requis pour les résultats', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A2A6C)),
              decoration: InputDecoration(suffixText: '\$', contentPadding: const EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ),
          const SizedBox(width: 15),
          IconButton(
            icon: const Icon(Icons.save_as_rounded, color: AppColors.primaryBlue),
            onPressed: () => _savePromoThreshold(promo.id, controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptConfigCard(DepartementEntity dept) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dept.nomDept.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 0.5)),
          const SizedBox(height: 25),
          _buildToggleRow(
            '🎓 Consultation des Résultats',
            'Ouvre l\'accès aux cotes pour les étudiants de ce département.',
            dept.resultatsOuverts,
            () => _toggleResults(dept),
          ),
          const Divider(height: 40),
          _buildToggleRow(
            '⚖️ Évaluations des Enseignants',
            'Force l\'étudiant à évaluer ses cours avant de voir ses notes.',
            dept.evalProfsOuverte,
            () => _toggleEval(dept),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String desc, bool isActive, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.3)),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Switch(
          value: isActive,
          onChanged: (_) => onTap(),
          activeColor: AppColors.primaryBlue,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isActive ? 'ACTIF' : 'BLOQUÉ',
            style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
