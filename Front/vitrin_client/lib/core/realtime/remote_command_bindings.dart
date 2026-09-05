import '../services/app_update_service.dart';
import '../utils/global_keys.dart';
import 'remote_command_service.dart';
import '../../features/admin/presentation/screens/admin_panel_screen.dart';

/// Single place that wires remote command *types* (plain strings agreed
/// with the backend, see `Back/Realtime/Hub.go`) to what they actually do
/// in this app. [RemoteCommandService] itself stays completely unaware of
/// any specific command - adding a new one is just one more
/// `registerHandler` call here, nothing else in the app needs to change.
abstract class RemoteCommandBindings {
  static bool _registered = false;

  static void registerAll() {
    if (_registered) return;
    _registered = true;

    final service = RemoteCommandService.instance;

    // Lets an admin open this kiosk's settings panel remotely (e.g. to
    // debug it without driving to the site) without needing the on-device
    // password - the backend already required an authenticated admin to
    // trigger this in the first place.
    service.registerHandler('open_admin_panel', (payload) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) AdminPanelScreen.open(context);
    });

    // Remote command to check for updates
    service.registerHandler('check_for_update', (payload) {
      AppUpdateService.checkForUpdate();
    });
  }
}
