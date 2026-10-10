import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/horaire_entity.dart';
import '../../domain/entities/cours_entity.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/admission_entity.dart';
import '../../domain/entities/faculte_entity.dart';
import '../../domain/entities/departement_entity.dart';
import '../../../auth/domain/entities/enseignant_entity.dart';
import '../../../auth/domain/entities/etudiant_entity.dart';

class AcademicRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ENSEIGNANTS ---
  Stream<List<EnseignantEntity>> getTeachers() {
    return _firestore.collection('enseignants').orderBy('nom_ens').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EnseignantEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTeacher(EnseignantEntity teacher) {
    return _firestore.collection('enseignants').doc(teacher.id.isEmpty ? null : teacher.id).set(teacher.toMap());
  }

  Future<void> deleteTeacher(String id) {
    return _firestore.collection('enseignants').doc(id).delete();
  }

  // --- FACULTÉS ---
  Stream<List<FaculteEntity>> getFaculties() {
    return _firestore.collection('facultes').orderBy('nom_faculte').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => FaculteEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addFaculty(String name) async {
    // Auto-increment logic
    int nextId = 1;
    final query = await _firestore.collection('facultes').orderBy('id_faculte', descending: true).limit(1).get();
    if (query.docs.isNotEmpty) {
      final lastId = query.docs.first.data()['id_faculte'];
      if (lastId is int) nextId = lastId + 1;
    }

    await _firestore.collection('facultes').add({
      'nom_faculte': name,
      'id_faculte': nextId,
    });
  }

  Future<void> deleteFaculty(String id) {
    return _firestore.collection('facultes').doc(id).delete();
  }

  Future<void> updateFaculty(String id, String name) {
    return _firestore.collection('facultes').doc(id).update({'nom_faculte': name});
  }

  // --- DÉPARTEMENTS ---
  Stream<List<DepartementEntity>> getDepartments() {
    return _firestore.collection('departements').orderBy('nom_dept').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => DepartementEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addDepartment(String name, String idFaculte) async {
    // Auto-increment logic
    int nextId = 1;
    final query = await _firestore.collection('departements').orderBy('id_dept', descending: true).limit(1).get();
    if (query.docs.isNotEmpty) {
      final lastId = query.docs.first.data()['id_dept'];
      if (lastId is int) nextId = lastId + 1;
    }

    await _firestore.collection('departements').add({
      'nom_dept': name,
      'id_faculte': idFaculte,
      'id_dept': nextId,
      'resultats_ouverts': false,
      'eval_profs_ouverte': false,
    });
  }

  Future<void> deleteDepartment(String id) {
    return _firestore.collection('departements').doc(id).delete();
  }

  Future<void> updateDepartment(String id, String name, String idFaculte) {
    return _firestore.collection('departements').doc(id).update({
      'nom_dept': name,
      'id_faculte': idFaculte,
    });
  }

  // --- PROMOTIONS ---
  Stream<List<PromotionEntity>> getPromotions() {
    return _firestore.collection('promotions').orderBy('nom_promo').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => PromotionEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addPromotion(String name, String idDept, {String? anneeAcad}) async {
    // Auto-increment logic robuste
    int nextId = 1;
    final query = await _firestore.collection('promotions').orderBy('id_promo', descending: true).get();
    if (query.docs.isNotEmpty) {
      for (var doc in query.docs) {
        final val = doc.data()['id_promo'];
        if (val is int) {
          nextId = val + 1;
          break;
        } else if (val is String) {
          final p = int.tryParse(val);
          if (p != null) {
            nextId = p + 1;
            break;
          }
        }
      }
    }

    final Map<String, dynamic> promoData = {
      'nom_promo': name,
      'id_dept': idDept,
      'id_promo': nextId,
    };
    if (anneeAcad != null && anneeAcad.trim().isNotEmpty) {
      promoData['annee_academique'] = anneeAcad.trim();
    }

    await _firestore.collection('promotions').add(promoData);
  }

  Future<void> deletePromotion(String id) {
    return _firestore.collection('promotions').doc(id).delete();
  }

  Future<void> updatePromotion(String id, String name, String idDept, {String? anneeAcad}) {
    final Map<String, dynamic> data = {
      'nom_promo': name,
      'id_dept': idDept,
    };
    if (anneeAcad != null) {
      data['annee_academique'] = anneeAcad.trim();
    }
    return _firestore.collection('promotions').doc(id).update(data);
  }

  Future<void> updatePromotionThreshold(String id, double threshold) {
    return _firestore.collection('promotions').doc(id).update({'seuil_finance': threshold});
  }

  // --- HORAIRES ---
  Stream<List<HoraireEntity>> getSchedules(String? idPromo) {
    Query query = _firestore.collection('horaires');
    if (idPromo != null && idPromo.isNotEmpty) {
      query = query.where('id_promo', isEqualTo: idPromo);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => HoraireEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addSchedule(HoraireEntity schedule) async {
    await _firestore.collection('horaires').add(schedule.toMap());
  }

  Future<void> deleteSchedule(String id) {
    return _firestore.collection('horaires').doc(id).delete();
  }

  // --- COURS ---
  Stream<List<CoursEntity>> getCourses() {
    return _firestore.collection('cours').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CoursEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addCourse(Map<String, dynamic> data) async {
    // Auto-increment course ID
    int nextId = 1;
    final query = await _firestore.collection('cours').orderBy('id_cours', descending: true).limit(1).get();
    if (query.docs.isNotEmpty) {
      final lastId = query.docs.first.data()['id_cours'];
      if (lastId is int) nextId = lastId + 1;
    }

    final finalData = Map<String, dynamic>.from(data);
    finalData['id_cours'] = nextId;

    await _firestore.collection('cours').add(finalData);
  }

  Future<void> deleteCourse(String id) {
    return _firestore.collection('cours').doc(id).delete();
  }

  Future<void> updateCourse(String id, Map<String, dynamic> data) {
    return _firestore.collection('cours').doc(id).update(data);
  }

  // --- ADMISSIONS ---
  Future<void> submitAdmission(AdmissionEntity admission) async {
    await _firestore.collection('admissions').add({
      'nom': admission.nom,
      'postnom': admission.postnom,
      'prenom': admission.prenom,
      'genre': admission.genre,
      'telephone': admission.telephone,
      'date_soumission': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDepartmentConfig(String idDept, Map<String, dynamic> config) {
    return _firestore.collection('departements').doc(idDept).update(config);
  }

  // --- CONFIGURATION GLOBALE ---
  Stream<String> getCurrentAcademicYear() {
    return _firestore.collection('settings').doc('global').snapshots().map((snap) {
      return snap.data()?['current_annee_acad'] ?? '2025-2026';
    });
  }

  Future<void> setCurrentAcademicYear(String year) {
    return _firestore.collection('settings').doc('global').set({
      'current_annee_acad': year,
    }, SetOptions(merge: true));
  }

  // --- ÉTUDIANTS ---
  Future<void> addStudent(EtudiantEntity student) async {
    await _firestore.collection('etudiants').add(student.toMap());
  }

  Future<void> updateStudent(String studentId, Map<String, dynamic> data) {
    return _firestore.collection('etudiants').doc(studentId).update(data);
  }

  Future<void> reEnrollStudent(String studentId, String newPromoId, {String? anneeAcad}) async {
    final Map<String, dynamic> updateData = {
      'id_promo': int.tryParse(newPromoId) ?? newPromoId,
    };
    if (anneeAcad != null && anneeAcad.trim().isNotEmpty) {
      updateData['annee_academique'] = anneeAcad.trim();
      updateData['historique_inscriptions'] = FieldValue.arrayUnion([
        {
          'id_promo': newPromoId,
          'annee_academique': anneeAcad.trim(),
          'date_inscription': DateTime.now().toIso8601String(),
        }
      ]);
    }

    await _firestore.collection('etudiants').doc(studentId).update(updateData);
  }

  Stream<List<CoursEntity>> getStudentCourses(String promoId, {String? anneeAcad}) {
    return _firestore.collection('cours').snapshots().map((snapshot) {
      final intPromo = int.tryParse(promoId);
      return snapshot.docs
          .map((doc) => CoursEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((c) {
            final matchesPromo = c.idPromo == promoId || (intPromo != null && c.idPromo == intPromo.toString());
            if (!matchesPromo) return false;
            if (anneeAcad != null && anneeAcad.isNotEmpty && c.anneeAcad != null && c.anneeAcad!.isNotEmpty) {
              return c.anneeAcad == anneeAcad;
            }
            return true;
          })
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getStudentResults(String etuId) {
    return _firestore.collection('notes')
        .where('id_etu', isEqualTo: etuId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  // --- FINANCES ---
  Stream<Map<String, dynamic>?> getStudentFraisConfig(String idPromo) {
    // On convertit l'ID en entier si possible
    final int? promoInt = int.tryParse(idPromo);
    return _firestore.collection('frais_config')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final docPromo = data['id_promo']?.toString();
            return docPromo == idPromo || (promoInt != null && docPromo == promoInt.toString());
          }).toList();
          return docs.isNotEmpty ? docs.first.data() as Map<String, dynamic> : null;
        });
  }

  Stream<List<Map<String, dynamic>>> getStudentPayments(String etuId) {
    return _firestore.collection('finances')
        .where('id_etu', isEqualTo: etuId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          // TRI EN MÉMOIRE : Évite l'erreur "The query requires an index"
          docs.sort((a, b) {
            final DateTime dateA = (a['date_paiement'] as dynamic)?.toDate() ?? DateTime(0);
            final DateTime dateB = (b['date_paiement'] as dynamic)?.toDate() ?? DateTime(0);
            return dateB.compareTo(dateA); // Plus récent en premier
          });
          return docs;
        });
  }

  // --- COMPTABILITÉ GLOBALE ---

  Stream<List<Map<String, dynamic>>> getAllPayments() {
    return _firestore.collection('finances')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Stream<List<Map<String, dynamic>>> getFraisGrille() {
    return _firestore.collection('frais_config')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Future<void> saveFraisConfig(Map<String, dynamic> config) async {
    final idPromo = config['id_promo'].toString();
    final anneeAcad = config['annee_acad'];
    final docId = "${idPromo}_$anneeAcad";
    
    await _firestore.collection('frais_config').doc(docId).set(config, SetOptions(merge: true));
  }

  Future<void> recordPayment(Map<String, dynamic> payment) async {
    // Auto-increment payment ID
    int nextId = 1;
    final query = await _firestore.collection('finances').orderBy('id_paiement', descending: true).limit(1).get();
    if (query.docs.isNotEmpty) {
      final lastId = query.docs.first.data()['id_paiement'];
      if (lastId is int) nextId = lastId + 1;
    }
    
    final finalPayment = Map<String, dynamic>.from(payment);
    finalPayment['id_paiement'] = nextId;
    finalPayment['date_paiement'] = FieldValue.serverTimestamp();

    await _firestore.collection('finances').add(finalPayment);
  }

  Future<EtudiantEntity?> findStudentByMatricule(String search) async {
    // Recherche par matricule exact ou nom (case insensitive simulation)
    final variants = [search, search.toUpperCase(), search.toLowerCase()];
    for (var v in variants) {
      final q = await _firestore.collection('etudiants').where('matricule_etu', isEqualTo: v).limit(1).get();
      if (q.docs.isNotEmpty) return EtudiantEntity.fromMap(q.docs.first.data(), q.docs.first.id);
      
      final q2 = await _firestore.collection('etudiants').where('nom_etu', isEqualTo: v).limit(1).get();
      if (q2.docs.isNotEmpty) return EtudiantEntity.fromMap(q2.docs.first.data(), q2.docs.first.id);
    }
    return null;
  }

  // --- ÉTUDIANTS PAR PROMO ---
  Stream<List<EtudiantEntity>> getStudentsByPromo(String? idPromo) {
    if (idPromo == null || idPromo.isEmpty) {
      return Stream.value([]);
    }

    return _firestore.collection('etudiants').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EtudiantEntity.fromMap(doc.data(), doc.id);
      }).where((etu) {
        // On compare avec l'ID du document OU l'ID numérique PHP
        return etu.idPromo == idPromo;
      }).toList();
    });
  }

  // --- NOTES ---
  Future<void> saveGrades(String idCours, String idPromo, String anneeAcad, Map<String, double> grades) async {
    final batch = _firestore.batch();
    for (var entry in grades.entries) {
      final studentId = entry.key;
      final cote = entry.value;
      // Document ID: idEtu_idCours_anneeAcad (unique per year)
      final docId = "${studentId}_${idCours}_${anneeAcad.replaceAll('/', '-')}";
      final docRef = _firestore.collection('notes').doc(docId);
      
      batch.set(docRef, {
        'id_etu': studentId,
        'id_cours': idCours,
        'id_promo': idPromo,
        'annee_academique': anneeAcad,
        'cote': cote,
        'date_saisie': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getNotesByPromo(String idPromo, String anneeAcad) {
    return _firestore.collection('notes')
        .where('id_promo', isEqualTo: idPromo)
        .where('annee_academique', isEqualTo: anneeAcad)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // --- LOGIQUE DICTATOR (DOCUMENTS & EVALUATIONS) ---

  Stream<List<Map<String, dynamic>>> getCourseDocuments(String idCours, String type) {
    return _firestore.collection('documents_cours')
        .where('id_cours', isEqualTo: idCours)
        .where('type_doc', isEqualTo: type)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Future<void> submitTP(String idCours, String idEtu, String fileName) async {
    // Vérifier si déjà soumis
    final check = await _firestore.collection('depots_tp')
        .where('id_etu', isEqualTo: idEtu)
        .where('id_cours', isEqualTo: idCours)
        .get();
    
    if (check.docs.isNotEmpty) {
        throw Exception("Vous avez déjà soumis un travail pour ce cours.");
    }

    await _firestore.collection('depots_tp').add({
      'id_etu': idEtu,
      'id_cours': idCours,
      'nom_fichier': fileName,
      'date_depot': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getEvaluationCriteria() {
    return _firestore.collection('evaluation_criteres')
        .orderBy('id_critere')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Stream<List<Map<String, dynamic>>> getStudentEvaluations(String etuId) {
    return _firestore.collection('evaluations')
        .where('id_etu', isEqualTo: etuId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Future<void> submitEvaluation(Map<String, dynamic> data) async {
    // Exact mapping to PHP/MySQL structure logic
    await _firestore.collection('evaluations').add({
      'id_etu': data['id_etu'],
      'id_cours': data['id_cours'],
      'id_ens': data['id_ens'],
      'commentaire_general': data['commentaire_general'],
      'details': data['details'], // Map of critere_id -> response_value
      'date_evaluation': FieldValue.serverTimestamp(),
    });
  }

  // --- LIBRARY (Real files) ---
  Stream<List<Map<String, dynamic>>> getLibraryDocuments(String? idPromo) {
    Query query = _firestore.collection('documents_cours')
        .where('type_doc', isEqualTo: 'Livre');
    
    // We can also show global books if promo is null or specifically filter
    return query.snapshots().map((snap) => snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}
