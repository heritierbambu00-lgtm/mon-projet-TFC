import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/home/presentation/providers/home_providers.dart';
import '../providers/info_providers.dart';
import '../../../home/domain/entities/news_article.dart';

class NewsManagementPage extends ConsumerStatefulWidget {
  const NewsManagementPage({super.key});

  @override
  ConsumerState<NewsManagementPage> createState() => _NewsManagementPageState();
}

class _NewsManagementPageState extends ConsumerState<NewsManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _editingId;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageUrl = image.path);
    }
  }

  void _save() async {
    if (_titleController.text.isEmpty || (_imageUrl == null && _editingId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Titre et Image sont requis.")));
      return;
    }

    final article = NewsArticle(
      id: _editingId ?? '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imageUrl: _imageUrl ?? '',
      date: DateTime.now(),
    );

    try {
      await ref.read(infoRepositoryProvider).saveNews(article);
      _titleController.clear();
      _contentController.clear();
      _imageUrl = null;
      _editingId = null;
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Article publié !")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('GESTION DES ACTUALITÉS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.premiumGold, fontFamily: 'Playfair Display')),
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
            newsAsync.when(
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
          Text(_editingId == null ? "PUBLIER UNE ACTUALITÉ" : "MODIFIER L'ARTICLE", style: const TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 25),
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: AppColors.deepNavy, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.premiumGold.withOpacity(0.3))),
                  child: _imageUrl == null 
                      ? const Icon(Icons.add_photo_alternate_rounded, color: AppColors.premiumGold, size: 30)
                      : ClipRRect(borderRadius: BorderRadius.circular(15), child: _imageUrl!.startsWith('http') ? Image.network(_imageUrl!, fit: BoxFit.cover) : Image.file(File(_imageUrl!), fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(hintText: "Titre de l'article", filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _contentController,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: "Contenu de l'article...", filled: true, fillColor: AppColors.deepNavy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.premiumGold, foregroundColor: AppColors.deepNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: Text(_editingId == null ? 'PUBLIER MAINTENANT' : 'METTRE À JOUR', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<NewsArticle> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final n = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(color: const Color(0xFF112240).withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(n.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.newspaper)),
            ),
            title: Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20), onPressed: () {
                  setState(() {
                    _editingId = n.id;
                    _titleController.text = n.title;
                    _contentController.text = n.content;
                    _imageUrl = n.imageUrl;
                  });
                }),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), onPressed: () => ref.read(infoRepositoryProvider).deleteNews(n.id)),
              ],
            ),
          ),
        );
      },
    );
  }
}
