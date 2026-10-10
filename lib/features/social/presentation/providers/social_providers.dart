import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/social_repository.dart';
import '../../domain/entities/chat_faculte_entity.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) => SocialRepository());

final messagesStreamProvider = StreamProvider.family<List<ChatFaculteEntity>, String>((ref, faculte) {
  return ref.watch(socialRepositoryProvider).getMessages(faculte);
});
