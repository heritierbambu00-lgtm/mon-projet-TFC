class ResultatEntity {
  final String id;
  final double cote;
  final String session;
  final String idEtu;
  final String idCours;
  final String anneeAcad;
  final int semestre;

  ResultatEntity({
    required this.id,
    required this.cote,
    required this.session,
    required this.idEtu,
    required this.idCours,
    required this.anneeAcad,
    required this.semestre,
  });

  factory ResultatEntity.fromMap(Map<String, dynamic> map, String id) {
    return ResultatEntity(
      id: id,
      cote: (map['cote'] ?? 0).toDouble(),
      session: map['session'] ?? '',
      idEtu: map['id_etu']?.toString() ?? '',
      idCours: map['id_cours']?.toString() ?? '',
      anneeAcad: map['annee_academique'] ?? '',
      semestre: map['semestre'] ?? 1,
    );
  }
}
