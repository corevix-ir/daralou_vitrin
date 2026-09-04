package com.example.vitrin_client

import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * This activity doubles as the device's Home app on kiosk installs (see the
 * HOME/DEFAULT intent-filter in AndroidManifest.xml). Two things follow from
 * that role: there must be nothing to "go back" to, and the admin panel
 * needs a way to jump into native settings screens the Flutter side can't
 * reach on its own.
 */
class MainActivity : FlutterActivity() {
    private val systemSettingsChannel = "vitrin_client/system_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, systemSettingsChannel)
            .setMethodCallHandler { call, result ->
                val action = when (call.method) {
                    "openDeveloperOptions" -> Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS
                    "openSettings" -> Settings.ACTION_SETTINGS
                    "openWifiSettings" -> Settings.ACTION_WIFI_SETTINGS
                    "openBluetoothSettings" -> Settings.ACTION_BLUETOOTH_SETTINGS
                    else -> null
                }
                if (action == null) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    result.success(true)
                } catch (e: ActivityNotFoundException) {
                    result.success(false)
                }
            }
    }

    // As the Home app, this screen sits at the root of its task with nowhere
    // to return to, so the back button/gesture must never close or
    // background it the way it would for a regular app.
    @Suppress("MissingSuperCall", "OVERRIDE_DEPRECATION")
    override fun onBackPressed() {
        // Intentionally swallowed.
    }
}
