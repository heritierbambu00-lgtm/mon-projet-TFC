class ComiteEntity {
  final String id;
  final String nomComplet;
  final String fonction;
  final String categorie;
  final String photoMembre;
  final String bio;
  final int rang;

  ComiteEntity({
    required this.id,
    required this.nomComplet,
    required this.fonction,
    required this.categorie,
    required this.photoMembre,
    required this.bio,
    required this.rang,
  });

  factory ComiteEntity.fromMap(Map<String, dynamic> map, String id) {
    return ComiteEntity(
      id: id,
      nomComplet: map['nom_complet'] ?? '',
      fonction: map['fonction'] ?? '',
      categorie: map['categorie'] ?? 'Direction',
      photoMembre: map['photo_membre'] ?? '',
      bio: map['bio'] ?? '',
      rang: map['rang'] ?? 0,
    );
  }
}
