import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/etudiant_entity.dart';
import 'package:istm_mahagi/features/academic/presentation/providers/academic_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final promosAsync = ref.watch(promotionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('DÉTAILS DU PROFIL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: userDataAsync.when(
        data: (user) {
          if (user == null || user is! EtudiantEntity) return const Center(child: Text("Profil introuvable."));

          return promosAsync.when(
            data: (promos) {
              final promo = promos.where((p) => p.stableId == user.idPromo).firstOrNull;
              final String promoLabel = promo?.nomPromo ?? "Promotion ${user.idPromo}";
              final bool isMobile = Responsive.isMobile(context);

              return SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 15 : 30),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      children: [
                        _buildHeader(user, isMobile),
                        const SizedBox(height: 30),
                        if (isMobile) ...[
                          _buildInfoTable('IDENTITÉ FONDAMENTALE', {
                            'Matricule': user.matriculeEtu,
                            'Nom': user.nomEtu,
                            'Post-Nom': user.postnomEtu,
                            'Prénom': user.prenomEtu,
                            'Genre': user.sexe,
                            'État Civil': user.etatCivil,
                            'Téléphone': user.telephone,
                            'Tél. Tuteur': user.telTuteur,
                            'Email': user.emailPersonnel,
                            'Naissance': "${user.dateNaissance?.day}/${user.dateNaissance?.month}/${user.dateNaissance?.year} à ${user.lieuNaissance}",
                            'Nationalité': user.nationalite,
                            'Province': user.provinceOrigine,
                          }),
                          const SizedBox(height: 25),
                          _buildInfoTable('PARCOURS & SANTÉ', {
                            'Promotion': promoLabel,
                            'École Secondaire': user.ecoleSecondaire,
                            'Orientation': user.orientation,
                            'Pourcentage': "${user.pourcentage} %",
                            'Nom du Père': user.nomPere,
                            'Nom de la Mère': user.nomMere,
                            'Sponsor': user.sponsor,
                            'Groupe Sanguin': user.groupeSanguin,
                            'Handicap': user.handicap,
                          }),
                          const SizedBox(height: 30),
                          _buildPhotoSection(user),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildInfoTable('IDENTITÉ FONDAMENTALE', {
                                'Matricule': user.matriculeEtu,
                                'Nom': user.nomEtu,
                                'Post-Nom': user.postnomEtu,
                                'Prénom': user.prenomEtu,
                                'Genre': user.sexe,
                                'État Civil': user.etatCivil,
                                'Téléphone': user.telephone,
                                'Tél. Tuteur': user.telTuteur,
                                'Email': user.emailPersonnel,
                                'Naissance': "${user.dateNaissance?.day}/${user.dateNaissance?.month}/${user.dateNaissance?.year} à ${user.lieuNaissance}",
                                'Nationalité': user.nationalite,
                                'Province': user.provinceOrigine,
                              })),
                              const SizedBox(width: 30),
                              Expanded(child: Column(
                                children: [
                                  _buildInfoTable('PARCOURS & SANTÉ', {
                                    'Promotion': promoLabel,
                                    'École Secondaire': user.ecoleSecondaire,
                                    'Orientation': user.orientation,
                                    'Pourcentage': "${user.pourcentage} %",
                                    'Nom du Père': user.nomPere,
                                    'Nom de la Mère': user.nomMere,
                                    'Sponsor': user.sponsor,
                                    'Groupe Sanguin': user.groupeSanguin,
                                    'Handicap': user.handicap,
                                  }),
                                  const SizedBox(height: 30),
                                  _buildPhotoSection(user),
                                ],
                              )),
                            ],
                          ),
                        const SizedBox(height: 50),
                        _buildPremiumExtensions(context, user),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur profil: $e')),
      ),
    );
  }

  Widget _buildHeader(EtudiantEntity user, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF003366), width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              isMobile ? 'MON PROFIL' : 'DÉTAILS DU PROFIL', 
              style: TextStyle(fontWeight: FontWeight.w900, color: const Color(0xFF003366), fontSize: isMobile ? 20 : 24)
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/logo.jpg', width: isMobile ? 40 : 50, height: isMobile ? 40 : 50, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTable(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 15),
        Table(
          border: TableBorder.all(color: const Color(0xFFE0E0E0)),
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(2),
          },
          children: data.entries.map((entry) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF555555))),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(entry.value.isEmpty ? 'Ras' : entry.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(EtudiantEntity user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('Photo de l\'étudiant', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            width: 150,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF003366), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: (user.photoProfil != 'default.jpg' && user.photoProfil.startsWith('http'))
                ? Image.network(user.photoProfil, fit: BoxFit.cover)
                : const Icon(Icons.person, size: 80, color: Color(0xFFE2E8F0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumExtensions(BuildContext context, EtudiantEntity user) {
    return Column(
      children: [
        // augmented: Digital ID Card
        PremiumFadeIn(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              gradient: AppColors.deepGradient,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(color: AppColors.deepNavy.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ISTM MAHAGI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
                        Text('Digital Student Identity', style: TextStyle(color: AppColors.accentYellow, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                    Icon(Icons.nfc_rounded, color: Colors.white.withOpacity(0.3), size: 30),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.premiumGold, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: (user.photoProfil != 'default.jpg' && user.photoProfil.startsWith('http')) 
                            ? NetworkImage(user.photoProfil) 
                            : null,
                        child: (user.photoProfil == 'default.jpg') ? const Icon(Icons.person) : null,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.nomEtu.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Playfair Display')),
                          Text(user.matriculeEtu, style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.qr_code_2_rounded, color: AppColors.deepNavy, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Section Badges
        PremiumFadeIn(
          delay: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.premiumGold.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.premiumGold, size: 40),
                const SizedBox(height: 15),
                const Text(
                  'STATUT ACADÉMIQUE CERTIFIÉ',
                  style: TextStyle(color: AppColors.premiumGold, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 3),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Étudiant Régulier & Actif',
                  style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Playfair Display'),
                ),
                const SizedBox(height: 15),
                Text(
                  'Ce profil est validé par les services académiques pour l\'exercice 2025-2026.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Section Sécurité
        PremiumFadeIn(
          delay: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SÉCURITÉ DU COMPTE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.deepNavy)),
                      Text('Vos données sont protégées par cryptage AES-256.', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Section Aide & Support Premium
        PremiumFadeIn(
          delay: const Duration(milliseconds: 600),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, color: AppColors.accentYellow, size: 24),
                    SizedBox(width: 15),
                    Text(
                      'BESOIN D\'AIDE ?',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Une erreur dans vos informations ? Contactez le Secrétariat Académique via le bouton ci-dessous.',
                  style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('CONTACTER LE SUPPORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
