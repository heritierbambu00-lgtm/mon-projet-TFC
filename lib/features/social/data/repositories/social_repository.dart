import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/chat_faculte_entity.dart';

class SocialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<ChatFaculteEntity>> getMessages(String faculte) {
    return _firestore.collection('chat_faculte')
        .where('faculte', isEqualTo: faculte)
        .orderBy('date_envoi', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatFaculteEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String idEtu,
    required String nomComplet,
    required String message,
    required String faculte,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    await _firestore.collection('chat_faculte').add({
      'id_etu': idEtu,
      'nom_utilisateur': nomComplet,
      'message': message,
      'type': type.name,
      'media_url': mediaUrl,
      'faculte': faculte,
      'date_envoi': FieldValue.serverTimestamp(),
      'deleted_by': [],
    });
  }

  Future<String?> uploadMedia(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // --- NEW SUPPRESSION LOGIC ---

  Future<void> deleteForMe(List<String> messageIds, String userId) async {
    final batch = _firestore.batch();
    for (final id in messageIds) {
      batch.update(_firestore.collection('chat_faculte').doc(id), {
        'deleted_by': FieldValue.arrayUnion([userId])
      });
    }
    await batch.commit();
  }

  Future<void> deleteForEveryone(List<String> messageIds) async {
    final batch = _firestore.batch();
    for (final id in messageIds) {
      batch.update(_firestore.collection('chat_faculte').doc(id), {
        'type': MessageType.deleted.name,
        'message': '',
        'media_url': null,
      });
    }
    await batch.commit();
  }

  Future<void> clearChatForMe(String faculte, String userId) async {
    final query = await _firestore.collection('chat_faculte')
        .where('faculte', isEqualTo: faculte)
        .get();
    
    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'deleted_by': FieldValue.arrayUnion([userId])
      });
    }
    await batch.commit();
  }
}
