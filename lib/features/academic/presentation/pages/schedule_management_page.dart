import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/academic_providers.dart';
import '../../domain/entities/horaire_entity.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/cours_entity.dart';

class ScheduleManagementPage extends ConsumerStatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  ConsumerState<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends ConsumerState<ScheduleManagementPage> {
  String? _selectedPromoId;
  String? _selectedCourseId;
  DateTime? _selectedDate;
  String _selectedDay = 'Lundi';
  final TextEditingController _hDebutController = TextEditingController();
  final TextEditingController _hFinController = TextEditingController();
  final TextEditingController _salleController = TextEditingController();

  Future<void> _addSession() async {
    if (_selectedPromoId == null || _selectedCourseId == null || _selectedDate == null) return;
    
    final schedule = HoraireEntity(
      id: '',
      idPromo: _selectedPromoId!,
      idCours: _selectedCourseId!,
      dateCours: _selectedDate!,
      jour: _selectedDay,
      heureDebut: _hDebutController.text,
      heureFin: _hFinController.text,
      salle: _salleController.text,
    );

    await ref.read(academicRepositoryProvider).addSchedule(schedule);
    
    _salleController.clear();
    _hDebutController.clear();
    _hFinController.clear();
    
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Séance ajoutée !")));
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(promotionsProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final schedulesAsync = _selectedPromoId != null ? ref.watch(schedulesProvider(_selectedPromoId)) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Gestion des Emplois du Temps', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromoSelector(promosAsync),
                const SizedBox(height: 30),
                if (_selectedPromoId != null) ...[
                  _buildAddForm(coursesAsync),
                  const SizedBox(height: 40),
                  _buildScheduleTable(schedulesAsync, coursesAsync),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoSelector(AsyncValue<List<PromotionEntity>> promosAsync) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2F7),
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: Color(0xFF3498DB), width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sélectionner la Promotion :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          promosAsync.when(
            data: (list) => DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedPromoId,
              hint: const Text('-- Choisissez une promotion --'),
              items: list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p.id, child: Text(p.nomPromo))).toList(),
              onChanged: (v) => setState(() => _selectedPromoId = v),
              decoration: InputDecoration(fillColor: Colors.white, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: \$e'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm(AsyncValue<List<CoursEntity>> coursesAsync) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ajouter une séance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Wrap(
            spacing: 15, runSpacing: 15,
            children: [
              Container(
                width: 250,
                child: coursesAsync.when(
                  data: (list) {
                    final promoCourses = list.where((c) => c.idPromo == _selectedPromoId).toList();
                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedCourseId,
                      hint: const Text('-- Cours --'),
                      items: promoCourses.map<DropdownMenuItem<String>>((c) => DropdownMenuItem(value: c.id, child: Text(c.intituleCours))).toList(),
                      onChanged: (v) => setState(() => _selectedCourseId = v),
                      decoration: _inputDeco(),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                ),
              ),
              Container(
                width: 180,
                child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2026), lastDate: DateTime(2027));
                    if (d != null) setState(() => _selectedDate = d);
                  },
                  child: InputDecorator(
                    decoration: _inputDeco(),
                    child: Text(_selectedDate == null ? 'Date' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                  ),
                ),
              ),
              Container(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _selectedDay,
                  items: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'].map<DropdownMenuItem<String>>((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _selectedDay = v!),
                  decoration: _inputDeco(),
                ),
              ),
              Container(width: 100, child: TextField(controller: _hDebutController, decoration: _inputDeco(hint: 'Début'))),
              Container(width: 100, child: TextField(controller: _hFinController, decoration: _inputDeco(hint: 'Fin'))),
              Container(width: 150, child: TextField(controller: _salleController, decoration: _inputDeco(hint: 'Salle'))),
              ElevatedButton(
                onPressed: _addSession, 
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20)),
                child: const Text('➕ AJOUTER')
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(AsyncValue<List<HoraireEntity>>? schedulesAsync, AsyncValue<List<CoursEntity>> coursesAsync) {
    if (schedulesAsync == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Horaire actuel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: schedulesAsync.when(
            data: (list) {
              if (list.isEmpty) return const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Aucune séance programmée.')));
              return DataTable(
                columns: const [
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('JOUR')),
                  DataColumn(label: Text('HEURES')),
                  DataColumn(label: Text('COURS')),
                  DataColumn(label: Text('SALLE')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: list.map((s) {
                  final course = coursesAsync.value?.firstWhere((c) => c.id == s.idCours, orElse: () => CoursEntity(id: '', idCours: 0, codeCours: '', intituleCours: '?', credits: 0, idEns: '', idPromo: ''));
                  return DataRow(cells: [
                    DataCell(Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text(DateFormat('dd/MM/yyyy').format(s.dateCours), style: const TextStyle(fontWeight: FontWeight.bold)))),
                    DataCell(Text(s.jour)),
                    DataCell(Text('\${s.heureDebut} - \${s.heureFin}')),
                    DataCell(Text(course?.intituleCours ?? '')),
                    DataCell(Text(s.salle)),
                    DataCell(IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () => ref.read(academicRepositoryProvider).deleteSchedule(s.id))),
                  ]);
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur: \$e'),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco({String? hint}) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.all(12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
  );
}
