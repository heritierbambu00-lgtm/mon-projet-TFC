import 'package:cloud_firestore/cloud_firestore.dart';

class StaffEntity {
  final String id;
  final String nom;
  final String postnom;
  final String prenom;
  final String grade;
  final String fonction;
  final String matriculeStaff;
  final String emailPro;
  final DateTime dateEnregistrement;
  final String role;

  StaffEntity({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.grade,
    required this.fonction,
    required this.matriculeStaff,
    required this.emailPro,
    required this.dateEnregistrement,
    this.role = 'staff',
  });

  factory StaffEntity.fromMap(Map<String, dynamic> map, String id) {
    return StaffEntity(
      id: id,
      nom: map['nom'] ?? '',
      postnom: map['postnom'] ?? '',
      prenom: map['prenom'] ?? '',
      grade: map['grade'] ?? '',
      fonction: map['fonction'] ?? '',
      matriculeStaff: map['matricule_staff'] ?? '',
      emailPro: map['email_pro'] ?? '',
      dateEnregistrement: (map['date_enregistrement'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: map['role'] ?? 'staff',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'grade': grade,
      'fonction': fonction,
      'matricule_staff': matriculeStaff,
      'email_pro': emailPro,
      'date_enregistrement': dateEnregistrement,
      'role': role,
    };
  }
}
