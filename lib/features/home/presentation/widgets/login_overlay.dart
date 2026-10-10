import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';

class LoginOverlay extends ConsumerStatefulWidget {
  final String role;
  final VoidCallback onClose;

  const LoginOverlay({
    super.key,
    required this.role,
    required this.onClose,
  });

  @override
  ConsumerState<LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends ConsumerState<LoginOverlay> {
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPass = false;

  Future<void> _handleLogin() async {
    if (_matriculeController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userEntity = await authRepo.login(
        _matriculeController.text.trim(),
        _passwordController.text,
      );

      if (userEntity == null) {
        setState(() => _errorMessage = "Identifiants ou rôle incorrects pour cet espace.");
      } else {
        ref.read(authEntityProvider.notifier).state = userEntity;
        ref.read(loginOverlayProvider.notifier).state = null;
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background blur & overlay
          GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          // Form Container with Keyboard avoidance
          Center(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Container(
                  width: isMobile ? double.infinity : (isTablet ? 450 : 500),
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: EdgeInsets.all(isMobile ? 30 : 45),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(isMobile ? 30 : 45),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.1), 
                        blurRadius: 50, 
                        offset: const Offset(0, 25)
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isMobile ? 30 : 45),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 30 : 45),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Hero(
                              tag: 'login_logo',
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: CircleAvatar(
                                  radius: isMobile ? 40 : 50,
                                  backgroundImage: const AssetImage('assets/images/logo.jpg'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),
                            Text(
                              'ESPACE SÉCURISÉ',
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.w900, 
                                letterSpacing: 4, 
                                color: AppColors.premiumGold
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.role.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 24 : 32, 
                                fontWeight: FontWeight.w900, 
                                color: AppColors.textMain, 
                                fontFamily: 'Playfair Display',
                                letterSpacing: -1.0
                              ),
                            ),
                            const SizedBox(height: 40),
                            if (_errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.only(bottom: 25),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2).withOpacity(0.7), 
                                  borderRadius: BorderRadius.circular(15), 
                                  border: Border.all(color: const Color(0xFFFCA5A5))
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!, 
                                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _buildPremiumInput(
                              controller: _matriculeController, 
                              hint: 'Identifiant / Matricule', 
                              icon: Icons.account_circle_outlined
                            ),
                            const SizedBox(height: 20),
                            _buildPremiumInput(
                              controller: _passwordController,
                              hint: 'Mot de passe',
                              icon: Icons.lock_person_outlined,
                              isPassword: true,
                              showPass: _showPass,
                              onTogglePass: () => setState(() => _showPass = !_showPass),
                            ),
                            const SizedBox(height: 45),
                            Container(
                              width: double.infinity,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: AppColors.deepGradient,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withOpacity(0.3), 
                                    blurRadius: 20, 
                                    offset: const Offset(0, 10)
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent, 
                                  foregroundColor: Colors.white, 
                                  shadowColor: Colors.transparent, 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                ),
                                child: _isLoading 
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                  : const Text('ACCÉDER AU PORTAIL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                              ),
                            ),
                            const SizedBox(height: 25),
                            TextButton(
                              onPressed: widget.onClose,
                              child: Text(
                                'ANNULER'.toUpperCase(), 
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildPremiumInput({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool? showPass, VoidCallback? onTogglePass}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !(showPass ?? false),
        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF334155), size: 20),
          suffixIcon: isPassword ? IconButton(onPressed: onTogglePass, icon: Icon((showPass ?? false) ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 16)) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
