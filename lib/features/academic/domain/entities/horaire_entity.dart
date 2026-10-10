import 'package:cloud_firestore/cloud_firestore.dart';

class HoraireEntity {
  final String id;
  final String heureDebut;
  final String heureFin;
  final String salle;
  final String idCours;
  final String idPromo;
  final DateTime dateCours;
  final String jour;

  HoraireEntity({
    required this.id,
    required this.heureDebut,
    required this.heureFin,
    required this.salle,
    required this.idCours,
    required this.idPromo,
    required this.dateCours,
    required this.jour,
  });

  factory HoraireEntity.fromMap(Map<String, dynamic> map, String id) {
    return HoraireEntity(
      id: id,
      heureDebut: map['heure_debut'] ?? '',
      heureFin: map['heure_fin'] ?? '',
      salle: map['salle'] ?? '',
      idCours: map['id_cours']?.toString() ?? '',
      idPromo: map['id_promo']?.toString() ?? '',
      dateCours: (map['date_cours'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jour: map['jour'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'salle': salle,
      'id_cours': idCours,
      'id_promo': idPromo,
      'date_cours': Timestamp.fromDate(dateCours),
      'jour': jour,
    };
  }
}
