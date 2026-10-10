import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/dashboard/presentation/pages/student_dashboard.dart';
import '../../features/auth/domain/entities/admin_entity.dart';
import '../../features/auth/domain/entities/staff_entity.dart';
import '../../features/auth/domain/entities/utilisateur_entity.dart';
import '../../features/auth/domain/entities/enseignant_entity.dart';
import '../../features/auth/domain/entities/etudiant_entity.dart';

import '../../features/dashboard/presentation/pages/admin_dashboard.dart';
import '../../features/dashboard/presentation/pages/staff_dashboard.dart';
import '../../features/dashboard/presentation/pages/teacher_dashboard.dart';
import '../../features/dashboard/presentation/pages/accountant_dashboard.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(authEntityProvider);

    if (entity == null) {
      return const HomePage();
    }

    return _mapEntityToDashboard(entity);
  }

  Widget _mapEntityToDashboard(dynamic data) {
    if (data is AdminEntity) return const AdminDashboard();
    if (data is StaffEntity) return const StaffDashboard();
    if (data is EnseignantEntity) return const TeacherDashboard();
    if (data is EtudiantEntity) return const StudentDashboard();
    if (data is UtilisateurEntity) {
      if (data.role == 'comptable') return const AccountantDashboard();
      return const AdminDashboard(); // Par défaut pour les autres agents/staff
    }
    return const HomePage();
  }
}
