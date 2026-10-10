class AppUser {
  final String uid;
  final String matricule;
  final String nom;
  final String role;
  final String promo;
  final String? photoUrl;
  final String sexe;

  AppUser({
    required this.uid,
    required this.matricule,
    required this.nom,
    required this.role,
    required this.promo,
    this.photoUrl,
    required this.sexe,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      matricule: map['matricule'] ?? '',
      nom: map['nom'] ?? '',
      role: map['role'] ?? 'etudiant',
      promo: map['promo'] ?? '',
      photoUrl: map['photoUrl'],
      sexe: map['sexe'] ?? 'M',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matricule': matricule,
      'nom': nom,
      'role': role,
      'promo': promo,
      'photoUrl': photoUrl,
      'sexe': sexe,
    };
  }
}
