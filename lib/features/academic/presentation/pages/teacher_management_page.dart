import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/academic_providers.dart';
import '../../../auth/domain/entities/enseignant_entity.dart';

class TeacherManagementPage extends ConsumerStatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  ConsumerState<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends ConsumerState<TeacherManagementPage> {
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _postnomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialiteController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isPasswordVisible = false;

  void _showAddModal({EnseignantEntity? teacher}) {
    if (teacher != null) {
      _matriculeController.text = teacher.matriculeEns;
      _nomController.text = teacher.nomEns;
      _postnomController.text = teacher.postnomEns;
      _emailController.text = teacher.emailPro;
      _specialiteController.text = teacher.specialite;
      _passController.text = teacher.password;
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(teacher == null ? Icons.person_add_rounded : Icons.edit_rounded, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 15),
              Text(teacher == null ? 'Enregistrer un Enseignant' : 'Modifier l\'Enseignant', 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 550,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildPremiumField('Matricule *', _matriculeController, Icons.badge_outlined, enabled: teacher == null)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildPremiumField('Spécialité', _specialiteController, Icons.school_outlined)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildPremiumField('Nom *', _nomController, Icons.person_outline)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildPremiumField('Postnom', _postnomController, Icons.person_outline)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildPremiumField('Email Professionnel', _emailController, Icons.email_outlined),
                  const SizedBox(height: 15),
                  _buildPremiumField(
                    'Mot de passe *', 
                    _passController, 
                    Icons.lock_outline, 
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: () => setModalState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  const SizedBox(height: 10),
                  const Text('* Champs obligatoires', style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          actions: [
            TextButton(
              onPressed: () {
                _clearControllers();
                Navigator.pop(context);
              }, 
              child: const Text('ANNULER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                onPressed: () => _saveTeacher(id: teacher?.id), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, 
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(teacher == null ? 'ENREGISTRER MAINTENANT' : 'METTRE À JOUR', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5))
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTeacher({String? id}) async {
    if (_matriculeController.text.isEmpty || _nomController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir les champs obligatoires."), backgroundColor: Colors.orange));
      return;
    }
    
    final ens = EnseignantEntity(
      id: id ?? '',
      matriculeEns: _matriculeController.text.trim(),
      nomEns: _nomController.text.trim(),
      postnomEns: _postnomController.text.trim(),
      emailPro: _emailController.text.trim(),
      specialite: _specialiteController.text.trim(),
      photoEns: 'default.jpg',
      password: _passController.text.trim(),
    );

    await ref.read(academicRepositoryProvider).addTeacher(ens);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(id == null ? "Enseignant enregistré avec succès !" : "Profil mis à jour !"), backgroundColor: Colors.green));
      _clearControllers();
    }
  }

  void _clearControllers() {
    _matriculeController.clear();
    _nomController.clear();
    _postnomController.clear();
    _emailController.clear();
    _specialiteController.clear();
    _passController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(teachersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('REGISTRE DES ENSEIGNANTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1, color: Color(0xFF0F172A))),
            Text('Gestion de la faculté et du personnel académique', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        toolbarHeight: 85,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showAddModal(),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('NOUVEL ENSEIGNANT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, 
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            teachersAsync.when(
              data: (list) => Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Row(
                  children: [
                    _buildStatCard('Total Enseignants', list.length.toString(), Icons.groups_rounded, AppColors.primaryBlue),
                    const SizedBox(width: 20),
                    _buildStatCard('Spécialités', list.map((e) => e.specialite).toSet().length.toString(), Icons.psychology_rounded, Colors.orange),
                    const SizedBox(width: 20),
                    _buildStatCard('Actifs ce mois', list.length.toString(), Icons.verified_user_rounded, Colors.green),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 10)),
                ],
              ),
              child: teachersAsync.when(
                data: (list) => ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: DataTable(
                    headingRowHeight: 65,
                    dataRowHeight: 75,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF0F172A)),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    dividerThickness: 1,
                    horizontalMargin: 25,
                    columns: const [
                      DataColumn(label: Text('ENSEIGNANT', style: TextStyle(letterSpacing: 1))),
                      DataColumn(label: Text('MATRICULE', style: TextStyle(letterSpacing: 1))),
                      DataColumn(label: Text('SPÉCIALITÉ', style: TextStyle(letterSpacing: 1))),
                      DataColumn(label: Text('EMAIL PRO', style: TextStyle(letterSpacing: 1))),
                      DataColumn(label: Text('MOT DE PASSE', style: TextStyle(letterSpacing: 1))),
                      DataColumn(label: Text('ACTIONS', style: TextStyle(letterSpacing: 1))),
                    ],
                    rows: list.map((ens) => DataRow(
                      cells: [
                        DataCell(Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 2)),
                              child: CircleAvatar(
                                radius: 22, 
                                backgroundColor: const Color(0xFFF1F5F9),
                                backgroundImage: (ens.photoEns != 'default.jpg' && ens.photoEns.startsWith('http')) 
                                  ? NetworkImage(ens.photoEns) 
                                  : const AssetImage('assets/images/logo.jpg') as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${ens.nomEns} ${ens.postnomEns}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                                const Text('Personnel Académique', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                          child: Text(ens.matriculeEns, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primaryBlue)),
                        )),
                        DataCell(Text(ens.specialite, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Text(ens.emailPro, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                        DataCell(Row(
                          children: [
                            Text(ens.password, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: ens.password));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mot de passe copié !"), duration: Duration(seconds: 1)));
                              },
                            ),
                          ],
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, color: Colors.blueGrey, size: 22),
                              onPressed: () => _showAddModal(teacher: ens),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                              onPressed: () => _confirmDelete(ens),
                            ),
                          ],
                        )),
                      ],
                    )).toList(),
                  ),
                ),
                loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(EnseignantEntity ens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer l\'enseignant ${ens.nomEns} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          TextButton(
            onPressed: () {
              ref.read(academicRepositoryProvider).deleteTeacher(ens.id);
              Navigator.pop(context);
            }, 
            child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 5),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.deepNavy, fontFamily: 'Playfair Display')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, bool isVisible = false, VoidCallback? onToggleVisibility, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF334155), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF8FAFC) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isVisible,
            enabled: enabled,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: enabled ? Colors.black : Colors.grey),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
              suffixIcon: isPassword ? IconButton(icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, size: 18), onPressed: onToggleVisibility) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
