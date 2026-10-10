import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import '../providers/academic_providers.dart';
import '../../domain/entities/admission_entity.dart';

class AdmissionPage extends ConsumerStatefulWidget {
  const AdmissionPage({super.key});

  @override
  ConsumerState<AdmissionPage> createState() => _AdmissionPageState();
}

class _AdmissionPageState extends ConsumerState<AdmissionPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _postnomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _lieuNaissanceController = TextEditingController();
  final TextEditingController _adressePermController = TextEditingController();
  final TextEditingController _adresseContactController = TextEditingController();
  final TextEditingController _nationaliteController = TextEditingController(text: 'Congolaise');
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _ecoleController = TextEditingController();
  final TextEditingController _adresseEcoleController = TextEditingController();
  final TextEditingController _centreExamenController = TextEditingController();
  final TextEditingController _anneeEtatController = TextEditingController();
  final TextEditingController _pourcentageController = TextEditingController();
  final TextEditingController _diplomeNumController = TextEditingController();
  final TextEditingController _postSecController = TextEditingController();

  DateTime _dateNaissance = DateTime(2000, 1, 1);
  String _genre = 'Masculin';
  String _etatCivil = 'Célibataire';
  String? _selectedPromo;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance,
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0F172A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateNaissance = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPromo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une promotion.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final admission = AdmissionEntity(
        id: '',
        nom: _nomController.text.trim(),
        postnom: _postnomController.text.trim(),
        prenom: _prenomController.text.trim(),
        genre: _genre,
        telephone: _phoneController.text.trim(),
        lieuNaissance: _lieuNaissanceController.text.trim(),
        dateNaissance: _dateNaissance,
        adressePermanente: _adressePermController.text.trim(),
        adresseContact: _adresseContactController.text.trim(),
        nationalite: _nationaliteController.text.trim(),
        provinceOrigine: _provinceController.text.trim(),
        villageOrigine: _villageController.text.trim(),
        etatCivil: _etatCivil,
        ecoleSecondaire: _ecoleController.text.trim(),
        adresseEcole: _adresseEcoleController.text.trim(),
        centreExamen: _centreExamenController.text.trim(),
        anneeObtentionEtat: int.tryParse(_anneeEtatController.text) ?? 0,
        pourcentageEtat: double.tryParse(_pourcentageController.text) ?? 0.0,
        numeroDiplome: _diplomeNumController.text.trim(),
        postSecondaire: _postSecController.text.trim(),
        codePromotion: _selectedPromo!,
        dateSoumission: DateTime.now(),
      );

      await ref.read(academicRepositoryProvider).submitAdmission(admission);
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dossier Soumis !', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            SizedBox(height: 10),
            Text('Votre candidature a été envoyée avec succès au secrétariat académique de l\'ISTM.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('RETOUR À L\'ACCUEIL', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(promotionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Midnight Navy Root
      body: CustomScrollView(
        slivers: [
          _buildSliverHero(),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9), // Slate background for content
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                children: [
                  _buildGuideSection(),
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 15)),
                        ],
                      ),
                      padding: const EdgeInsets.all(50),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('01', 'IDENTITÉ & ÉTAT CIVIL', 'Informations personnelles du candidat'),
                            const SizedBox(height: 35),
                            Row(
                              children: [
                                Expanded(child: _buildPremiumField('Nom *', _nomController, Icons.person_outline)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildPremiumField('Post-Nom *', _postnomController, Icons.person_outline)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildPremiumField('Prénom *', _prenomController, Icons.person_outline)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildPremiumDropdown('Genre', ['Masculin', 'Féminin'], _genre, (v) => setState(() => _genre = v!))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildPremiumField('Lieu de Naissance *', _lieuNaissanceController, Icons.location_on_outlined)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildPremiumDatePicker('Date de Naissance')),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildPremiumField('Nationalité', _nationaliteController, Icons.flag_outlined)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildPremiumDropdown('État Civil', ['Célibataire', 'Marié(e)'], _etatCivil, (v) => setState(() => _etatCivil = v!))),
                              ],
                            ),
                            const SizedBox(height: 60),
                            
                            _buildSectionHeader('02', 'LOCALISATION & CONTACT', 'Comment vous joindre officiellement'),
                            const SizedBox(height: 35),
                            _buildPremiumField('Téléphone de Contact *', _phoneController, Icons.phone_outlined, hint: 'Ex: +243...'),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildPremiumField('Province d\'Origine', _provinceController, Icons.map_outlined)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildPremiumField('Village d\'Origine', _villageController, Icons.home_outlined)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildPremiumField('Adresse Permanente', _adressePermController, Icons.alternate_email_rounded),
                            const SizedBox(height: 60),

                            _buildSectionHeader('03', 'CURSUS ACADÉMIQUE', 'Vos antécédents scolaires'),
                            const SizedBox(height: 35),
                            _buildPremiumField('École Secondaire', _ecoleController, Icons.school_outlined),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildPremiumField('Centre Exetat', _centreExamenController, Icons.assignment_outlined)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildPremiumField('Année d\'Obtention', _anneeEtatController, Icons.calendar_today_outlined, keyboardType: TextInputType.number)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildPremiumField('Pourcentage Exetat (%)', _pourcentageController, Icons.percent_rounded, keyboardType: TextInputType.number)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildPremiumField('Numéro du Diplôme', _diplomeNumController, Icons.badge_outlined)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildPremiumField('Études Post-Secondaires', _postSecController, Icons.history_edu_outlined, hint: 'Autre Institut ou (-)'),
                            const SizedBox(height: 60),

                            _buildSectionHeader('04', 'CHOIX DE FORMATION', 'Quelle carrière visez-vous ?'),
                            const SizedBox(height: 35),
                            promosAsync.when(
                              data: (promos) => _buildPremiumDropdown(
                                'Promotion & Filière ciblée *', 
                                promos.map<String>((p) => p.nomPromo).toList(), 
                                _selectedPromo, 
                                (v) => setState(() => _selectedPromo = v),
                                icon: Icons.ads_click_rounded
                              ),
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const Text('Erreur de chargement des promotions'),
                            ),

                            const SizedBox(height: 80),
                            SizedBox(
                              width: double.infinity,
                              height: 75,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: _isSubmitting 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('SOUMETTRE MON DOSSIER COMPLET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Center(child: Text('* Conformément au règlement, toute fausse déclaration annule l\'inscription.', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHero() {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: const Color(0xFF0F172A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image/Video Placeholder with dark overlay
            Image.asset('assets/images/slider1.jpg', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.6)),
            
            // Text Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.accentYellow, borderRadius: BorderRadius.circular(8)),
                    child: const Text('ADMISSIONS 2025-2026', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 20),
                  const Text('Devenez un professionnel\nde la santé d\'élite.', 
                    style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1)),
                  const SizedBox(height: 15),
                  const Text('Rejoignez l\'ISTM Mahagi et bénéficiez d\'une formation clinique de pointe.', 
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 35),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        label: const Text('VOIR LA PRÉSENTATION'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Row(
        children: [
          _buildGuideCard('01', 'Formulaire', 'Remplissez vos infos réelles.', Icons.edit_note_rounded),
          const SizedBox(width: 20),
          _buildGuideCard('02', 'Vérification', 'Le secrétariat valide.', Icons.fact_check_outlined),
          const SizedBox(width: 20),
          _buildGuideCard('03', 'Confirmation', 'Recevez votre admission.', Icons.verified_user_outlined),
        ],
      ),
    );
  }

  Widget _buildGuideCard(String num, String title, String desc, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(num, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFE2E8F0))),
                Icon(icon, color: AppColors.primaryBlue, size: 28),
              ],
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B))),
            const SizedBox(height: 5),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String step, String title, String sub) {
    return Row(
      children: [
        Container(
          width: 45, height: 45,
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A), letterSpacing: 0.5)),
            Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumField(String label, TextEditingController controller, IconData icon, {String? hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF334155), letterSpacing: 0.5)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDropdown(String label, List<String> items, String? value, Function(String?) onChanged, {IconData icon = Icons.keyboard_arrow_down_rounded}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF334155), letterSpacing: 0.5)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Requis' : null,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDatePicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF334155), letterSpacing: 0.5)),
        const SizedBox(height: 10),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: Color(0xFF64748B), size: 20),
                    const SizedBox(width: 12),
                    Text("${_dateNaissance.day}/${_dateNaissance.month}/${_dateNaissance.year}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
