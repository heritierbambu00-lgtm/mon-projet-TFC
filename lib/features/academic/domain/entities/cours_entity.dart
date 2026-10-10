class CoursEntity {
  final String id;
  final int idCours;
  final String codeCours;
  final String intituleCours;
  final int credits;
  final String idEns;
  final String idPromo;
  final String? anneeAcad;
  final String semestre;
  final String? supportCours;

  CoursEntity({
    required this.id,
    required this.idCours,
    required this.codeCours,
    required this.intituleCours,
    required this.credits,
    required this.idEns,
    required this.idPromo,
    this.anneeAcad,
    this.semestre = 'S1',
    this.supportCours,
  });

  factory CoursEntity.fromMap(Map<String, dynamic> map, String id) {
    return CoursEntity(
      id: id,
      idCours: int.tryParse(map['id_cours']?.toString() ?? '0') ?? 0,
      codeCours: map['code_cours'] ?? '',
      intituleCours: map['intitule_cours'] ?? '',
      credits: map['credits'] ?? 1,
      idEns: map['id_ens']?.toString() ?? '',
      idPromo: map['id_promo']?.toString() ?? '',
      anneeAcad: map['annee_academique']?.toString(),
      semestre: map['semestre']?.toString() ?? 'S1',
      supportCours: map['support_cours'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cours': idCours,
      'code_cours': codeCours,
      'intitule_cours': intituleCours,
      'credits': credits,
      'id_ens': idEns,
      'id_promo': idPromo,
      'annee_academique': anneeAcad,
      'semestre': semestre,
      'support_cours': supportCours,
    };
  }
}
