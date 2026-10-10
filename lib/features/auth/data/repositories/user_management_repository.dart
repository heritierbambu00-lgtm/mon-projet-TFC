import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/enseignant_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/staff_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/utilisateur_entity.dart';

class UserManagementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ÉTUDIANTS ---
  Stream<List<EtudiantEntity>> getStudents() {
    return _firestore.collection('etudiants').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EtudiantEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addStudent(EtudiantEntity student) {
    return _firestore.collection('etudiants').doc(student.id.isEmpty ? null : student.id).set(student.toMap());
  }

  Future<void> deleteStudent(String id) {
    return _firestore.collection('etudiants').doc(id).delete();
  }

  // --- ENSEIGNANTS ---
  Stream<List<EnseignantEntity>> getTeachers() {
    return _firestore.collection('enseignants').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EnseignantEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTeacher(EnseignantEntity teacher) {
    return _firestore.collection('enseignants').doc(teacher.id.isEmpty ? null : teacher.id).set(teacher.toMap());
  }

  // --- AGENTS (Utilisateurs) ---
  Stream<List<UtilisateurEntity>> getAgents() {
    return _firestore.collection('utilisateurs').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UtilisateurEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> saveAgent(UtilisateurEntity agent) {
    if (agent.id.isEmpty) {
      return _firestore.collection('utilisateurs').add(agent.toMap());
    } else {
      return _firestore.collection('utilisateurs').doc(agent.id).set(agent.toMap());
    }
  }

  Future<void> deleteAgent(String id) {
    return _firestore.collection('utilisateurs').doc(id).delete();
  }

  // --- STAFF ---
  Stream<List<StaffEntity>> getStaff() {
    return _firestore.collection('staff').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => StaffEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addStaff(StaffEntity staff) {
    return _firestore.collection('staff').doc(staff.id.isEmpty ? null : staff.id).set(staff.toMap());
  }
}
