import 'package:flutter/services.dart';

/// Bridges to the native `MainActivity` MethodChannel (see
/// `android/.../MainActivity.kt`) so the admin panel can open Android's own
/// developer options, settings, Wi-Fi and Bluetooth screens. Kept as a tiny
/// hand-rolled channel instead of a generic intent plugin since these four
/// fixed destinations are all the kiosk needs.
class SystemIntentService {
  SystemIntentService._();

  static const MethodChannel _channel = MethodChannel('vitrin_client/system_settings');

  static Future<bool> openDeveloperOptions() => _invoke('openDeveloperOptions');

  static Future<bool> openSystemSettings() => _invoke('openSettings');

  static Future<bool> openWifiSettings() => _invoke('openWifiSettings');

  static Future<bool> openBluetoothSettings() => _invoke('openBluetoothSettings');

  static Future<bool> _invoke(String method) async {
    try {
      final result = await _channel.invokeMethod<bool>(method);
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
