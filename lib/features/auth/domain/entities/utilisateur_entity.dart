class UtilisateurEntity {
  final String id;
  final String nomUser;
  final String prenomUser;
  final String matricule;
  final String password;
  final String role; // admin, secretaire, decanat, comptable
  final String idDept;
  final bool statut;

  UtilisateurEntity({
    required this.id,
    required this.nomUser,
    required this.prenomUser,
    required this.matricule,
    required this.password,
    required this.role,
    required this.idDept,
    this.statut = true,
  });

  factory UtilisateurEntity.fromMap(Map<String, dynamic> map, String id) {
    return UtilisateurEntity(
      id: id,
      nomUser: map['nom_user'] ?? '',
      prenomUser: map['prenom_user'] ?? '',
      matricule: map['matricule'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      idDept: map['id_dept']?.toString() ?? '',
      statut: map['statut'] == 1 || map['statut'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom_user': nomUser,
      'prenom_user': prenomUser,
      'matricule': matricule,
      'password': password,
      'role': role,
      'id_dept': idDept,
      'statut': statut ? 1 : 0,
    };
  }
}
