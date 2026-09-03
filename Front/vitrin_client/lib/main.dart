import 'package:flutter/material.dart';
import 'core/theme/kiosk_theme.dart';
import 'core/utils/global_keys.dart';
import 'shared/widgets/kiosk_view_scaler.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DaralouVitrinKioskApp());
}

class DaralouVitrinKioskApp extends StatelessWidget {
  const DaralouVitrinKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شرکت مس درآلو - ویترین',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: KioskTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: KioskViewScaler(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const AuthGate(),
    );
  }
}
