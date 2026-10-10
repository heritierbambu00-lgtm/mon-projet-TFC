import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/academic_repository.dart';
import '../../domain/entities/horaire_entity.dart';
import '../../domain/entities/cours_entity.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/faculte_entity.dart';
import '../../domain/entities/departement_entity.dart';
import '../../../auth/domain/entities/enseignant_entity.dart';
import '../../../auth/domain/entities/etudiant_entity.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) => AcademicRepository());

final teachersProvider = StreamProvider<List<EnseignantEntity>>((ref) {
  return ref.watch(academicRepositoryProvider).getTeachers();
});

final currentAcademicYearProvider = StreamProvider<String>((ref) {
  return ref.watch(academicRepositoryProvider).getCurrentAcademicYear();
});

final facultiesProvider = StreamProvider<List<FaculteEntity>>((ref) {
  return ref.watch(academicRepositoryProvider).getFaculties();
});

final departmentsProvider = StreamProvider<List<DepartementEntity>>((ref) {
  return ref.watch(academicRepositoryProvider).getDepartments();
});

final schedulesProvider = StreamProvider.family<List<HoraireEntity>, String?>((ref, idPromo) {
  return ref.watch(academicRepositoryProvider).getSchedules(idPromo);
});

final coursesProvider = StreamProvider<List<CoursEntity>>((ref) {
  return ref.watch(academicRepositoryProvider).getCourses();
});

final promotionsProvider = StreamProvider<List<PromotionEntity>>((ref) {
  return ref.watch(academicRepositoryProvider).getPromotions();
});

final studentsByPromoProvider = StreamProvider.family<List<EtudiantEntity>, String?>((ref, idPromo) {
  return ref.watch(academicRepositoryProvider).getStudentsByPromo(idPromo);
});

final getStudentCoursesProvider = StreamProvider.family<List<CoursEntity>, ({String promoId, String? anneeAcad})>((ref, arg) {
  return ref.watch(academicRepositoryProvider).getStudentCourses(arg.promoId, anneeAcad: arg.anneeAcad);
});

final getStudentResultsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, etuId) {
  return ref.watch(academicRepositoryProvider).getStudentResults(etuId);
});

final notesByPromoProvider = StreamProvider.family<List<Map<String, dynamic>>, ({String idPromo, String anneeAcad})>((ref, arg) {
  return ref.watch(academicRepositoryProvider).getNotesByPromo(arg.idPromo, arg.anneeAcad);
});

final getStudentFraisConfigProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, idPromo) {
  return ref.watch(academicRepositoryProvider).getStudentFraisConfig(idPromo);
});

final getStudentPaymentsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, etuId) {
  return ref.watch(academicRepositoryProvider).getStudentPayments(etuId);
});

final allPaymentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(academicRepositoryProvider).getAllPayments();
});

final fraisGrilleProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(academicRepositoryProvider).getFraisGrille();
});

/// Fournit les promotions avec les noms de leurs facultés et départements parents
final promotionsWithDetailsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final faculties = ref.watch(facultiesProvider).value ?? [];
  final departments = ref.watch(departmentsProvider).value ?? [];
  final promotions = ref.watch(promotionsProvider).value ?? [];

  return Stream.value(promotions.map((p) {
    final dept = departments.firstWhere((d) => d.id == p.idDept, orElse: () => DepartementEntity(id: '', nomDept: '?', idFaculte: ''));
    final fac = faculties.firstWhere((f) => f.id == dept.idFaculte, orElse: () => FaculteEntity(id: '', nomFaculte: '?'));
    final yearSuffix = (p.anneeAcad != null && p.anneeAcad!.isNotEmpty) ? " (${p.anneeAcad})" : "";

    return <String, dynamic>{
      'id': p.id,
      'stableId': p.stableId,
      'nom': p.nomPromo,
      'dept': dept.nomDept,
      'fac': fac.nomFaculte,
      'anneeAcad': p.anneeAcad,
      'label': "[${fac.nomFaculte}] ${dept.nomDept} - ${p.nomPromo}$yearSuffix"
    };
  }).toList());
});

// --- DICTATOR PROVIDERS ---

final courseDocumentsProvider = StreamProvider.family<List<Map<String, dynamic>>, ({String idCours, String type})>((ref, arg) {
  return ref.watch(academicRepositoryProvider).getCourseDocuments(arg.idCours, arg.type);
});

final evaluationCriteriaProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(academicRepositoryProvider).getEvaluationCriteria();
});

final libraryDocumentsProvider = StreamProvider.family<List<Map<String, dynamic>>, String?>((ref, idPromo) {
  return ref.watch(academicRepositoryProvider).getLibraryDocuments(idPromo);
});

final studentEvaluationsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, etuId) {
  return ref.watch(academicRepositoryProvider).getStudentEvaluations(etuId);
});
