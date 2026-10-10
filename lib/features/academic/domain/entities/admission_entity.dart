import 'package:cloud_firestore/cloud_firestore.dart';

class AdmissionEntity {
  final String id;
  final String nom;
  final String postnom;
  final String prenom;
  final String genre;
  final String telephone;
  final String lieuNaissance;
  final DateTime dateNaissance;
  final String adressePermanente;
  final String adresseContact;
  final String nationalite;
  final String provinceOrigine;
  final String villageOrigine;
  final String etatCivil;
  final String ecoleSecondaire;
  final String adresseEcole;
  final String centreExamen;
  final int anneeObtentionEtat;
  final double pourcentageEtat;
  final String numeroDiplome;
  final String postSecondaire;
  final String codePromotion;
  final DateTime dateSoumission;

  AdmissionEntity({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.genre,
    required this.telephone,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.adressePermanente,
    required this.adresseContact,
    required this.nationalite,
    required this.provinceOrigine,
    required this.villageOrigine,
    required this.etatCivil,
    required this.ecoleSecondaire,
    required this.adresseEcole,
    required this.centreExamen,
    required this.anneeObtentionEtat,
    required this.pourcentageEtat,
    required this.numeroDiplome,
    required this.postSecondaire,
    required this.codePromotion,
    required this.dateSoumission,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'genre': genre,
      'telephone': telephone,
      'lieu_naissance': lieuNaissance,
      'date_naissance': dateNaissance,
      'adresse_permanente': adressePermanente,
      'adresse_contact': adresseContact,
      'nationalite': nationalite,
      'province_origine': provinceOrigine,
      'village_origine': villageOrigine,
      'etat_civil': etatCivil,
      'ecole_secondaire': ecoleSecondaire,
      'adresse_ecole': adresseEcole,
      'centre_examen': centreExamen,
      'annee_obtention_etat': anneeObtentionEtat,
      'pourcentage_etat': pourcentageEtat,
      'numero_diplome': numeroDiplome,
      'post_secondaire': postSecondaire,
      'code_promotion': codePromotion,
      'date_soumission': dateSoumission,
    };
  }

  factory AdmissionEntity.fromMap(Map<String, dynamic> map, String id) {
    return AdmissionEntity(
      id: id,
      nom: map['nom'] ?? '',
      postnom: map['postnom'] ?? '',
      prenom: map['prenom'] ?? '',
      genre: map['genre'] ?? '',
      telephone: map['telephone'] ?? '',
      lieuNaissance: map['lieu_naissance'] ?? '',
      dateNaissance: (map['date_naissance'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adressePermanente: map['adresse_permanente'] ?? '',
      adresseContact: map['adresse_contact'] ?? '',
      nationalite: map['nationalite'] ?? '',
      provinceOrigine: map['province_origine'] ?? '',
      villageOrigine: map['village_origine'] ?? '',
      etatCivil: map['etat_civil'] ?? '',
      ecoleSecondaire: map['ecole_secondaire'] ?? '',
      adresseEcole: map['adresse_ecole'] ?? '',
      centreExamen: map['centre_examen'] ?? '',
      anneeObtentionEtat: map['annee_obtention_etat'] ?? 0,
      pourcentageEtat: (map['pourcentage_etat'] ?? 0).toDouble(),
      numeroDiplome: map['numero_diplome'] ?? '',
      postSecondaire: map['post_secondaire'] ?? '',
      codePromotion: map['code_promotion'] ?? '',
      dateSoumission: (map['date_soumission'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
