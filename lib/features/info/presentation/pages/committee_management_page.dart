import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/comite_entity.dart';

class CommitteeManagementPage extends ConsumerStatefulWidget {
  const CommitteeManagementPage({super.key});

  @override
  ConsumerState<CommitteeManagementPage> createState() => _CommitteeManagementPageState();
}

class _CommitteeManagementPageState extends ConsumerState<CommitteeManagementPage> {
  final TextEditingController _nomCompletController = TextEditingController();
  final TextEditingController _fonctionController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _rangController = TextEditingController();
  String? _editingId;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _categorieController.text = "Direction";
    _rangController.text = "1";
  }

  void _clear() {
    _nomCompletController.clear();
    _fonctionController.clear();
    _categorieController.text = "Direction";
    _bioController.clear();
    _rangController.text = "1";
    _editingId = null;
    _imageUrl = null;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageUrl = image.path);
    }
  }

  void _save() async {
    if (_nomCompletController.text.isEmpty || _fonctionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nom et Fonction sont requis.")));
      return;
    }

    final member = ComiteEntity(
      id: _editingId ?? '',
      nomComplet: _nomCompletController.text.trim(),
      fonction: _fonctionController.text.trim(),
      categorie: _categorieController.text.trim(),
      photoMembre: _imageUrl ?? 'default.jpg',
      bio: _bioController.text.trim(),
      rang: int.tryParse(_rangController.text) ?? 10,
    );

    try {
      await ref.read(infoRepositoryProvider).saveCommitteeMember(member);
      _clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingId == null ? "Membre ajouté avec succès !" : "Profil mis à jour !"),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final committeeAsync = ref.watch(committeeProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('GESTION DU COMITÉ', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.premiumGold, fontFamily: 'Playfair Display')),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.premiumGold),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 30),
        child: Column(
          children: [
            _buildMemberForm(),
            const SizedBox(height: 50),
            _buildMembersList(committeeAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberForm() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_editingId == null ? "AJOUTER UN MEMBRE" : "MODIFIER LE MEMBRE", 
            style: const TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 25),
          _buildInput(_nomCompletController, "Nom Complet (Prénom Nom Postnom)"),
          const SizedBox(height: 15),
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppColors.deepNavy, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.premiumGold.withOpacity(0.3))),
                  child: _imageUrl == null 
                      ? const Icon(Icons.add_a_photo_rounded, color: AppColors.premiumGold, size: 24)
                      : ClipRRect(borderRadius: BorderRadius.circular(15), child: _imageUrl!.startsWith('http') ? Image.network(_imageUrl!, fit: BoxFit.cover) : Image.file(File(_imageUrl!), fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildInput(_fonctionController, "Fonction")),
                        const SizedBox(width: 15),
                        Expanded(flex: 1, child: _buildInput(_categorieController, "Catégorie")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(flex: 3, child: _buildInput(_bioController, "Biographie courte (Optionnel)")),
              const SizedBox(width: 15),
              Expanded(flex: 1, child: _buildInput(_rangController, "Rang (Ordre)", isNumeric: true)),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              if (_editingId != null) 
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: OutlinedButton(
                    onPressed: _clear, 
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                    child: const Text("ANNULER", style: TextStyle(color: Colors.white60))
                  ),
                ),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.premiumGold, 
                      foregroundColor: AppColors.deepNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(_editingId == null ? 'AJOUTER AU COMITÉ' : 'METTRE À JOUR LE PROFIL', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0A192F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      ),
    );
  }

  Widget _buildMembersList(AsyncValue<List<ComiteEntity>> asyncList) {
    return asyncList.when(
      data: (list) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final m = list[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF112240).withOpacity(0.5), 
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.premiumGold.withOpacity(0.05)),
            ),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.deepNavy, child: Icon(Icons.person, color: goldAccentAlpha)),
              title: Text(m.nomComplet.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(m.fonction, style: const TextStyle(color: AppColors.premiumGold, fontSize: 11, fontWeight: FontWeight.w600)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                    onPressed: () {
                      setState(() {
                        _editingId = m.id;
                        _nomCompletController.text = m.nomComplet;
                        _fonctionController.text = m.fonction;
                        _categorieController.text = m.categorie;
                        _bioController.text = m.bio;
                        _rangController.text = m.rang.toString();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => _confirmDelete(m.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.premiumGold)),
      error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.redAccent)),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepNavy,
        title: const Text("Supprimer ?", style: TextStyle(color: Colors.white)),
        content: const Text("Voulez-vous retirer ce membre du comité ?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(infoRepositoryProvider).deleteCommitteeMember(id);
            }, 
            child: const Text("SUPPRIMER", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }
}

const Color goldAccentAlpha = Color(0x33C5A059);
