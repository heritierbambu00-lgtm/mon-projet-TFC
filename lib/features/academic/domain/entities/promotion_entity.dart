class PromotionEntity {
  final String id;
  final String nomPromo;
  final String idDept;
  final String? idPromoAlt; // Capture le champ 'id_promo' s'il existe
  final double seuilFinance;
  final String? anneeAcad;

  PromotionEntity({
    required this.id,
    required this.nomPromo,
    required this.idDept,
    this.idPromoAlt,
    this.seuilFinance = 0,
    this.anneeAcad,
  });

  factory PromotionEntity.fromMap(Map<String, dynamic> map, String id) {
    return PromotionEntity(
      id: id,
      nomPromo: map['nom_promo'] ?? '',
      idDept: map['id_dept']?.toString() ?? '',
      idPromoAlt: map['id_promo']?.toString(),
      seuilFinance: (map['seuil_finance'] ?? 0).toDouble(),
      anneeAcad: map['annee_academique']?.toString() ?? map['annee_acad']?.toString(),
    );
  }

  /// Renvoie l'ID le plus stable pour cette promotion
  String get stableId => idPromoAlt ?? id;
}
