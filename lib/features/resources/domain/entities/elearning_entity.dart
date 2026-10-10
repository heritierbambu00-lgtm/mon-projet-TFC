class ElearningEntity {
  final String id;
  final String titreRessource;
  final String typeFichier;
  final String lienUrl;
  final String idCours;

  ElearningEntity({
    required this.id,
    required this.titreRessource,
    required this.typeFichier,
    required this.lienUrl,
    required this.idCours,
  });

  factory ElearningEntity.fromMap(Map<String, dynamic> map, String id) {
    return ElearningEntity(
      id: id,
      titreRessource: map['titre_ressource'] ?? '',
      typeFichier: map['type_fichier'] ?? '',
      lienUrl: map['lien_url'] ?? '',
      idCours: map['id_cours']?.toString() ?? '',
    );
  }
}
