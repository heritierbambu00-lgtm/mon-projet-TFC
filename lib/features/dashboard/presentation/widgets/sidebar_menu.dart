import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/core/navigation/auth_wrapper.dart';

class SidebarMenu extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? photoUrl;
  final String userName;
  final String roleTitle;
  final List<SidebarItem>? customItems;

  const SidebarMenu({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    this.photoUrl,
    required this.userName,
    required this.roleTitle,
    this.customItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 280 : 85, 
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Elegant Institutional Header
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(image: AssetImage('assets/images/logo.jpg'), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ISTM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
                      Text('MAHAGI', style: TextStyle(color: AppColors.accentYellow, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 4)),
                    ],
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 50),
          
          // Identity Section (More compact profile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.premiumGold.withOpacity(isExpanded ? 0.4 : 0), width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: isExpanded ? 45 : 25,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        backgroundImage: (photoUrl != null && photoUrl != 'default.jpg' && photoUrl!.startsWith('http')) 
                            ? NetworkImage(photoUrl!) 
                            : null,
                        child: (photoUrl == null || photoUrl == 'default.jpg')
                          ? Icon(Icons.person_rounded, size: isExpanded ? 40 : 25, color: Colors.white.withOpacity(0.1)) 
                          : null,
                      ),
                    ),
                    if (isExpanded)
                      Positioned(
                        right: 4, bottom: 4,
                        child: Container(
                          width: 14, height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981), 
                            shape: BoxShape.circle, 
                            border: Border.all(color: AppColors.deepNavy, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      userName.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w900, 
                        fontSize: 13, 
                        letterSpacing: 1,
                        fontFamily: 'Playfair Display'
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.premiumGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.premiumGold.withOpacity(0.2)),
                    ),
                    child: Text(
                      roleTitle.toUpperCase(),
                      style: const TextStyle(color: AppColors.premiumGold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Menu Items (Ultra Premium look)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: customItems != null 
                ? customItems!.map((item) => _menuItem(item.icon, item.title, isExpanded, isActive: item.isActive, onTap: item.onTap)).toList()
                : [],
            ),
          ),

          // Action Section
          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
          _menuItem(
            Icons.power_settings_new_rounded, 
            'Déconnexion', 
            isExpanded, 
            color: const Color(0xFFFCA5A5),
            onTap: () {
              ref.read(authEntityProvider.notifier).state = null;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AuthWrapper()), 
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, bool expanded, {Color? color, VoidCallback? onTap, bool isActive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16), 
          decoration: BoxDecoration(
            border: isActive ? const Border(left: BorderSide(color: AppColors.accentYellow, width: 4)) : null,
            gradient: isActive 
              ? LinearGradient(
                  colors: [AppColors.accentYellow.withOpacity(0.1), Colors.transparent],
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                )
              : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 85, 
                child: Icon(
                  icon, 
                  color: color ?? (isActive ? AppColors.accentYellow : Colors.white24), 
                  size: 22
                ),
              ),
              if (expanded)
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color ?? (isActive ? Colors.white : Colors.white60),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                      letterSpacing: 0.5
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  SidebarItem({
    required this.icon,
    required this.title,
    this.isActive = false,
    this.onTap,
  });
}
