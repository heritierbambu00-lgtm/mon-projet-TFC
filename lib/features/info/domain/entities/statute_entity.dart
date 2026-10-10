class StatuteEntity {
  final String id;
  final String titre;
  final String description;
  final String? fichierPdf;

  StatuteEntity({
    required this.id,
    required this.titre,
    required this.description,
    this.fichierPdf,
  });

  factory StatuteEntity.fromMap(Map<String, dynamic> map, String id) {
    return StatuteEntity(
      id: id,
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      fichierPdf: map['fichier_pdf'],
    );
  }
}
