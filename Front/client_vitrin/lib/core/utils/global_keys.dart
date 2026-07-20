import 'package:flutter/material.dart';

/// Global key for accessing [ScaffoldMessengerState] anywhere in the app
/// without requiring a [BuildContext]. Used by core error interceptors.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Global key for root [NavigatorState] navigation if needed.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();
