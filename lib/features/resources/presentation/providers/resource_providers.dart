import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/resource_repository.dart';
import '../../domain/entities/elearning_entity.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) => ResourceRepository());

final elearningProvider = StreamProvider<List<ElearningEntity>>((ref) {
  return ref.watch(resourceRepositoryProvider).getELearningResources();
});
