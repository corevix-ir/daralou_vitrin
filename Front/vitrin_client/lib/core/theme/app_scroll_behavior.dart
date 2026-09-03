import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Kiosk hardware swipes via touch, but this app also runs (and gets
/// developed/tested) as a desktop/web build driven with a mouse. Flutter's
/// default [MaterialScrollBehavior] only treats touch/stylus drags as scroll
/// gestures and ignores mouse drags, so swiping a `PageView` with a mouse
/// would silently do nothing. This enables every pointer kind to drag.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
