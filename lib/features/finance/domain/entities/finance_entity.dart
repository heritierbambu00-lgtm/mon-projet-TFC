import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceEntity {
  final String id;
  final double montantPaye;
  final String typeFrais;
  final DateTime datePaiement;
  final String idEtu;
  final String anneeAcad;

  FinanceEntity({
    required this.id,
    required this.montantPaye,
    required this.typeFrais,
    required this.datePaiement,
    required this.idEtu,
    required this.anneeAcad,
  });

  factory FinanceEntity.fromMap(Map<String, dynamic> map, String id) {
    return FinanceEntity(
      id: id,
      montantPaye: (map['montant_paye'] ?? 0).toDouble(),
      typeFrais: map['type_frais'] ?? '',
      datePaiement: (map['date_paiement'] as Timestamp?)?.toDate() ?? DateTime.now(),
      idEtu: map['id_etu']?.toString() ?? '',
      anneeAcad: map['annee_acad'] ?? '',
    );
  }
}
