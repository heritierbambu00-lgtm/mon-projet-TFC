class BibliothequeEntity {
  final String id;
  final String titreLivre;
  final String auteurLivre;
  final String isbn;
  final String categorie;
  final bool disponibilite;

  BibliothequeEntity({
    required this.id,
    required this.titreLivre,
    required this.auteurLivre,
    required this.isbn,
    required this.categorie,
    required this.disponibilite,
  });

  factory BibliothequeEntity.fromMap(Map<String, dynamic> map, String id) {
    return BibliothequeEntity(
      id: id,
      titreLivre: map['titre_livre'] ?? '',
      auteurLivre: map['auteur_livre'] ?? '',
      isbn: map['isbn'] ?? '',
      categorie: map['categorie'] ?? '',
      disponibilite: map['disponibilite'] == 1 || map['disponibilite'] == true,
    );
  }
}
