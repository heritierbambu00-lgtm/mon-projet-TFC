class AdminEntity {
  final String id;
  final String nomComplet;
  final String matricule;
  final String role;

  AdminEntity({
    required this.id,
    required this.nomComplet,
    required this.matricule,
    this.role = 'admin',
  });

  factory AdminEntity.fromMap(Map<String, dynamic> map, String id) {
    return AdminEntity(
      id: id,
      nomComplet: map['nom_complet'] ?? '',
      matricule: map['matricule'] ?? '',
      role: map['role'] ?? 'admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom_complet': nomComplet,
      'matricule': matricule,
      'role': role,
    };
  }
}
