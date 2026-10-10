import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/info_repository.dart';
import '../../domain/entities/anthem_entity.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/entities/mission_vision_entity.dart';
import '../../domain/entities/statute_entity.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/entities/comite_entity.dart';

final infoRepositoryProvider = Provider<InfoRepository>((ref) => InfoRepository());

final anthemProvider = StreamProvider<AnthemEntity?>((ref) {
  return ref.watch(infoRepositoryProvider).getAnthem();
});

final historyProvider = StreamProvider<HistoryEntity?>((ref) {
  return ref.watch(infoRepositoryProvider).getHistory();
});

final missionVisionProvider = StreamProvider<MissionVisionEntity?>((ref) {
  return ref.watch(infoRepositoryProvider).getMissionVision();
});

final statutesProvider = StreamProvider<List<StatuteEntity>>((ref) {
  return ref.watch(infoRepositoryProvider).getStatutes();
});

final calendarEventsProvider = StreamProvider<List<CalendarEventEntity>>((ref) {
  return ref.watch(infoRepositoryProvider).getCalendarEvents();
});

final committeeProvider = StreamProvider<List<ComiteEntity>>((ref) {
  return ref.watch(infoRepositoryProvider).getCommittee();
});
