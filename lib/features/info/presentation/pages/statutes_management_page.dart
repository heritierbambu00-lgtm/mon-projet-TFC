import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/statute_entity.dart';

class StatutesManagementPage extends ConsumerStatefulWidget {
  const StatutesManagementPage({super.key});

  @override
  ConsumerState<StatutesManagementPage> createState() => _StatutesManagementPageState();
}

class _StatutesManagementPageState extends ConsumerState<StatutesManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _editingId;

  void _save() async {
    if (_titleController.text.isEmpty) return;

    final statute = StatuteEntity(
      id: _editingId ?? '',
      titre: _titleController.text.trim(),
      description: _descController.text.trim(),
      fichierPdf: 'standard_statut.pdf',
    );

    try {
      await ref.read(infoRepositoryProvider).addStatute(statute);
      _titleController.clear();
      _descController.clear();
      _editingId = null;
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document ajouté !")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final statutesAsync = ref.watch(statutesProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('GESTION DES STATUTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.premiumGold, fontFamily: 'Playfair Display')),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.premiumGold),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context), vertical: 30),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 50),
            statutesAsync.when(
              data: (list) => _buildList(list),
              loading: () => const CircularProgressIndicator(color: AppColors.premiumGold),
              error: (e, _) => Text("Erreur : $e"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.premiumGold.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AJOUTER UN DOCUMENT", style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 25),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: "Titre du document", filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: "Description courte", filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.add_rounded),
              label: const Text("PUBLIER LE DOCUMENT", style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.premiumGold, foregroundColor: AppColors.deepNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<StatuteEntity> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final s = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(color: const Color(0xFF112240).withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
            title: Text(s.titre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () => ref.read(infoRepositoryProvider).deleteStatute(s.id),
            ),
          ),
        );
      },
    );
  }
}
