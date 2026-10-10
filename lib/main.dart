import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_colors.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/splash_page.dart';
import 'firebase_options.dart';
import 'core/navigation/auth_wrapper.dart';

import 'core/providers/connectivity_provider.dart';
import 'core/widgets/no_internet_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase non initialisé: $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider);

    return MaterialApp(
      title: 'ISTM MAHAGI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.darkBlue),
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      home: connectivity == ConnectivityStatus.isDisconnected
          ? NoInternetWidget(onRetry: () => ref.read(connectivityStatusProvider.notifier).retry())
          : const SplashPage(),
    );
  }
}
