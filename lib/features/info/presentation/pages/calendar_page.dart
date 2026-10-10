import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/info/presentation/providers/info_providers.dart';
import 'package:istm_mahagi/features/info/domain/entities/calendar_event_entity.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildHeroHeader(context),
          calendarAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Aucun événement au calendrier.')),
                );
              }

              // Group events by month
              final groupedEvents = <String, List<CalendarEventEntity>>{};
              for (final event in events) {
                final monthYear = DateFormat('MMMM yyyy', 'fr_FR').format(event.dateDebut).toUpperCase();
                if (!groupedEvents.containsKey(monthYear)) {
                  groupedEvents[monthYear] = [];
                }
                groupedEvents[monthYear]!.add(event);
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final month = groupedEvents.keys.elementAt(index);
                      final monthEvents = groupedEvents[month]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthSeparator(month),
                          const SizedBox(height: 25),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final bool isSmall = constraints.maxWidth < 650;
                              
                              if (isSmall) {
                                return Column(
                                  children: monthEvents.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: _buildEventCard(e, isSmall: true),
                                  )).toList(),
                                );
                              }
                              
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 600,
                                  crossAxisSpacing: 25,
                                  mainAxisSpacing: 25,
                                  mainAxisExtent: 260,
                                ),
                                itemCount: monthEvents.length,
                                itemBuilder: (context, i) => _buildEventCard(monthEvents[i], isSmall: false),
                              );
                            },
                          ),
                          const SizedBox(height: 60),
                        ],
                      );
                    },
                    childCount: groupedEvents.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverFillRemaining(child: Center(child: Text('Erreur: $err'))),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CALENDRIER ACADÉMIQUE',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white, fontSize: 18),
            ),
            Text(
              "Agenda officiel de l'ISTM Mahagi",
              style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500, letterSpacing: 1),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: const BoxDecoration(gradient: AppColors.premiumGradient)),
            Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/slider2.jpg', fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSeparator(String month) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Text(
        month,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
      ),
    );
  }

  Widget _buildEventCard(CalendarEventEntity event, {required bool isSmall}) {
    final isExamen = event.titreEvent.toUpperCase().contains('EXAMEN');
    final isExcursion = event.titreEvent.toUpperCase().contains('EXCURSION');
    
    Color typeColor = AppColors.primaryBlue;
    String typeLabel = "ÉVÉNEMENT";
    
    if (isExamen) {
      typeColor = const Color(0xFFDC2626);
      typeLabel = "SESSION D'EXAMENS";
    } else if (isExcursion) {
      typeColor = const Color(0xFFF59E0B);
      typeLabel = "EXCURSION";
    }

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(typeLabel, style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 15),
          Text(
            event.titreEvent.toUpperCase(), 
            maxLines: 2, 
            textAlign: isSmall ? TextAlign.center : TextAlign.start,
            overflow: TextOverflow.ellipsis, 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: isSmall ? 15 : 17, color: const Color(0xFF1E293B))
          ),
          const SizedBox(height: 10),
          if (isSmall)
            Text(
              event.descriptionEvent, 
              maxLines: 3, 
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.5)
            )
          else
            Expanded(
              child: Text(
                event.descriptionEvent, 
                maxLines: 4, 
                overflow: TextOverflow.ellipsis, 
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.5)
              ),
            ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dateBox(DateFormat('MMM', 'fr_FR').format(event.dateDebut).toUpperCase(), event.dateDebut.day.toString()),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text('au', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                _dateBox(DateFormat('MMM', 'fr_FR').format(event.dateFin).toUpperCase(), event.dateFin.day.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String month, String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.03))),
      child: Column(
        children: [
          Text(month, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 8)),
          Text(day, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }
}
