import 'package:flutter/material.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/kiosk_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/utils/global_keys.dart';
import 'shared/widgets/kiosk_view_scaler.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.init();
  runApp(const DaralouVitrinKioskApp());
}

class DaralouVitrinKioskApp extends StatelessWidget {
  const DaralouVitrinKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDark;
        return MaterialApp(
          title: 'شرکت مس درآلو - ویترین',
          debugShowCheckedModeBanner: false,
          navigatorKey: rootNavigatorKey,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          theme: isDark ? KioskTheme.darkTheme : KioskTheme.lightTheme,
          scrollBehavior: AppScrollBehavior(),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: KioskViewScaler(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          // Keyed on the theme so the whole dashboard remounts cleanly on
          // toggle instead of relying on every descendant const widget
          // happening to be non-const to notice the color change. The
          // floating ball lives outside this subtree (added by
          // KioskViewScaler itself) so it is untouched by the remount.
          home: AuthGate(key: ValueKey(isDark)),
        );
      },
    );
  }
}
