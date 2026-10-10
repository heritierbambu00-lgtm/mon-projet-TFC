import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';

class AdminQuickSetupPage extends StatefulWidget {
  const AdminQuickSetupPage({super.key});

  @override
  State<AdminQuickSetupPage> createState() => _AdminQuickSetupPageState();
}

class _AdminQuickSetupPageState extends State<AdminQuickSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _matController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Nouveau champ Email
  bool _isLoading = false;

  Future<void> _setupAdmin() async {
    if (_nameController.text.isEmpty || _matController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Remplissez au moins Nom, Matricule et Passe"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // On utilise le matricule comme ID de document pour plus de simplicité
      final matricule = _matController.text.trim();
      
      await FirebaseFirestore.instance.collection('administrateurs').doc(matricule).set({
        'nom_complet': _nameController.text.trim(),
        'matricule': matricule,
        'password': _passController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(), // Pour lier au compte Gmail
        'role': 'admin',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ADMINISTRATEUR CRÉÉ AVEC SUCCÈS !"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur Firestore : $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_rounded, size: 60, color: AppColors.primaryBlue),
                const SizedBox(height: 20),
                const Text(
                  'INITIALISATION ADMIN',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const Text(
                  'Configuration réelle de la base de données',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 35),
                _buildInput(_nameController, 'Nom Complet (ex: HÉRITIER BAMBU)', Icons.person_outline),
                const SizedBox(height: 15),
                _buildInput(_matController, 'Matricule (ex: ADMIN001)', Icons.badge_outlined),
                const SizedBox(height: 15),
                _buildInput(_emailController, 'Email Gmail (optionnel)', Icons.email_outlined),
                const SizedBox(height: 15),
                _buildInput(_passController, 'Mot de passe', Icons.lock_outline, isPass: true),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _setupAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('CRÉER LE COMPTE DANS FIRESTORE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler et retourner au Login', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
