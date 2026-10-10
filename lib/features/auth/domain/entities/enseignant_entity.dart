class EnseignantEntity {
  final String id;
  final String matriculeEns;
  final String nomEns;
  final String postnomEns;
  final String emailPro;
  final String specialite;
  final String photoEns;
  final String password;

  EnseignantEntity({
    required this.id,
    required this.matriculeEns,
    required this.nomEns,
    required this.postnomEns,
    required this.emailPro,
    required this.specialite,
    required this.photoEns,
    this.password = '',
  });

  factory EnseignantEntity.fromMap(Map<String, dynamic> map, String id) {
    return EnseignantEntity(
      id: id,
      matriculeEns: map['matricule_ens'] ?? '',
      nomEns: map['nom_ens'] ?? '',
      postnomEns: map['postnom_ens'] ?? '',
      emailPro: map['email_pro'] ?? '',
      specialite: map['specialite'] ?? '',
      photoEns: map['photo_ens'] ?? 'default.jpg',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matricule_ens': matriculeEns,
      'nom_ens': nomEns,
      'postnom_ens': postnomEns,
      'email_pro': emailPro,
      'specialite': specialite,
      'photo_ens': photoEns,
      'password': password,
    };
  }
}
