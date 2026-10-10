import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/anthem_entity.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/entities/mission_vision_entity.dart';
import '../../domain/entities/statute_entity.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/entities/comite_entity.dart';
import '../../../home/domain/entities/news_article.dart';
import '../../../home/domain/entities/gallery_item.dart';

class InfoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AnthemEntity?> getAnthem() {
    return _firestore
        .collection('hymne')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return AnthemEntity.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
          }
          return null;
        });
  }

  Stream<HistoryEntity?> getHistory() {
    return _firestore
        .collection('historique')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return HistoryEntity.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
          }
          return null;
        });
  }

  Stream<MissionVisionEntity?> getMissionVision() {
    return _firestore
        .collection('mission_vision')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return MissionVisionEntity.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
          }
          return null;
        });
  }

  Stream<List<StatuteEntity>> getStatutes() {
    return _firestore
        .collection('status_uac')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StatuteEntity.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<CalendarEventEntity>> getCalendarEvents() {
    return _firestore
        .collection('calendrier')
        .orderBy('date_debut', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalendarEventEntity.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addCalendarEvent(CalendarEventEntity event) {
    return _firestore.collection('calendrier').add({
      'titre_event': event.titreEvent,
      'description_event': event.descriptionEvent,
      'date_debut': Timestamp.fromDate(event.dateDebut),
      'date_fin': Timestamp.fromDate(event.dateFin),
    });
  }

  Future<void> deleteCalendarEvent(String id) {
    return _firestore.collection('calendrier').doc(id).delete();
  }

  Future<void> updateHistory(HistoryEntity history) async {
    final data = {
      'titre': history.titre,
      'contenu': history.contenu,
      'date_creation': FieldValue.serverTimestamp(),
    };
    if (history.id.isEmpty) {
      await _firestore.collection('historique').add(data);
    } else {
      await _firestore.collection('historique').doc(history.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> updateMissionVision(MissionVisionEntity mv) async {
    final data = {
      'mission': mv.mission,
      'vision': mv.vision,
      'valeurs': mv.valeurs,
    };
    if (mv.id.isEmpty) {
      await _firestore.collection('mission_vision').add(data);
    } else {
      await _firestore.collection('mission_vision').doc(mv.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> updateAnthem(AnthemEntity anthem) async {
    final data = {
      'titre': anthem.titre,
      'paroles': anthem.paroles,
    };
    if (anthem.id.isEmpty) {
      await _firestore.collection('hymne').add(data);
    } else {
      await _firestore.collection('hymne').doc(anthem.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> saveCommitteeMember(ComiteEntity member) async {
    final data = {
      'nom_complet': member.nomComplet,
      'fonction': member.fonction,
      'photo_membre': member.photoMembre,
      'rang': member.rang,
      'categorie': member.categorie,
      'bio': member.bio,
    };
    if (member.id.isEmpty) {
      await _firestore.collection('comite').add(data);
    } else {
      await _firestore.collection('comite').doc(member.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteCommitteeMember(String id) {
    return _firestore.collection('comite').doc(id).delete();
  }

  Future<void> addStatute(StatuteEntity statute) {
    return _firestore.collection('status_uac').add({
      'titre': statute.titre,
      'fichier_pdf': statute.fichierPdf,
      'description': statute.description,
      'date_pub': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteStatute(String id) {
    return _firestore.collection('status_uac').doc(id).delete();
  }

  // --- NEWS MANAGEMENT ---
  Future<void> saveNews(NewsArticle article) async {
    final data = {
      'title': article.title,
      'content': article.content,
      'imageUrl': article.imageUrl,
      'date': article.id.isEmpty ? FieldValue.serverTimestamp() : Timestamp.fromDate(article.date),
    };
    if (article.id.isEmpty) {
      await _firestore.collection('news').add(data);
    } else {
      await _firestore.collection('news').doc(article.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteNews(String id) {
    return _firestore.collection('news').doc(id).delete();
  }

  // --- GALLERY MANAGEMENT ---
  Future<void> saveGalleryItem(GalleryItem item) async {
    final data = {
      'imageUrl': item.imageUrl,
      'legende': item.legende,
      'date': item.id.isEmpty ? FieldValue.serverTimestamp() : Timestamp.fromDate(item.date),
    };
    if (item.id.isEmpty) {
      await _firestore.collection('gallery').add(data);
    } else {
      await _firestore.collection('gallery').doc(item.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteGalleryItem(String id) {
    return _firestore.collection('gallery').doc(id).delete();
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
}
