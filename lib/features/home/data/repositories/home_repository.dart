import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/gallery_item.dart';
import '../../../academic/domain/entities/faculte_entity.dart';
import '../../../info/domain/entities/comite_entity.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FaculteEntity>> getFaculties() {
    return _firestore
        .collection('facultes')
        .orderBy('nom_faculte')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FaculteEntity.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ComiteEntity>> getCommittee() {
    return _firestore
        .collection('comite')
        .orderBy('rang', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComiteEntity.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<NewsArticle>> getNews() {
    return _firestore
        .collection('news')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NewsArticle.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<GalleryItem>> getGallery() {
    return _firestore
        .collection('gallery')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<Map<String, String>> getGlobalStats() {
    return _firestore
        .collection('config')
        .doc('stats_globales')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            return {
              'annees': data['annees']?.toString() ?? '...',
              'etudiants': data['etudiants']?.toString() ?? '...',
              'departements': data['departements']?.toString() ?? '...',
              'homologation': data['homologation']?.toString() ?? '...',
            };
          }
          return {
            'annees': '...',
            'etudiants': '...',
            'departements': '...',
            'homologation': '...',
          };
        });
  }
}
