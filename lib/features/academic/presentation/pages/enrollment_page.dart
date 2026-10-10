import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/academic_providers.dart';
import '../../../auth/domain/entities/etudiant_entity.dart';

class EnrollmentPage extends ConsumerStatefulWidget {
  const EnrollmentPage({super.key});

  @override
  ConsumerState<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends ConsumerState<EnrollmentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // 1. Académique & Sécurité
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedPromoId;

  // 2. Identité Fondamentale
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _postnomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  String _sexe = 'M';
  String _etatCivil = 'Célibataire';
  final TextEditingController _nationaliteController = TextEditingController(text: 'CONGOLAISE');

  // 3. Naissance & Coordonnées
  final TextEditingController _lieuNaissanceController = TextEditingController();
  DateTime _dateNaissance = DateTime(2000, 1, 1);
  final TextEditingController _typeIdentiteController = TextEditingController();
  final TextEditingController _numIdentiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 4. Adresse Résidentielle
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();
  final TextEditingController _quartierController = TextEditingController();

  // 5. Origines
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _territoireController = TextEditingController();
  final TextEditingController _secteurController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  // 6. Cursus Secondaire
  final TextEditingController _ecoleController = TextEditingController();
  final TextEditingController _adresseEcoleController = TextEditingController();
  final TextEditingController _orientationController = TextEditingController();
  final TextEditingController _centreExetatController = TextEditingController();
  final TextEditingController _pourcentageController = TextEditingController();
  final TextEditingController _numDiplomeController = TextEditingController();

  // 7. Relations Familiales
  final TextEditingController _nomPereController = TextEditingController();
  final TextEditingController _nomMereController = TextEditingController();
  final TextEditingController _telTuteurController = TextEditingController();
  final TextEditingController _sponsorController = TextEditingController();

  // 8. Infos Médicales
  String _groupeSanguin = 'Inconnu';
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _alergieController = TextEditingController();
  String _handicap = 'NON';

  bool _isPasswordVisible = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance,
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateNaissance = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPromoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une promotion.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final nom = _nomController.text.trim().toUpperCase();
      String finalPassword = _passwordController.text.trim();
      if (finalPassword.isEmpty) {
        finalPassword = "Uac@${DateTime.now().year}${nom.toLowerCase()}";
      }

      final student = EtudiantEntity(
        id: '',
        matriculeEtu: _matriculeController.text.trim(),
        nomEtu: nom,
        postnomEtu: _postnomController.text.trim().toUpperCase(),
        prenomEtu: _prenomController.text.trim(),
        emailPersonnel: _emailController.text.trim(),
        password: finalPassword,
        idPromo: _selectedPromoId ?? '',
        sexe: _sexe,
        etatCivil: _etatCivil,
        telephone: _phoneController.text.trim(),
        telTuteur: _telTuteurController.text.trim(),
        lieuNaissance: _lieuNaissanceController.text.trim(),
        dateNaissance: _dateNaissance,
        typeIdentite: _typeIdentiteController.text.trim(),
        numIdentite: _numIdentiteController.text.trim(),
        ville: _villeController.text.trim(),
        commune: _communeController.text.trim(),
        quartier: _quartierController.text.trim(),
        nationalite: _nationaliteController.text.trim().toUpperCase(),
        provinceOrigine: _provinceController.text.trim(),
        territoireOrigine: _territoireController.text.trim(),
        secteur: _secteurController.text.trim(),
        village: _villageController.text.trim(),
        ecoleSecondaire: _ecoleController.text.trim(),
        adresseEcole: _adresseEcoleController.text.trim(),
        orientation: _orientationController.text.trim(),
        centreExamenEtat: _centreExetatController.text.trim(),
        pourcentage: _pourcentageController.text.trim(),
        numDiplome: _numDiplomeController.text.trim(),
        nomPere: _nomPereController.text.trim(),
        nomMere: _nomMereController.text.trim(),
        sponsor: _sponsorController.text.trim(),
        groupeSanguin: _groupeSanguin,
        taille: _tailleController.text.trim(),
        alergie: _alergieController.text.trim(),
        handicap: _handicap,
      );

      await ref.read(academicRepositoryProvider).addStudent(student);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🎉 Étudiant inscrit ! Password : $finalPassword"), backgroundColor: Colors.green, duration: const Duration(seconds: 5)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosWithDetailsAsync = ref.watch(promotionsWithDetailsProvider);
    final bool isMobile = Responsive.isMobile(context);
    const Color pageBg = Color(0xFFE2E8F0); // Arrière-plan plus foncé pour contraste

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Column(
          children: [
            Text(isMobile ? 'NOUVELLE INSCRIPTION' : 'PLATEFORME D\'INSCRIPTION ÉTUDIANT', 
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16, color: Color(0xFF0F172A))),
            const Text('SESSION ACADÉMIQUE 2026', style: TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isSubmitting 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildFormSection(
                        '1. Informations Académiques & Sécurité',
                        Icons.school_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Matricule *', _matriculeController, Icons.badge_outlined),
                            promosWithDetailsAsync.when(
                              data: (list) => _buildDropdown(
                                'Promotion Cible *', 
                                list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p['stableId'].toString(), child: Text(p['label']))).toList(), 
                                _selectedPromoId, 
                                (v) => setState(() => _selectedPromoId = v)
                              ),
                              loading: () => const LinearProgressIndicator(),
                              error: (e, __) => Text('Erreur: $e'),
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _buildPasswordField(),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(
                        '2. Identité Fondamentale Civile',
                        Icons.person_pin_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Nom *', _nomController, Icons.person_outline),
                            _buildTextField('Post-Nom', _postnomController, Icons.person_outline),
                            _buildTextField('Prénom *', _prenomController, Icons.person_outline),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildDropdown('Sexe *', [const DropdownMenuItem(value: 'M', child: Text('Masculin')), const DropdownMenuItem(value: 'F', child: Text('Féminin'))], _sexe, (v) => setState(() => _sexe = v!)),
                            _buildDropdown('État Civil', [const DropdownMenuItem(value: 'Célibataire', child: Text('Célibataire')), const DropdownMenuItem(value: 'Marié(e)', child: Text('Marié(e)')), const DropdownMenuItem(value: 'Divorcé(e)', child: Text('Divorcé(e)'))], _etatCivil, (v) => setState(() => _etatCivil = v!)),
                            _buildTextField('Nationalité', _nationaliteController, Icons.flag_outlined),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(
                        '3. Naissance & Coordonnées',
                        Icons.contact_mail_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Lieu de Naissance', _lieuNaissanceController, Icons.location_on_outlined),
                            _buildDatePicker(),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Type de Pièce ID', _typeIdentiteController, Icons.card_membership_outlined),
                            _buildTextField('Numéro de Pièce', _numIdentiteController, Icons.numbers_outlined),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Téléphone *', _phoneController, Icons.phone_outlined),
                            _buildTextField('Email Personnel', _emailController, Icons.email_outlined),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(
                        '4. Adresse Résidentielle Actuelle',
                        Icons.location_city_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Ville', _villeController, Icons.map_outlined),
                            _buildTextField('Commune', _communeController, Icons.apartment_rounded),
                            _buildTextField('Quartier', _quartierController, Icons.holiday_village_outlined),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(
                        '5. Origines Territoriales',
                        Icons.home_work_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Province', _provinceController, Icons.public_outlined),
                            _buildTextField('Territoire', _territoireController, Icons.explore_outlined),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Secteur', _secteurController, Icons.grid_view_outlined),
                            _buildTextField('Village', _villageController, Icons.home_rounded),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(
                        '6. Cursus Humanitaire (Études Secondaires)',
                        Icons.history_edu_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('École de provenance', _ecoleController, Icons.school_outlined),
                            _buildTextField('Adresse École', _adresseEcoleController, Icons.location_on_outlined),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Option / Orientation', _orientationController, Icons.psychology_outlined),
                            _buildTextField('Centre Exetat', _centreExetatController, Icons.assignment_outlined),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Pourcentage (%)', _pourcentageController, Icons.percent_outlined, keyboardType: TextInputType.number),
                            _buildTextField('Numéro Diplôme d\'État', _numDiplomeController, Icons.badge_outlined),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(
                        '7. Relations Familiales & Prise en Charge',
                        Icons.family_restroom_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Nom du Père', _nomPereController, Icons.person_pin_outlined),
                            _buildTextField('Nom de la Mère', _nomMereController, Icons.person_pin_outlined),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Téléphone Tuteur', _telTuteurController, Icons.phone_android_outlined),
                            _buildTextField('Sponsor / Payeur', _sponsorController, Icons.handshake_outlined),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(
                        '8. Informations Médicales',
                        Icons.medical_services_rounded,
                        [
                          _buildResponsiveRow(isMobile, [
                            _buildDropdown('Groupe Sanguin', ['Inconnu', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), _groupeSanguin, (v) => setState(() => _groupeSanguin = v!)),
                            _buildTextField('Taille (ex: 1.75m)', _tailleController, Icons.height_outlined),
                          ]),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(isMobile, [
                            _buildTextField('Allergies connues', _alergieController, Icons.warning_amber_rounded),
                            _buildDropdown('Handicap ?', [const DropdownMenuItem(value: 'NON', child: Text('NON')), const DropdownMenuItem(value: 'OUI', child: Text('OUI'))], _handicap, (v) => setState(() => _handicap = v!)),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 45),
                      Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('FINALISER L\'INSCRIPTION PROMAX', 
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFormSection(String title, IconData icon, List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primaryBlue, size: 22),
              ),
              const SizedBox(width: 15),
              Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: AppColors.deepNavy)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(thickness: 1, color: Color(0xFFF1F5F9)),
          ),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 20), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 20), child: c))).toList(),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) => (label.contains('*') && v!.isEmpty) ? 'Requis' : null,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<DropdownMenuItem<String>> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: (v) => (label.contains('*') && v == null) ? 'Requis' : null,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date de Naissance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_dateNaissance.day}/${_dateNaissance.month}/${_dateNaissance.year}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mot de passe personnalisé (Laisser vide pour générer auto)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF64748B)),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, size: 18),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }
}
