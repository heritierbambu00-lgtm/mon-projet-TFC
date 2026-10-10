import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEventEntity {
  final String id;
  final String titreEvent;
  final String descriptionEvent;
  final DateTime dateDebut;
  final DateTime dateFin;

  CalendarEventEntity({
    required this.id,
    required this.titreEvent,
    required this.descriptionEvent,
    required this.dateDebut,
    required this.dateFin,
  });

  factory CalendarEventEntity.fromMap(Map<String, dynamic> map, String id) {
    return CalendarEventEntity(
      id: id,
      titreEvent: map['titre_event'] ?? '',
      descriptionEvent: map['description_event'] ?? '',
      dateDebut: (map['date_debut'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateFin: (map['date_fin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
