class NoteEntity {
  final String id;
  final String idEtu;
  final String idCours;
  final double coteEx;
  final double coteTp;
  final int semestre;
  final String anneeAcad;

  NoteEntity({
    required this.id,
    required this.idEtu,
    required this.idCours,
    required this.coteEx,
    required this.coteTp,
    required this.semestre,
    required this.anneeAcad,
  });

  factory NoteEntity.fromMap(Map<String, dynamic> map, String id) {
    return NoteEntity(
      id: id,
      idEtu: map['id_etu']?.toString() ?? '',
      idCours: map['id_cours']?.toString() ?? '',
      coteEx: (map['cote_ex'] ?? 0).toDouble(),
      coteTp: (map['cote_tp'] ?? 0).toDouble(),
      semestre: map['semestre'] ?? 1,
      anneeAcad: map['annee_academique'] ?? '',
    );
  }
}
