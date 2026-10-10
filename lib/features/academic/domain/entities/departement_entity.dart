class DepartementEntity {
  final String id;
  final String nomDept;
  final String idFaculte;
  final bool resultatsOuverts;
  final bool evalProfsOuverte;

  DepartementEntity({
    required this.id,
    required this.nomDept,
    required this.idFaculte,
    this.resultatsOuverts = false,
    this.evalProfsOuverte = false,
  });

  factory DepartementEntity.fromMap(Map<String, dynamic> map, String id) {
    return DepartementEntity(
      id: id,
      nomDept: map['nom_dept'] ?? '',
      idFaculte: map['id_faculte']?.toString() ?? '',
      resultatsOuverts: map['resultats_ouverts'] == 1 || map['resultats_ouverts'] == true,
      evalProfsOuverte: map['eval_profs_ouverte'] == 1 || map['eval_profs_ouverte'] == true,
    );
  }
}
