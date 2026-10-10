import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/features/auth/data/repositories/user_management_repository.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/enseignant_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/staff_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/utilisateur_entity.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) => UserManagementRepository());

final studentsStreamProvider = StreamProvider<List<EtudiantEntity>>((ref) {
  return ref.watch(userManagementRepositoryProvider).getStudents();
});

final teachersStreamProvider = StreamProvider<List<EnseignantEntity>>((ref) {
  return ref.watch(userManagementRepositoryProvider).getTeachers();
});

final agentsStreamProvider = StreamProvider<List<UtilisateurEntity>>((ref) {
  return ref.watch(userManagementRepositoryProvider).getAgents();
});

final staffStreamProvider = StreamProvider<List<StaffEntity>>((ref) {
  return ref.watch(userManagementRepositoryProvider).getStaff();
});
