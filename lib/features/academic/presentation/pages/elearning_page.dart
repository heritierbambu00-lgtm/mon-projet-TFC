import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/resources/presentation/providers/resource_providers.dart';
import 'package:istm_mahagi/features/resources/domain/entities/elearning_entity.dart';

class ELearningPage extends ConsumerStatefulWidget {
  const ELearningPage({super.key});

  @override
  ConsumerState<ELearningPage> createState() => _ELearningPageState();
}

class _ELearningPageState extends ConsumerState<ELearningPage> {
  @override
  Widget build(BuildContext context) {
    final elearningAsync = ref.watch(elearningProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.darkBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('E-LEARNING PLATFORM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/slider1.jpg', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3)),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
                ],
              ),
            ),
          ),
          elearningAsync.when(
            data: (resources) {
              if (resources.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Aucune donnée disponible', style: TextStyle(color: AppColors.textMuted))),
                );
              }

              final videos = resources.where((r) => r.typeFichier.toLowerCase() == 'video' || r.typeFichier.toLowerCase() == 'mp4').toList();
              final books = resources.where((r) => r.typeFichier.toLowerCase() == 'pdf' || r.typeFichier.toLowerCase() == 'livre').toList();

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (videos.isNotEmpty) ...[
                        const Text('Cours Vidéos Récents', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 280,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: videos.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 20),
                            itemBuilder: (context, index) => _buildVideoCard(videos[index]),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                      if (books.isNotEmpty) ...[
                        const Text('Bibliothèque Numérique', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: books.length,
                          itemBuilder: (context, index) => _buildBookCard(books[index]),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Erreur: \$err'))),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(ElearningEntity resource) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 180,
                  width: 350,
                  color: AppColors.darkBlue.withOpacity(0.1),
                  child: const Icon(Icons.video_library, size: 50, color: AppColors.primaryBlue),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: AppColors.primaryBlue, size: 30),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.titreRessource, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text('Vidéo • \${resource.typeFichier}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(ElearningEntity resource) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book, size: 50, color: AppColors.primaryBlue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(resource.titreRessource, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 2),
                const SizedBox(height: 5),
                Text('PDF • \${resource.typeFichier}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
