import 'package:cloud_firestore/cloud_firestore.dart';

class EtudiantEntity {
  final String id;
  final String matriculeEtu;
  final String nomEtu;
  final String postnomEtu;
  final String prenomEtu;
  final String emailPersonnel;
  final String photoProfil;
  final String idPromo;
  final String sexe;
  final String etatCivil;
  final String telephone;
  final String telTuteur;
  final String lieuNaissance;
  final DateTime? dateNaissance;
  final String typeIdentite;
  final String numIdentite;
  final String ville;
  final String commune;
  final String quartier;
  final String nationalite;
  final String provinceOrigine;
  final String territoireOrigine;
  final String secteur;
  final String village;
  final String ecoleSecondaire;
  final String adresseEcole;
  final String orientation;
  final String centreExamenEtat;
  final String pourcentage;
  final String numDiplome;
  final String nomPere;
  final String nomMere;
  final String sponsor;
  final String groupeSanguin;
  final String taille;
  final String alergie;
  final String handicap;
  final String password;
  final List<Map<String, dynamic>> historiqueInscriptions;

  EtudiantEntity({
    required this.id,
    required this.matriculeEtu,
    required this.nomEtu,
    required this.postnomEtu,
    required this.prenomEtu,
    required this.emailPersonnel,
    this.photoProfil = 'default.jpg',
    required this.idPromo,
    required this.sexe,
    this.etatCivil = 'Célibataire',
    required this.telephone,
    required this.telTuteur,
    required this.lieuNaissance,
    this.dateNaissance,
    required this.typeIdentite,
    required this.numIdentite,
    required this.ville,
    required this.commune,
    required this.quartier,
    this.nationalite = 'CONGOLAISE',
    required this.provinceOrigine,
    required this.territoireOrigine,
    required this.secteur,
    required this.village,
    required this.ecoleSecondaire,
    required this.adresseEcole,
    required this.orientation,
    required this.centreExamenEtat,
    required this.pourcentage,
    required this.numDiplome,
    required this.nomPere,
    required this.nomMere,
    required this.sponsor,
    required this.groupeSanguin,
    required this.taille,
    required this.alergie,
    this.handicap = 'NON',
    this.password = '',
    this.historiqueInscriptions = const [],
  });

  factory EtudiantEntity.fromMap(Map<String, dynamic> map, String id) {
    return EtudiantEntity(
      id: id,
      matriculeEtu: map['matricule_etu'] ?? '',
      nomEtu: map['nom_etu'] ?? '',
      postnomEtu: map['postnom_etu'] ?? '',
      prenomEtu: map['prenom_etu'] ?? '',
      emailPersonnel: map['email_personnel'] ?? '',
      photoProfil: map['photo_profil'] ?? 'default.jpg',
      idPromo: (map['id_promo'] ?? map['idPromo'] ?? '').toString(),
      sexe: map['Sexe'] ?? map['sexe'] ?? '',
      etatCivil: map['etat_civil'] ?? 'Célibataire',
      telephone: map['telephone'] ?? '',
      telTuteur: map['tel_tuteur'] ?? '',
      lieuNaissance: map['lieu_naissance'] ?? '',
      dateNaissance: (map['date_naissance'] as Timestamp?)?.toDate(),
      typeIdentite: map['type_identite'] ?? '',
      numIdentite: map['num_identite'] ?? '',
      ville: map['ville'] ?? '',
      commune: map['commune'] ?? '',
      quartier: map['quartier'] ?? '',
      nationalite: map['nationalite'] ?? 'CONGOLAISE',
      provinceOrigine: map['province_origine'] ?? '',
      territoireOrigine: map['territoire_origine'] ?? '',
      secteur: map['secteur'] ?? '',
      village: map['village'] ?? '',
      ecoleSecondaire: map['ecole_secondaire'] ?? '',
      adresseEcole: map['adresse_ecole'] ?? '',
      orientation: map['orientation'] ?? '',
      centreExamenEtat: map['centre_examen_etat'] ?? '',
      pourcentage: map['pourcentage'] ?? '',
      numDiplome: map['num_diplome'] ?? '',
      nomPere: map['nom_pere'] ?? '',
      nomMere: map['nom_mere'] ?? '',
      sponsor: map['sponsor'] ?? '',
      groupeSanguin: map['groupe_sanguin'] ?? '',
      taille: map['taille'] ?? '',
      alergie: map['alergie'] ?? '',
      handicap: map['handicap'] ?? 'NON',
      password: map['password'] ?? '',
      historiqueInscriptions: (map['historique_inscriptions'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    final int? promoInt = int.tryParse(idPromo);
    return {
      'matricule_etu': matriculeEtu,
      'nom_etu': nomEtu,
      'postnom_etu': postnomEtu,
      'prenom_etu': prenomEtu,
      'email_personnel': emailPersonnel,
      'photo_profil': photoProfil,
      'id_promo': promoInt ?? idPromo, // Envoie un int si possible, sinon String
      'Sexe': sexe,
      'etat_civil': etatCivil,
      'telephone': telephone,
      'tel_tuteur': telTuteur,
      'lieu_naissance': lieuNaissance,
      'date_naissance': dateNaissance,
      'type_identite': typeIdentite,
      'num_identite': numIdentite,
      'ville': ville,
      'commune': commune,
      'quartier': quartier,
      'nationalite': nationalite,
      'province_origine': provinceOrigine,
      'territoire_origine': territoireOrigine,
      'secteur': secteur,
      'village': village,
      'ecole_secondaire': ecoleSecondaire,
      'adresse_ecole': adresseEcole,
      'orientation': orientation,
      'centre_examen_etat': centreExamenEtat,
      'pourcentage': pourcentage,
      'num_diplome': numDiplome,
      'nom_pere': nomPere,
      'nom_mere': nomMere,
      'sponsor': sponsor,
      'groupe_sanguin': groupeSanguin,
      'taille': taille,
      'alergie': alergie,
      'handicap': handicap,
      'password': password,
      'historique_inscriptions': historiqueInscriptions,
    };
  }
}
