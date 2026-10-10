import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntity {
  final String id;
  final String titre;
  final String contenu;
  final DateTime dateMaj;

  HistoryEntity({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.dateMaj,
  });

  factory HistoryEntity.fromMap(Map<String, dynamic> map, String id) {
    return HistoryEntity(
      id: id,
      titre: map['titre'] ?? 'Notre Histoire',
      contenu: map['contenu'] ?? '',
      dateMaj: (map['date_maj'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
