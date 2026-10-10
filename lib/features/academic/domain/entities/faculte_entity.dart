class FaculteEntity {
  final String id;
  final String nomFaculte;

  FaculteEntity({required this.id, required this.nomFaculte});

  factory FaculteEntity.fromMap(Map<String, dynamic> map, String id) {
    return FaculteEntity(
      id: id,
      nomFaculte: map['nom_faculte'] ?? '',
    );
  }
}
