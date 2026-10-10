import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/academic/presentation/utils/student_id_print_utils.dart';
import 'package:istm_mahagi/features/academic/presentation/utils/attendance_print_utils.dart';
import '../providers/academic_providers.dart';
import '../../../auth/domain/entities/etudiant_entity.dart';

class StudentListPage extends ConsumerStatefulWidget {
  const StudentListPage({super.key});

  @override
  ConsumerState<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends ConsumerState<StudentListPage> {
  String? _selectedPromoId;
  static const Color navySurface = Color(0xFF112240);
  static const Color goldAccent = Color(0xFFC5A059);

  void _showReEnrollDialog(EtudiantEntity student) {
    String? localSelectedPromo;
    final currentYear = ref.read(currentAcademicYearProvider).value ?? "2025-2026";
    final TextEditingController yearController = TextEditingController(text: currentYear);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: navySurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("RÉINSCRIRE : ${student.nomEtu}", style: const TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choisissez la nouvelle promotion et l'année académique cible pour cet étudiant.", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) {
                final promosAsync = ref.watch(promotionsWithDetailsProvider);
                return promosAsync.when(
                  data: (list) => DropdownButtonFormField<String>(
                    dropdownColor: navySurface,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0A192F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    hint: const Text("-- Nouvelle Promotion --", style: TextStyle(color: Colors.white38)),
                    items: list.map((p) => DropdownMenuItem(value: p['stableId'].toString(), child: Text(p['label']))).toList(),
                    onChanged: (v) {
                      localSelectedPromo = v;
                      final selectedItem = list.firstWhere((p) => p['stableId'].toString() == v, orElse: () => {});
                      if (selectedItem['anneeAcad'] != null && (selectedItem['anneeAcad'] as String).isNotEmpty) {
                        yearController.text = selectedItem['anneeAcad'];
                      }
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text("Erreur : $e", style: const TextStyle(color: Colors.red)),
                );
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: yearController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              decoration: InputDecoration(
                labelText: "Année Académique de Réinscription",
                labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0A192F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () async {
              if (localSelectedPromo == null) return;
              try {
                await ref.read(academicRepositoryProvider).reEnrollStudent(
                  student.id, 
                  localSelectedPromo!, 
                  anneeAcad: yearController.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Étudiant réinscrit avec succès !"), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: Colors.white),
            child: const Text("CONFIRMER"),
          ),
        ],
      ),
    );
  }

  void _showStudentDetailsDialog(EtudiantEntity student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: navySurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("${student.nomEtu} ${student.postnomEtu} ${student.prenomEtu}".toUpperCase(), 
          style: const TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Matricule", student.matriculeEtu),
              _detailRow("Genre", student.sexe),
              _detailRow("Téléphone", student.telephone.isNotEmpty ? student.telephone : "Non renseigné"),
              _detailRow("Email", student.emailPersonnel.isNotEmpty ? student.emailPersonnel : "Non renseigné"),
              _detailRow("Lieu de naissance", student.lieuNaissance.isNotEmpty ? student.lieuNaissance : "Non renseigné"),
              _detailRow("Nationalité", student.nationalite),
              _detailRow("Province d'origine", student.provinceOrigine.isNotEmpty ? student.provinceOrigine : "Non renseigné"),
              _detailRow("École secondaire", student.ecoleSecondaire.isNotEmpty ? student.ecoleSecondaire : "Non renseigné"),
              _detailRow("Option / Pourcentage", "${student.orientation} (${student.pourcentage}%)"),
              _detailRow("Tuteur / Sponsor", "${student.nomPere} / ${student.sponsor}"),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: Colors.white),
            child: const Text("FERMER"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text("$label :", style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(EtudiantEntity student) {
    final nomCtrl = TextEditingController(text: student.nomEtu);
    final postnomCtrl = TextEditingController(text: student.postnomEtu);
    final prenomCtrl = TextEditingController(text: student.prenomEtu);
    final matriculeCtrl = TextEditingController(text: student.matriculeEtu);
    final phoneCtrl = TextEditingController(text: student.telephone);
    final emailCtrl = TextEditingController(text: student.emailPersonnel);
    String sexe = student.sexe.isNotEmpty ? student.sexe : 'M';
    String? promoId = student.idPromo.isNotEmpty ? student.idPromo : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: navySurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text("MODIFIER : ${student.nomEtu} ${student.prenomEtu}", style: const TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: matriculeCtrl,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Matricule",
                    labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0A192F),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nomCtrl,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Nom",
                    labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0A192F),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: postnomCtrl,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Post-nom",
                    labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0A192F),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prenomCtrl,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Prénom",
                    labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0A192F),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sexe,
                        dropdownColor: navySurface,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "Genre",
                          labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF0A192F),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'M', child: Text("Masculin")),
                          DropdownMenuItem(value: 'F', child: Text("Féminin")),
                        ],
                        onChanged: (v) => setModalState(() => sexe = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "Téléphone",
                          labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF0A192F),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Email Personnel",
                    labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0A192F),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final promosAsync = ref.watch(promotionsWithDetailsProvider);
                    return promosAsync.when(
                      data: (list) => DropdownButtonFormField<String>(
                        value: promoId,
                        dropdownColor: navySurface,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        decoration: InputDecoration(
                          labelText: "Promotion",
                          labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF0A192F),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: list.map((p) => DropdownMenuItem(value: p['stableId'].toString(), child: Text(p['label']))).toList(),
                        onChanged: (v) => setModalState(() => promoId = v),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text("Erreur: $e", style: const TextStyle(color: Colors.red)),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER", style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              onPressed: () async {
                if (nomCtrl.text.trim().isEmpty || matriculeCtrl.text.trim().isEmpty) return;
                final Map<String, dynamic> updateData = {
                  'matricule_etu': matriculeCtrl.text.trim(),
                  'nom_etu': nomCtrl.text.trim().toUpperCase(),
                  'postnom_etu': postnomCtrl.text.trim().toUpperCase(),
                  'prenom_etu': prenomCtrl.text.trim(),
                  'Sexe': sexe,
                  'telephone': phoneCtrl.text.trim(),
                  'email_personnel': emailCtrl.text.trim(),
                };
                if (promoId != null) {
                  updateData['id_promo'] = int.tryParse(promoId!) ?? promoId;
                }

                await ref.read(academicRepositoryProvider).updateStudent(student.id, updateData);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Étudiant modifié avec succès !"), backgroundColor: Colors.green));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: Colors.white),
              child: const Text("ENREGISTRER"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promosWithDetailsAsync = ref.watch(promotionsWithDetailsProvider);
    final studentsAsync = _selectedPromoId != null ? ref.watch(studentsByPromoProvider(_selectedPromoId)) : null;
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isMobile ? 'RÉPERTOIRE' : 'RÉPERTOIRE ACADÉMIQUE', 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1, color: goldAccent, fontFamily: 'Playfair Display')),
            const Text('Gestion des effectifs étudiants', style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w600)),
          ],
        ),
        iconTheme: const IconThemeData(color: goldAccent),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        toolbarHeight: 85,
        shape: Border(bottom: BorderSide(color: goldAccent.withOpacity(0.1))),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF112240), Color(0xFF0A192F)],
            center: Alignment.topCenter,
            radius: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  PremiumFadeIn(child: _buildFilterCard(promosWithDetailsAsync, isMobile)),
                  const SizedBox(height: 40),
                  if (_selectedPromoId == null)
                    PremiumFadeIn(delay: const Duration(milliseconds: 200), child: _buildInitialState())
                  else
                    _buildStudentsTableCard(studentsAsync, isMobile),
                  const SizedBox(height: 80),
                  _buildAdministrativeGuides(isMobile),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(AsyncValue<List<Map<String, dynamic>>> promosAsync, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 25 : 35),
      decoration: BoxDecoration(
        color: navySurface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 15))],
        border: Border.all(color: goldAccent.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.auto_awesome_rounded, color: goldAccent, size: 22),
              ),
              const SizedBox(width: 15),
              const Text("SÉLECTION DE LA PROMOTION", style: TextStyle(fontWeight: FontWeight.w900, color: goldAccent, fontSize: 13, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 25),
          promosAsync.when(
            data: (list) => DropdownButtonFormField<String>(
              value: _selectedPromoId,
              isExpanded: true,
              dropdownColor: navySurface,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              hint: const Text("-- Choisissez une promotion --", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white38)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0A192F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: goldAccent.withOpacity(0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: goldAccent.withOpacity(0.1))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              items: list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p['stableId'].toString(), child: Text(p['label'], style: TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 12 : 14, color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => _selectedPromoId = v),
            ),
            loading: () => const LinearProgressIndicator(backgroundColor: Colors.transparent, color: goldAccent),
            error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTableCard(AsyncValue<List<EtudiantEntity>>? studentsAsync, bool isMobile) {
    if (studentsAsync == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: navySurface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 50, offset: const Offset(0, 20))],
        border: Border.all(color: goldAccent.withOpacity(0.1), width: 0.5),
      ),
      child: studentsAsync.when(
        data: (list) {
          if (list.isEmpty) return _buildEmptyState("Aucun étudiant trouvé.");
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 25 : 35),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${list.length} ÉTUDIANTS", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text("Archive 2026 • ISTM Mahagi", style: TextStyle(fontSize: 10, color: goldAccent.withOpacity(0.6), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        _printActionBtn(
                          icon: Icons.vpn_key_rounded, 
                          label: isMobile ? 'ID' : 'IDENTIFIANTS',
                          color: goldAccent,
                          onTap: () => StudentIdPrintUtils.print(list),
                        ),
                        _printActionBtn(
                          icon: Icons.assignment_turned_in_rounded, 
                          label: isMobile ? 'LISTE' : 'LISTE DE PRÉSENCE',
                          color: AppColors.primaryBlue,
                          onTap: () {
                            final promoData = ref.read(promotionsWithDetailsProvider).value?.firstWhere((p) => p['stableId'].toString() == _selectedPromoId);
                            AttendancePrintUtils.print(
                              students: list, 
                              department: promoData?['dept'] ?? '?',
                              promotion: promoData?['nom'] ?? '?',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 65,
                    dataRowHeight: 85,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF0A192F).withOpacity(0.5)),
                    dividerThickness: 0.5,
                    horizontalMargin: 30,
                    columns: const [
                      DataColumn(label: Text('IDENTITÉ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: goldAccent, letterSpacing: 1))),
                      DataColumn(label: Text('MATRICULE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: goldAccent, letterSpacing: 1))),
                      DataColumn(label: Text('GENRE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: goldAccent, letterSpacing: 1))),
                      DataColumn(label: Text('ACCÈS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: goldAccent, letterSpacing: 1))),
                    ],
                    rows: list.map((e) => DataRow(
                      cells: [
                        DataCell(Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(border: Border.all(color: goldAccent.withOpacity(0.3)), shape: BoxShape.circle),
                              child: CircleAvatar(
                                radius: 20, 
                                backgroundColor: const Color(0xFF0A192F),
                                backgroundImage: (e.photoProfil != 'default.jpg' && e.photoProfil.startsWith('http')) 
                                  ? NetworkImage(e.photoProfil) 
                                  : const AssetImage('assets/images/logo.jpg') as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text("${e.nomEtu} ${e.prenomEtu}".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white, fontFamily: 'Playfair Display')),
                          ],
                        )),
                        DataCell(Text(e.matriculeEtu, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white70, letterSpacing: 1))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: e.sexe == 'M' ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: e.sexe == 'M' ? Colors.blue.withOpacity(0.3) : Colors.pink.withOpacity(0.3)),
                          ),
                          child: Text(e.sexe, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: e.sexe == 'M' ? Colors.blue : Colors.pink)),
                        )),
                        DataCell(Row(
                          children: [
                            _actionBtn(Icons.visibility_rounded, goldAccent, () => _showStudentDetailsDialog(e)),
                            const SizedBox(width: 10),
                            _actionBtn(Icons.redo_rounded, Colors.tealAccent, () => _showReEnrollDialog(e)),
                            const SizedBox(width: 10),
                            _actionBtn(Icons.edit_note_rounded, Colors.lightBlueAccent, () => _showEditStudentDialog(e)),
                          ],
                        )),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 400, child: Center(child: CircularProgressIndicator(color: goldAccent))),
        error: (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _printActionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(45),
              decoration: BoxDecoration(
                color: navySurface, 
                shape: BoxShape.circle, 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 50)],
                border: Border.all(color: goldAccent.withOpacity(0.1)),
              ),
              child: const Icon(Icons.manage_accounts_rounded, size: 80, color: goldAccent),
            ),
            const SizedBox(height: 35),
            const Text("SYSTÈME DE GESTION ACADÉMIQUE", style: TextStyle(fontWeight: FontWeight.w900, color: goldAccent, letterSpacing: 4, fontSize: 12)),
            const SizedBox(height: 15),
            const Text("Veuillez sélectionner une promotion pour consulter les effectifs.", style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdministrativeGuides(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: goldAccent, size: 18),
            const SizedBox(width: 10),
            const Text("DIRECTIVES ADMINISTRATIVES", style: TextStyle(fontWeight: FontWeight.w900, color: goldAccent, fontSize: 11, letterSpacing: 3)),
          ],
        ),
        const SizedBox(height: 30),
        isMobile 
          ? Column(children: _guideCards())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _guideCards().map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 25), child: c))).toList(),
            ),
      ],
    );
  }

  List<Widget> _guideCards() {
    return [
      _guideCard(Icons.vpn_key_rounded, "SÉCURITÉ DES ACCÈS", "La génération des identifiants doit être confidentielle. Remettez les plis fermés aux étudiants.", goldAccent),
      _guideCard(Icons.fact_check_rounded, "CONTRÔLE PRÉSENCE", "Le mode Portrait optimise l'archivage dans les classeurs du Décanat. Signatures obligatoires.", Colors.blue),
      _guideCard(Icons.cloud_sync_rounded, "SYNCHRONISATION", "Toute modification est répercutée sur le Portail Étudiant en temps réel.", Colors.teal),
    ];
  }

  Widget _guideCard(IconData icon, String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: navySurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.2))),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 25),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.6, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const Icon(Icons.group_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            Text(msg, style: const TextStyle(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
