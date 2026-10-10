import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/home/presentation/providers/home_providers.dart';
import '../providers/info_providers.dart';
import '../../../home/domain/entities/gallery_item.dart';

class GalleryManagementPage extends ConsumerStatefulWidget {
  const GalleryManagementPage({super.key});

  @override
  ConsumerState<GalleryManagementPage> createState() => _GalleryManagementPageState();
}

class _GalleryManagementPageState extends ConsumerState<GalleryManagementPage> {
  final TextEditingController _captionController = TextEditingController();
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageUrl = image.path);
    }
  }

  void _save() async {
    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez choisir une photo.")));
      return;
    }

    final item = GalleryItem(
      id: '',
      imageUrl: _imageUrl!,
      legende: _captionController.text.trim(),
      date: DateTime.now(),
    );

    try {
      await ref.read(infoRepositoryProvider).saveGalleryItem(item);
      _captionController.clear();
      _imageUrl = null;
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image ajoutée !")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(galleryStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('GESTION DE LA GALERIE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.premiumGold, fontFamily: 'Playfair Display')),
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
            galleryAsync.when(
              data: (list) => _buildGrid(list),
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
          const Text("AJOUTER UNE PHOTO", style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 25),
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: AppColors.deepNavy, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.premiumGold.withOpacity(0.3))),
                  child: _imageUrl == null 
                      ? const Icon(Icons.add_a_photo_rounded, color: AppColors.premiumGold, size: 30)
                      : ClipRRect(borderRadius: BorderRadius.circular(15), child: _imageUrl!.startsWith('http') ? Image.network(_imageUrl!, fit: BoxFit.cover) : Image.file(File(_imageUrl!), fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: _captionController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: "Légende de la photo", filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text("PUBLIER DANS LA GALERIE", style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.premiumGold, foregroundColor: AppColors.deepNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<GalleryItem> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(item.imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey, child: const Icon(Icons.broken_image, color: Colors.white24))),
            ),
            Positioned(
              top: 5, right: 5,
              child: IconButton(
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                onPressed: () => ref.read(infoRepositoryProvider).deleteGalleryItem(item.id),
              ),
            ),
          ],
        );
      },
    );
  }
}
