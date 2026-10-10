import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomeSplash extends StatelessWidget {
  final String userName;
  final String promo;
  final String sexe;
  final VoidCallback onClose;

  const WelcomeSplash({
    super.key,
    required this.userName,
    required this.promo,
    required this.sexe,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    String civilite = (sexe == 'M') ? "Monsieur" : ((sexe == 'F') ? "Mademoiselle" : "Cher(e)");
    String bienvenue = (sexe == 'F') ? "BIENVENUE" : "BIENVENU";

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.05),
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$bienvenue À L\'ISTM-MAHAGI',
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$civilite $userName',
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'PROMOTION : $promo',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/images/logo.jpg'), // Utilisation du logo copié
              ),
              const SizedBox(height: 20),
              const Text(
                'Cliquez n\'importe où pour entrer',
                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
