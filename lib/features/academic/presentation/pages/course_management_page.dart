import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/academic_providers.dart';
import '../../domain/entities/cours_entity.dart';
import '../../../auth/domain/entities/enseignant_entity.dart';

class CourseManagementPage extends ConsumerStatefulWidget {
  const CourseManagementPage({super.key});

  @override
  ConsumerState<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends ConsumerState<CourseManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _intituleController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String? _selectedPromoId;
  String? _selectedEnsId;
  String _selectedSemestre = 'S1';
  bool _isSaving = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedPromoId == null || _selectedEnsId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs."), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(academicRepositoryProvider).addCourse({
        'code_cours': _codeController.text.trim().toUpperCase(),
        'intitule_cours': _intituleController.text.trim(),
        'credits': int.tryParse(_creditsController.text) ?? 1,
        'id_promo': _selectedPromoId,
        'id_ens': _selectedEnsId,
        'annee_academique': _yearController.text.trim(),
        'semestre': _selectedSemestre,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cours ajouté avec succès !"), backgroundColor: Colors.green));
        _codeController.clear();
        _intituleController.clear();
        _creditsController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDelete(CoursEntity course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Supprimer définitivement le cours "${course.intituleCours}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          TextButton(
            onPressed: () async {
              await ref.read(academicRepositoryProvider).deleteCourse(course.id);
              if (mounted) Navigator.pop(context);
            }, 
            child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(CoursEntity course, List<Map<String, dynamic>> promos, List<EnseignantEntity> teachers) {
    final codeCtrl = TextEditingController(text: course.codeCours);
    final intituleCtrl = TextEditingController(text: course.intituleCours);
    final creditsCtrl = TextEditingController(text: course.credits.toString());
    final yearCtrl = TextEditingController(text: course.anneeAcad ?? '');
    String selectedSem = course.semestre.isNotEmpty ? course.semestre : 'S1';
    String? selectedPromo = course.idPromo.isNotEmpty ? course.idPromo : null;
    String? selectedEns = course.idEns.isNotEmpty ? course.idEns : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Modifier le Cours", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "Code UE")),
                const SizedBox(height: 10),
                TextField(controller: intituleCtrl, decoration: const InputDecoration(labelText: "Intitulé de l'EC")),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: creditsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Crédits"))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: yearCtrl, decoration: const InputDecoration(labelText: "Année Acad."))),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedSem,
                  decoration: const InputDecoration(labelText: "Semestre"),
                  items: const [
                    DropdownMenuItem(value: 'S1', child: Text("Semestre 1")),
                    DropdownMenuItem(value: 'S2', child: Text("Semestre 2")),
                  ],
                  onChanged: (v) => setModalState(() => selectedSem = v!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedPromo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: "Promotion Cible"),
                  items: promos.map((p) => DropdownMenuItem<String>(value: p['stableId'].toString(), child: Text(p['label'], style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setModalState(() => selectedPromo = v),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedEns,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: "Enseignant Titulaire"),
                  items: teachers.map((t) => DropdownMenuItem<String>(value: t.id, child: Text("${t.nomEns} ${t.postnomEns}"))).toList(),
                  onChanged: (v) => setModalState(() => selectedEns = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (codeCtrl.text.trim().isEmpty || intituleCtrl.text.trim().isEmpty) return;
                await ref.read(academicRepositoryProvider).updateCourse(course.id, {
                  'code_cours': codeCtrl.text.trim().toUpperCase(),
                  'intitule_cours': intituleCtrl.text.trim(),
                  'credits': int.tryParse(creditsCtrl.text) ?? 1,
                  'annee_academique': yearCtrl.text.trim(),
                  'semestre': selectedSem,
                  if (selectedPromo != null) 'id_promo': selectedPromo,
                  if (selectedEns != null) 'id_ens': selectedEns,
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cours modifié avec succès !"), backgroundColor: Colors.green));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              child: const Text("ENREGISTRER"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final promosWithDetailsAsync = ref.watch(promotionsWithDetailsProvider);
    final teachersAsync = ref.watch(teachersProvider);
    final currentYearAsync = ref.watch(currentAcademicYearProvider);
    final bool isMobile = Responsive.isMobile(context);

    // Initialisation de l'année courante si vide
    currentYearAsync.whenData((year) {
      if (_yearController.text.isEmpty) {
        _yearController.text = year;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('GESTION DU PROGRAMME ACADÉMIQUE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
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
                  _buildFormCard(promosWithDetailsAsync, teachersAsync),
                  const SizedBox(height: 30),
                  _buildListCard(coursesAsync, promosWithDetailsAsync, teachersAsync, true),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildFormCard(promosWithDetailsAsync, teachersAsync)),
                  const SizedBox(width: 35),
                  Expanded(flex: 3, child: _buildListCard(coursesAsync, promosWithDetailsAsync, teachersAsync, false)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(AsyncValue promosAsync, AsyncValue teachersAsync) {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("NOUVEAU COURS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
            const SizedBox(height: 30),
            _buildInput(_codeController, "Code UE (ex: LMD101)", Icons.qr_code_rounded),
            _buildInput(_intituleController, "Intitulé de l'EC", Icons.book_rounded),
            Row(
              children: [
                Expanded(child: _buildInput(_creditsController, "Crédits", Icons.star_outline_rounded, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildInput(_yearController, "Année Acad.", Icons.event_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              "Semestre",
              const [
                DropdownMenuItem(value: 'S1', child: Text("Semestre 1", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DropdownMenuItem(value: 'S2', child: Text("Semestre 2", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              ],
              _selectedSemestre,
              (v) => setState(() => _selectedSemestre = v!),
            ),
            const SizedBox(height: 15),
            promosAsync.when(
              data: (list) => _buildDropdown(
                "Promotion Cible", 
                list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p['stableId'].toString(), child: Text(p['label'], style: const TextStyle(fontSize: 12)))).toList(),
                _selectedPromoId,
                (v) => setState(() => _selectedPromoId = v)
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Err promos"),
            ),
            const SizedBox(height: 15),
            teachersAsync.when(
              data: (list) => _buildDropdown(
                "Enseignant Titulaire", 
                list.map<DropdownMenuItem<String>>((EnseignantEntity t) => DropdownMenuItem(value: t.id, child: Text("${t.nomEns} ${t.postnomEns}"))).toList(),
                _selectedEnsId,
                (v) => setState(() => _selectedEnsId = v)
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Err enseignants"),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("AJOUTER AU PROGRAMME", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(AsyncValue<List<CoursEntity>> coursesAsync, AsyncValue promosAsync, AsyncValue teachersAsync, bool isMobile) {
    final promosList = (promosAsync.value as List<Map<String, dynamic>>?) ?? [];
    final teachersList = (teachersAsync.value as List<EnseignantEntity>?) ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(35),
            child: Text("LISTE DES ENSEIGNEMENTS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
          ),
          coursesAsync.when(
            data: (list) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                columns: const [
                  DataColumn(label: Text('CODE')),
                  DataColumn(label: Text('INTITULÉ')),
                  DataColumn(label: Text('CRÉDITS')),
                  DataColumn(label: Text('SEMESTRE')),
                  DataColumn(label: Text('ANNÉE')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: list.map((c) => DataRow(
                  cells: [
                    DataCell(Text(c.codeCours, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(c.intituleCours)),
                    DataCell(Text(c.credits.toString())),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.semestre == 'S2' ? Colors.purple.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.semestre == 'S2' ? 'Semestre 2' : 'Semestre 1', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: c.semestre == 'S2' ? Colors.purple : Colors.teal),
                      ),
                    )),
                    DataCell(Text(c.anneeAcad ?? '-', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11))),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blue), onPressed: () => _showEditCourseDialog(c, promosList, teachersList)),
                        IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent), onPressed: () => _confirmDelete(c)),
                      ],
                    )),
                  ],
                )).toList(),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Err: $e"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v!.isEmpty ? "Requis" : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<DropdownMenuItem<String>> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
