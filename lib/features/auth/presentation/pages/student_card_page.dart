import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';

class StudentCardPage extends ConsumerWidget {
  const StudentCardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final promosAsync = ref.watch(promotionsProvider);
    final deptsAsync = ref.watch(departmentsProvider);
    final facultiesAsync = ref.watch(facultiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('CARTE D\'ÉTUDIANT OFFICIELLE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: userDataAsync.when(
        data: (user) {
          if (user == null || user is! EtudiantEntity) return const Center(child: Text("Étudiant non trouvé."));

          return promosAsync.when(
            data: (promos) => deptsAsync.when(
              data: (depts) => facultiesAsync.when(
                data: (faculties) {
                  // Recherche robuste de la promotion par stableId
                  final promo = promos.where((p) => p.stableId == user.idPromo).firstOrNull;
                  final dept = depts.where((d) => d.id == promo?.idDept).firstOrNull;
                  final faculty = faculties.where((f) => f.id == dept?.idFaculte).firstOrNull;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActions(),
                          const SizedBox(height: 30),
                          // Utilisation de FittedBox pour garantir la responsivité sans overflow
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: _buildIdCard(
                                user, 
                                promo?.nomPromo ?? 'Promotion Inconnue', 
                                dept?.nomDept ?? 'Département Inconnu', 
                                faculty?.nomFaculte ?? 'Faculté Inconnue'
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Cette carte est strictement personnelle.",
                            style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur facultés: $e'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur départements: $e'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur promotions: $e'),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur profil: $e')),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.print_rounded, size: 20),
        label: const Text('IMPRIMER MA CARTE DIGITALE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          foregroundColor: Colors.white, 
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
    );
  }

  Widget _buildIdCard(EtudiantEntity user, String promo, String dept, String faculty) {
    return Container(
      width: 480,
      height: 330, // Augmenté pour éviter tout overflow futur
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 15)),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header Officiel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF003366),
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              border: Border(bottom: BorderSide(color: Color(0xFFB21F1F), width: 5)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/logo.jpg', width: 45, height: 45, fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INSTITUT SUPÉRIEUR DES TECHNIQUES MÉDICALES', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                      Text('DE MAHAGI (ISTM-MAHAGI)', 
                        style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Corps de la Carte
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone Photo
                  Column(
                    children: [
                      Container(
                        width: 110,
                        height: 120, // Réduit pour gagner de l'espace vertical
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFF003366), width: 2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          image: DecorationImage(
                            image: (user.photoProfil != 'default.jpg' && user.photoProfil.startsWith('http'))
                                ? NetworkImage(user.photoProfil)
                                : const AssetImage('assets/images/logo.jpg') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('ÉTUDIANT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFFB21F1F), letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Zone Détails
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 45,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text('${user.nomEtu} ${user.postnomEtu} ${user.prenomEtu}'.toUpperCase(), 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF003366), letterSpacing: -0.5)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoRow('Matricule', user.matriculeEtu, isBold: true),
                        _infoRow('Faculté', faculty),
                        _infoRow('Départ.', dept),
                        _infoRow('Promotion', promo),
                        const Spacer(),
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text('VALIDITÉ : 2025 - 2026', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Footer avec Signature & QR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(19)),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LE SECRÉTAIRE GÉNÉRAL ACADÉMIQUE', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontSize: 8, fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text('Signature autorisée', style: TextStyle(color: Colors.grey, fontSize: 7)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: Image.network('https://api.qrserver.com/v1/create-qr-code/?size=50x50&data=ISTM-VERIF-${user.matriculeEtu}', width: 40, height: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 65, child: Text('$label:', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w800))),
          Expanded(child: Text(value.isEmpty ? 'Non défini' : value, 
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700))),
        ],
      ),
    );
  }
}
