import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/features/info/presentation/providers/info_providers.dart';
import 'package:istm_mahagi/features/info/domain/entities/calendar_event_entity.dart';

class CalendarManagementPage extends ConsumerStatefulWidget {
  const CalendarManagementPage({super.key});

  @override
  ConsumerState<CalendarManagementPage> createState() => _CalendarManagementPageState();
}

class _CalendarManagementPageState extends ConsumerState<CalendarManagementPage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;

  Future<void> _addEvent() async {
    if (_titreController.text.isEmpty || _dateDebut == null || _dateFin == null) return;
    
    final event = CalendarEventEntity(
      id: '',
      titreEvent: _titreController.text.trim(),
      descriptionEvent: _descController.text.trim(),
      dateDebut: _dateDebut!,
      dateFin: _dateFin!,
    );

    await ref.read(infoRepositoryProvider).addCalendarEvent(event);
    
    _titreController.clear();
    _descController.clear();
    setState(() { _dateDebut = null; _dateFin = null; });
    
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Événement ajouté au calendrier !")));
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);

    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CALENDRIER ACADÉMIQUE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
            Text('Planification des événements et jalons de la session', style: TextStyle(fontSize: 10, color: Colors.blue.shade200, fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Colors.white.withOpacity(0.05),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 45),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isMobile 
              ? Column(
                  children: [
                    _buildAddForm(),
                    const SizedBox(height: 50),
                    _buildEventsList(eventsAsync),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildAddForm()),
                    const SizedBox(width: 50),
                    Expanded(flex: 3, child: _buildEventsList(eventsAsync)),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('➕ Ajouter un événement', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          _buildInput(_titreController, 'Titre'),
          _buildInput(_descController, 'Description', maxLines: 3),
          Row(
            children: [
              Expanded(child: _buildDatePicker('Date début', _dateDebut, (d) => setState(() => _dateDebut = d))),
              const SizedBox(width: 20),
              Expanded(child: _buildDatePicker('Date fin', _dateFin, (d) => setState(() => _dateFin = d))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('AJOUTER L\'ÉVÉNEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2026), lastDate: DateTime(2027));
            if (d != null) onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                const SizedBox(width: 10),
                Text(value == null ? 'Choisir...' : DateFormat('dd/MM/yyyy').format(value), style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildEventsList(AsyncValue<List<CalendarEventEntity>> eventsAsync) {
    return eventsAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('Calendrier vide.', style: TextStyle(color: Colors.white38)));
        
        // Sort events by date
        list.sort((a, b) => a.dateDebut.compareTo(b.dateDebut));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final event = list[index];
            final String startStr = DateFormat('dd MMM', 'fr_FR').format(event.dateDebut);
            final String endStr = DateFormat('dd MMM yyyy', 'fr_FR').format(event.dateFin);
            
            return IntrinsicHeight(
              child: Row(
                children: [
                  // Timeline line & dot
                  Column(
                    children: [
                      Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.accentYellow.withOpacity(0.4), blurRadius: 10)],
                        ),
                      ),
                      if (index != list.length - 1)
                        Expanded(child: Container(width: 2, color: Colors.white.withOpacity(0.1))),
                    ],
                  ),
                  const SizedBox(width: 25),
                  // Event Card
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text("📌 Du $startStr au $endStr", style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () => ref.read(infoRepositoryProvider).deleteCalendarEvent(event.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(event.titreEvent, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Playfair Display')),
                          const SizedBox(height: 10),
                          Text(event.descriptionEvent, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Erreur: ${e.toString()}', style: const TextStyle(color: Colors.red)),
    );
  }
}
