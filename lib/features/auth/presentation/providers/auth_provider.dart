import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/utilisateur_entity.dart';
import '../../domain/entities/enseignant_entity.dart';
import '../../domain/entities/etudiant_entity.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

/// Stocke l'entité utilisateur connectée (AdminEntity, StaffEntity, etc.)
final authEntityProvider = StateProvider<dynamic>((ref) => null);

/// Gère la visibilité de l'overlay de login et le rôle sélectionné
final loginOverlayProvider = StateProvider<String?>((ref) => null);

/// Écoute en temps réel les changements sur le document de l'utilisateur connecté
final currentUserDataProvider = StreamProvider<dynamic>((ref) {
  final initialEntity = ref.watch(authEntityProvider);
  if (initialEntity == null) return Stream.value(null);

  String role = '';
  if (initialEntity is AdminEntity) role = 'administrateur';
  else if (initialEntity is StaffEntity) role = 'staff';
  else if (initialEntity is EnseignantEntity) role = 'enseignant';
  else if (initialEntity is EtudiantEntity) role = 'etudiant';
  else if (initialEntity is UtilisateurEntity) role = 'utilisateur';

  return ref.watch(authRepositoryProvider).getUserStream(initialEntity.id, role);
});
