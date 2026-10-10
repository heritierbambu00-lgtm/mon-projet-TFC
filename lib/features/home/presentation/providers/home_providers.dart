import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/gallery_item.dart';
import '../../../academic/domain/entities/faculte_entity.dart';
import '../../../info/domain/entities/comite_entity.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => HomeRepository());

final homeFacultiesProvider = StreamProvider<List<FaculteEntity>>((ref) {
  return ref.watch(homeRepositoryProvider).getFaculties();
});

final committeeStreamProvider = StreamProvider<List<ComiteEntity>>((ref) {
  return ref.watch(homeRepositoryProvider).getCommittee();
});

final newsStreamProvider = StreamProvider<List<NewsArticle>>((ref) {
  return ref.watch(homeRepositoryProvider).getNews();
});

final galleryStreamProvider = StreamProvider<List<GalleryItem>>((ref) {
  return ref.watch(homeRepositoryProvider).getGallery();
});

final globalStatsProvider = StreamProvider<Map<String, String>>((ref) {
  return ref.watch(homeRepositoryProvider).getGlobalStats();
});
