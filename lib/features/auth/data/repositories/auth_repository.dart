import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/utilisateur_entity.dart';
import '../../domain/entities/enseignant_entity.dart';
import '../../domain/entities/etudiant_entity.dart';

class AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<dynamic> login(String loginInput, String password) async {
    try {
      final String input = loginInput.trim();
      final String pass = password.trim();
      
      // On prépare les variantes pour la recherche (insensible à la casse)
      final List<String> variants = [input, input.toUpperCase(), input.toLowerCase()];

      // --- RECHERCHE DANS LES COLLECTIONS FIRESTORE ---
      
      // a. ADMINISTRATEURS
      for (var v in variants) {
        var aQuery = await _firestore.collection('administrateurs').where('matricule', isEqualTo: v).limit(1).get();
        if (aQuery.docs.isEmpty) aQuery = await _firestore.collection('administrateurs').where('email', isEqualTo: v).limit(1).get();
        
        if (aQuery.docs.isNotEmpty) {
          final data = aQuery.docs.first.data();
          if (data['password'] == pass) {
            return AdminEntity.fromMap(data, aQuery.docs.first.id);
          }
        }
      }

      // b. STAFF
      for (var v in variants) {
        var sQuery = await _firestore.collection('staff').where('matricule_staff', isEqualTo: v).limit(1).get();
        if (sQuery.docs.isEmpty) sQuery = await _firestore.collection('staff').where('email_pro', isEqualTo: v).limit(1).get();
        
        if (sQuery.docs.isNotEmpty) {
          final data = sQuery.docs.first.data();
          if (data['password'] == pass) {
            return StaffEntity.fromMap(data, sQuery.docs.first.id);
          }
        }
      }

      // c. UTILISATEURS (AGENT, SEC, DEC, COMPTABLE)
      for (var v in variants) {
        var uQuery = await _firestore.collection('utilisateurs').where('matricule', isEqualTo: v).limit(1).get();
        if (uQuery.docs.isNotEmpty) {
          final data = uQuery.docs.first.data();
          if (data['statut'] != 1 && data['statut'] != true) continue;
          if (data['password'] == pass) {
            return UtilisateurEntity.fromMap(data, uQuery.docs.first.id);
          }
        }
      }

      // d. ENSEIGNANTS
      for (var v in variants) {
        var eQuery = await _firestore.collection('enseignants').where('matricule_ens', isEqualTo: v).limit(1).get();
        if (eQuery.docs.isEmpty) eQuery = await _firestore.collection('enseignants').where('email_pro', isEqualTo: v).limit(1).get();
        
        if (eQuery.docs.isNotEmpty) {
          final data = eQuery.docs.first.data();
          if (data['password'] == pass) {
            return EnseignantEntity.fromMap(data, eQuery.docs.first.id);
          }
        }
      }

      // e. ETUDIANTS
      for (var v in variants) {
        var etuQuery = await _firestore.collection('etudiants').where('matricule_etu', isEqualTo: v).limit(1).get();
        if (etuQuery.docs.isEmpty) etuQuery = await _firestore.collection('etudiants').where('email_personnel', isEqualTo: v).limit(1).get();
        
        if (etuQuery.docs.isNotEmpty) {
          final data = etuQuery.docs.first.data();
          if (data['password'] == pass) {
            return EtudiantEntity.fromMap(data, etuQuery.docs.first.id);
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint("Login logic error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    // Rien à faire ici pour le moment car on utilise un état Riverpod purement mémoire
  }

  Stream<dynamic> getUserStream(String id, String role) {
    String collection = '';
    switch (role.toLowerCase()) {
      case 'administrateur': collection = 'administrateurs'; break;
      case 'staff': collection = 'staff'; break;
      case 'enseignant': collection = 'enseignants'; break;
      case 'etudiant': collection = 'etudiants'; break;
      default: collection = 'utilisateurs';
    }

    return _firestore.collection(collection).doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      switch (role.toLowerCase()) {
        case 'administrateur': return AdminEntity.fromMap(data, snap.id);
        case 'staff': return StaffEntity.fromMap(data, snap.id);
        case 'enseignant': return EnseignantEntity.fromMap(data, snap.id);
        case 'etudiant': return EtudiantEntity.fromMap(data, snap.id);
        default: return UtilisateurEntity.fromMap(data, snap.id);
      }
    });
  }
}
