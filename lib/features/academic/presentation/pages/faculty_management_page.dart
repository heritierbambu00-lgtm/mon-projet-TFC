import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/academic_providers.dart';
import '../../domain/entities/faculte_entity.dart';
import '../../domain/entities/departement_entity.dart';
import '../../domain/entities/promotion_entity.dart';

class FacultyManagementPage extends ConsumerStatefulWidget {
  const FacultyManagementPage({super.key});

  @override
  ConsumerState<FacultyManagementPage> createState() => _FacultyManagementPageState();
}

class _FacultyManagementPageState extends ConsumerState<FacultyManagementPage> {
  final TextEditingController _faculteController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _promoYearController = TextEditingController();
  
  String? _selectedFaculteId;
  String? _selectedDeptId;

  Future<void> _addFaculte() async {
    if (_faculteController.text.isEmpty) return;
    await ref.read(academicRepositoryProvider).addFaculty(_faculteController.text.trim());
    _faculteController.clear();
  }

  Future<void> _addDept() async {
    if (_deptController.text.isEmpty || _selectedFaculteId == null) return;
    await ref.read(academicRepositoryProvider).addDepartment(_deptController.text.trim(), _selectedFaculteId!);
    _deptController.clear();
  }

  Future<void> _addPromo(String currentYear) async {
    if (_promoController.text.isEmpty || _selectedDeptId == null) return;
    final year = _promoYearController.text.trim().isEmpty ? currentYear : _promoYearController.text.trim();
    await ref.read(academicRepositoryProvider).addPromotion(
      _promoController.text.trim(), 
      _selectedDeptId!,
      anneeAcad: year,
    );
    _promoController.clear();
  }

  void _confirmDelete(String title, String id, Future<void> Function(String) deleteFn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Attention', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Voulez-vous vraiment supprimer définitivement "$title" ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await deleteFn(id);
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Élément supprimé avec succès.')));
            }, 
            child: const Text('SUPPRIMER DÉFINITIVEMENT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _editFaculte(FaculteEntity f) {
    final controller = TextEditingController(text: f.nomFaculte);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Modifier la Faculté', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nom de la faculté'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(academicRepositoryProvider).updateFaculty(f.id, controller.text.trim());
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculté modifiée avec succès.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            child: const Text('ENREGISTRER'),
          ),
        ],
      ),
    );
  }

  void _editDept(DepartementEntity d, List<FaculteEntity> faculties) {
    final controller = TextEditingController(text: d.nomDept);
    String? selectedFacId = d.idFaculte.isNotEmpty ? d.idFaculte : null;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Modifier le Département', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFacId,
                hint: const Text('-- Faculté Parente --'),
                items: faculties.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nomFaculte, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setModalState(() => selectedFacId = v),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Nom du département'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty || selectedFacId == null) return;
                await ref.read(academicRepositoryProvider).updateDepartment(d.id, controller.text.trim(), selectedFacId!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Département modifié avec succès.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
  }

  void _editPromo(PromotionEntity p, List<DepartementEntity> depts) {
    final nameController = TextEditingController(text: p.nomPromo);
    final yearController = TextEditingController(text: p.anneeAcad ?? '');
    String? selectedDept = p.idDept.isNotEmpty ? p.idDept : null;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Modifier la Promotion', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDept,
                hint: const Text('-- Département Parent --'),
                items: depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.nomDept, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setModalState(() => selectedDept = v),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Intitulé de la promotion'),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Année Académique'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || selectedDept == null) return;
                await ref.read(academicRepositoryProvider).updatePromotion(
                  p.id, 
                  nameController.text.trim(), 
                  selectedDept!,
                  anneeAcad: yearController.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promotion modifiée avec succès.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facultiesAsync = ref.watch(facultiesProvider);
    final departmentsAsync = ref.watch(departmentsProvider);
    final promotionsAsync = ref.watch(promotionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('ARCHITECTURE ACADÉMIQUE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Column(
          children: [
            _buildTopBanner(),
            const SizedBox(height: 35),
            Responsive(
              mobile: Column(
                children: [
                  _buildFaculteCard(facultiesAsync),
                  const SizedBox(height: 25),
                  _buildDeptCard(facultiesAsync, departmentsAsync),
                  const SizedBox(height: 25),
                  _buildPromoCard(departmentsAsync, promotionsAsync),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildFaculteCard(facultiesAsync)),
                  const SizedBox(width: 25),
                  Expanded(child: _buildDeptCard(facultiesAsync, departmentsAsync)),
                  const SizedBox(width: 25),
                  Expanded(child: _buildPromoCard(departmentsAsync, promotionsAsync)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Console de Structure Universitaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text('Gestion des niveaux hiérarchiques et de l\'auto-incrémentation', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: const Text('AUTO-ID ACTIVÉ', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildFaculteCard(AsyncValue<List<FaculteEntity>> facultiesAsync) {
    return _buildCard(
      title: 'Niveau 1 : Facultés',
      icon: Icons.account_balance,
      accentColor: const Color(0xFF0F172A),
      form: Column(
        children: [
          _buildInput(_faculteController, 'Nom de la faculté'),
          _buildSubmitBtn('Ajouter Faculté', const Color(0xFF0F172A), _addFaculte),
        ],
      ),
      list: facultiesAsync.when(
        data: (list) => Column(
          children: list.map((f) => _buildListItem(
            f.nomFaculte, 
            onEdit: () => _editFaculte(f),
            onRemove: () => _confirmDelete(f.nomFaculte, f.id, ref.read(academicRepositoryProvider).deleteFaculty)
          )).toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Erreur: $e'),
      ),
    );
  }

  Widget _buildDeptCard(AsyncValue<List<FaculteEntity>> facultiesAsync, AsyncValue<List<DepartementEntity>> departmentsAsync) {
    return _buildCard(
      title: 'Niveau 2 : Départements',
      icon: Icons.business_rounded,
      accentColor: AppColors.primaryBlue,
      form: Column(
        children: [
          facultiesAsync.when(
            data: (list) => _buildDropdown(
              hint: '-- Faculté Parente --',
              value: _selectedFaculteId,
              items: list.map((f) => DropdownMenuItem<String>(value: f.id, child: Text(f.nomFaculte, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
              onChanged: (v) => setState(() => _selectedFaculteId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
          ),
          _buildInput(_deptController, 'Nom du département'),
          _buildSubmitBtn('Ajouter Département', AppColors.primaryBlue, _addDept),
        ],
      ),
      list: departmentsAsync.when(
        data: (list) {
          final faculties = facultiesAsync.value ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: faculties.map((f) {
              final depts = list.where((d) => d.idFaculte == f.id).toList();
              if (depts.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 8),
                    child: Text('📍 ${f.nomFaculte.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                  ),
                  ...depts.map((d) => _buildListItem(
                    d.nomDept, 
                    onEdit: () => _editDept(d, faculties),
                    onRemove: () => _confirmDelete(d.nomDept, d.id, ref.read(academicRepositoryProvider).deleteDepartment)
                  )),
                ],
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Erreur: $e'),
      ),
    );
  }

  Widget _buildPromoCard(AsyncValue<List<DepartementEntity>> departmentsAsync, AsyncValue<List<PromotionEntity>> promotionsAsync) {
    final currentYear = ref.watch(currentAcademicYearProvider).value ?? '2025-2026';
    if (_promoYearController.text.isEmpty) {
      _promoYearController.text = currentYear;
    }

    return _buildCard(
      title: 'Niveau 3 : Promotions',
      icon: Icons.school_rounded,
      accentColor: const Color(0xFF10B981),
      form: Column(
        children: [
          departmentsAsync.when(
            data: (list) => _buildDropdown(
              hint: '-- Département Parent --',
              value: _selectedDeptId,
              items: list.map((d) => DropdownMenuItem<String>(value: d.id, child: Text(d.nomDept, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
              onChanged: (v) => setState(() => _selectedDeptId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
          ),
          _buildInput(_promoController, 'Intitulé (ex: L1 IAGE)'),
          _buildInput(_promoYearController, 'Année Académique (ex: 2025-2026)'),
          _buildSubmitBtn('Ajouter Promotion', const Color(0xFF10B981), () => _addPromo(currentYear)),
        ],
      ),
      list: promotionsAsync.when(
        data: (list) {
          final depts = departmentsAsync.value ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: depts.map((d) {
              final promos = list.where((p) => p.idDept == d.id).toList();
              if (promos.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 8),
                    child: Text('📂 ${d.nomDept.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF10B981), letterSpacing: 1)),
                  ),
                  ...promos.map((p) {
                    final yearLabel = (p.anneeAcad != null && p.anneeAcad!.isNotEmpty) ? " • ${p.anneeAcad}" : "";
                    return _buildListItem(
                      "${p.nomPromo}$yearLabel (ID: ${p.stableId})", 
                      isBold: true, 
                      onEdit: () => _editPromo(p, depts),
                      onRemove: () => _confirmDelete(p.nomPromo, p.id, ref.read(academicRepositoryProvider).deletePromotion)
                    );
                  }),
                ],
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Erreur: $e'),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Color accentColor, required Widget form, required Widget list}) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 25),
          form,
          const SizedBox(height: 20),
          const Divider(thickness: 1, height: 40, color: Color(0xFFF1F5F9)),
          Container(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(child: list),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(hint, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
            value: value,
            items: items,
            onChanged: onChanged,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitBtn(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 8,
          shadowColor: color.withOpacity(0.4),
        ),
        child: Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildListItem(String text, {bool isBold = false, required VoidCallback onRemove, VoidCallback? onEdit}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: const Color(0xFF334155)))),
          if (onEdit != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue, size: 22),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Modifier cet élément',
            ),
            const SizedBox(width: 10),
          ],
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Supprimer cet élément',
          ),
        ],
      ),
    );
  }
}
