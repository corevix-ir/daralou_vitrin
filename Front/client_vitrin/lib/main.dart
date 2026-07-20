import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/utils/global_keys.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DaralouVitrinKioskApp());
}

class DaralouVitrinKioskApp extends StatelessWidget {
  const DaralouVitrinKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شرکت مس درآلو - کیوسک دیجیتال',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: rootNavigatorKey,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.copperOrange,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.copperOrange,
          surface: AppColors.cardBackground,
        ),
        textTheme: AppTypography.textTheme,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
