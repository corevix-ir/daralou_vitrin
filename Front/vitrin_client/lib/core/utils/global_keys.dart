import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Lets globally-mounted overlays (e.g. the floating assistive ball) push
/// routes and open dialogs without a Navigator ancestor of their own.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
