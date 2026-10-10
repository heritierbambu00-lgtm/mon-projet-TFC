import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class TpManagementPage extends StatefulWidget {
  const TpManagementPage({super.key});

  @override
  State<TpManagementPage> createState() => _TpManagementPageState();
}

class _TpManagementPageState extends State<TpManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Gestion des TPs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.darkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Travaux Pratiques en cours', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
            const SizedBox(height: 20),
            _buildTpItem('TP 01: Dissection Thoracique', 'Anatomie', '15 Août 2026', true),
            _buildTpItem('TP 02: Analyse de Sang', 'Biochimie', '20 Août 2026', false),
            _buildTpItem('TP 03: Culture Bactérienne', 'Microbiologie', '25 Août 2026', false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.darkBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NOUVEAU TP', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTpItem(String title, String course, String deadline, bool isUrgent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                child: Text(course, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Spacer(),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                  child: const Text('URGENT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text('Échéance : $deadline', style: const TextStyle(color: AppColors.textMuted)),
              const Spacer(),
              const Text('45 Soumissions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ],
          ),
          const Divider(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('VOIR LES DÉTAILS'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CORRIGER'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
