import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';
import 'package:istm_mahagi/features/academic/domain/entities/promotion_entity.dart';
import 'package:istm_mahagi/features/academic/domain/entities/horaire_entity.dart';
import 'package:istm_mahagi/features/academic/domain/entities/cours_entity.dart';

class CourseSchedulePage extends ConsumerStatefulWidget {
  const CourseSchedulePage({super.key});

  @override
  ConsumerState<CourseSchedulePage> createState() => _CourseSchedulePageState();
}

class _CourseSchedulePageState extends ConsumerState<CourseSchedulePage> {
  String? _selectedPromoId;
  String? _selectedPromoName;
  bool _hasSearched = false;

  final Color _headerBlue = const Color(0xFF3C5A78);
  final Color _searchBlue = const Color(0xFF3498DB);

  void _handleSearch(List<PromotionEntity> promotions) {
    if (_selectedPromoId == null || _selectedPromoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une promotion avant de lancer la recherche.")),
      );
      return;
    }
    setState(() {
      _hasSearched = true;
      _selectedPromoName = promotions.firstWhere((p) => p.id == _selectedPromoId).nomPromo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(promotionsProvider);
    final schedulesAsync = _selectedPromoId != null ? ref.watch(schedulesProvider(_selectedPromoId)) : null;
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Header (Bandeau bleu foncé)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            color: _headerBlue,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                      label: const Text("« Retour", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Text(
                    "HORAIRE DES COURS",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Search Box (Bandeau bleu clair)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            color: _searchBlue,
            child: promosAsync.when(
              data: (promos) => Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 15,
                runSpacing: 15,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPromoId,
                        hint: const Text("Choisissez une promotion"),
                        items: promos.map((p) {
                          return DropdownMenuItem(value: p.id, child: Text(p.nomPromo));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPromoId = val),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleSearch(promos),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _headerBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text("RECHERCHER", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (e, _) => Text("Erreur: $e", style: const TextStyle(color: Colors.white)),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Responsive(
                    mobile: Column(
                      children: [
                        _buildMainContent(schedulesAsync, coursesAsync),
                        const SizedBox(height: 30),
                        _buildRectorCard(),
                      ],
                    ),
                    desktop: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildMainContent(schedulesAsync, coursesAsync)),
                        const SizedBox(width: 30),
                        Expanded(flex: 1, child: _buildRectorCard()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(AsyncValue<List<HoraireEntity>>? schedulesAsync, AsyncValue<List<CoursEntity>> coursesAsync) {
    if (!_hasSearched || schedulesAsync == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: _searchBlue,
          child: Text(
            "Horaire : $_selectedPromoName",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        schedulesAsync.when(
          data: (schedules) {
            if (schedules.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  border: Border.all(color: const Color(0xFFFFEEBA)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "Aucun cours n'est programmé pour cette promotion actuellement.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF856404)),
                ),
              );
            }

            return coursesAsync.when(
              data: (courses) {
                return Column(
                  children: schedules.map((s) {
                    final course = courses.firstWhere(
                      (c) => c.id == s.idCours,
                      orElse: () => CoursEntity(id: '', idCours: 0, codeCours: '', intituleCours: 'Non défini', credits: 0, idEns: '', idPromo: ''),
                    );
                    
                    final dateStr = DateFormat("EEEE 'Le' dd MMMM yyyy", "fr_FR").format(s.dateCours);
                    final capitalizedDate = dateStr[0].toUpperCase() + dateStr.substring(1);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(capitalizedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text("Cours : ${course.intituleCours}"),
                          Text("Auditoire : ${s.salle}"),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text("Erreur: $e"),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Erreur: $e"),
        ),
      ],
    );
  }

  Widget _buildRectorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: _searchBlue,
            child: const Text(
              "Recteur",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF4F4F4), width: 3),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'), // Logo as placeholder for photo
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Dr. HERITIER BAMBU",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  "WAMARA, PhD",
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "Professeur Associé",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
