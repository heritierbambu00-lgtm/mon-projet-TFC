import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/elearning_entity.dart';

class ResourceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ElearningEntity>> getELearningResources() {
    return _firestore.collection('elearning').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ElearningEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
}
