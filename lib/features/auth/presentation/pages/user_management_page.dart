import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/user_management_providers.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/auth/domain/entities/utilisateur_entity.dart';
import 'package:istm_mahagi/features/academic/domain/entities/departement_entity.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _selectedRole = 'secretaire';
  String? _selectedDeptId;
  String? _editingAgentId;
  bool _showPassword = false;

  void _startEditing(UtilisateurEntity agent) {
    setState(() {
      _editingAgentId = agent.id;
      _nomController.text = agent.nomUser;
      _prenomController.text = agent.prenomUser;
      _matriculeController.text = agent.matricule;
      _passwordController.text = agent.password;
      _selectedRole = agent.role;
      _selectedDeptId = agent.idDept.isEmpty ? null : agent.idDept;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingAgentId = null;
      _nomController.clear();
      _prenomController.clear();
      _matriculeController.clear();
      _passwordController.clear();
      _selectedDeptId = null;
      _selectedRole = 'secretaire';
    });
  }

  Future<void> _saveAgent() async {
    if (_nomController.text.isEmpty || _matriculeController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.")));
      return;
    }

    try {
      final agent = UtilisateurEntity(
        id: _editingAgentId ?? '',
        nomUser: _nomController.text.trim(),
        prenomUser: _prenomController.text.trim(),
        matricule: _matriculeController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        idDept: _selectedDeptId ?? '',
      );

      final isUpdate = _editingAgentId != null;
      await ref.read(userManagementRepositoryProvider).saveAgent(agent);
      
      _cancelEditing();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isUpdate ? "Compte agent mis à jour avec succès !" : "Compte agent créé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'enregistrement : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentsAsync = ref.watch(agentsStreamProvider);
    final departmentsAsync = ref.watch(departmentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        title: const Text('Gestion de l\'Équipe Académique', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              children: [
                _buildTopBanner(),
                const SizedBox(height: 30),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 950) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _buildAddForm(departmentsAsync)),
                          const SizedBox(width: 30),
                          Expanded(flex: 1, child: _buildUserList(agentsAsync, departmentsAsync)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildAddForm(departmentsAsync),
                          const SizedBox(height: 30),
                          _buildUserList(agentsAsync, departmentsAsync),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👥 Gestion de l\'Équipe Académique', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          Text('Console d\'administration globale et gestion des accès personnels', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAddForm(AsyncValue<List<DepartementEntity>> departmentsAsync) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(_editingAgentId == null ? 'Créer un compte Agent' : 'Modifier le compte Agent'),
              if (_editingAgentId != null)
                TextButton.icon(
                  onPressed: _cancelEditing,
                  icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.orange),
                  label: const Text('ANNULER', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _buildInput('Nom de famille', _nomController)),
              const SizedBox(width: 20),
              Expanded(child: _buildInput('Prénom', _prenomController)),
            ],
          ),
          _buildInput('Code Unique / Matricule', _matriculeController),
          _buildPasswordInput(),
          
          const Text('Attribution du Rôle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedRole,
            items: const [
              DropdownMenuItem(value: 'secretaire', child: Text('Secrétaire')),
              DropdownMenuItem(value: 'decanat', child: Text('Décanat')),
              DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
              DropdownMenuItem(value: 'comptable', child: Text('Comptable')),
            ],
            onChanged: (v) => setState(() => _selectedRole = v!),
          ),
          
          const SizedBox(height: 20),
          const Text('Affectation au Département', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          departmentsAsync.when(
            data: (list) => _buildDropdown(
              hint: '-- Aucun (Accès d\'administration globale) --',
              value: _selectedDeptId,
              items: list.map<DropdownMenuItem<String>>((d) => DropdownMenuItem<String>(value: d.id, child: Text(d.nomDept))).toList(),
              onChanged: (v) => setState(() => _selectedDeptId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const Text("Erreur chargement départements", style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
          
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAgent,
              style: ElevatedButton.styleFrom(
                backgroundColor: _editingAgentId == null ? AppColors.primaryBlue : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 5,
              ),
              child: Text(
                _editingAgentId == null ? 'Générer le compte utilisateur' : 'Mettre à jour le compte', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(AsyncValue<List<UtilisateurEntity>> agentsAsync, AsyncValue<List<DepartementEntity>> departmentsAsync) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Utilisateurs enregistrés'),
          const SizedBox(height: 25),
          agentsAsync.when(
            data: (agents) {
              if (agents.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Aucun agent enregistré.")));
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  final agent = agents[index];
                  final dept = departmentsAsync.value?.where((d) => d.id == agent.idDept).firstOrNull;
                  return _buildUserRow(agent, dept?.nomDept);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(UtilisateurEntity agent, String? deptName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${agent.nomUser.toUpperCase()} ${agent.prenomUser}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Matricule: ${agent.matricule}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
              child: Text(agent.password, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: agent.role == 'admin' ? const Color(0xFFFEE2E2) : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: agent.role == 'admin' ? const Color(0xFFFCA5A5) : const Color(0xFFC7D2FE)),
                  ),
                  child: Text(agent.role.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: agent.role == 'admin' ? const Color(0xFF991B1B) : AppColors.primaryBlue)),
                ),
                Text(deptName ?? 'GLOBAL', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.blueGrey, size: 22),
            onPressed: () => _startEditing(agent),
            tooltip: 'Modifier les accès',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Révoquer l'accès ?"),
                  content: const Text("Confirmez-vous la révocation définitive des accès de cet agent ?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Révoquer", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(userManagementRepositoryProvider).deleteAgent(agent.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(height: 2, width: 50, color: AppColors.primaryBlue.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mot de passe en clair', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              contentPadding: const EdgeInsets.all(15),
              suffixIcon: TextButton(
                onPressed: () => setState(() => _showPassword = !_showPassword),
                child: Text(_showPassword ? 'CACHER' : 'VOIR', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({String? hint, required dynamic value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: hint != null ? Text(hint, style: const TextStyle(fontSize: 14)) : null,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
