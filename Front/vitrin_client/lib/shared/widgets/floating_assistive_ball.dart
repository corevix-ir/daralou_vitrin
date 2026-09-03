import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/global_keys.dart';
import '../../features/admin/presentation/screens/admin_panel_screen.dart';
import '../../features/admin/presentation/widgets/admin_password_dialog.dart';
import '../../features/auth/presentation/widgets/login_dialog.dart';

enum _StickyEdge { left, right, top, bottom }

/// A small, always-on-top floating ball (like iOS AssistiveTouch) that lives
/// above every screen in the kiosk canvas. It can be dragged anywhere and
/// snaps to the nearest wall on release; tapping it reveals a small radial
/// menu with the device login/logout action and the admin settings gate.
class FloatingAssistiveBall extends StatefulWidget {
  final Size canvasSize;

  const FloatingAssistiveBall({super.key, required this.canvasSize});

  @override
  State<FloatingAssistiveBall> createState() => _FloatingAssistiveBallState();
}

class _FloatingAssistiveBallState extends State<FloatingAssistiveBall> {
  static const double _ballSize = 84;
  static const double _subBallSize = 64;
  static const double _edgeMargin = 10;
  static const double _subButtonDistance = 104;
  static const double _subButtonGap = 88;

  final AuthState _authState = AuthState.instance;

  Offset? _position;
  bool _menuOpen = false;
  _StickyEdge _edge = _StickyEdge.right;
  Duration _animDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _authState.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authState.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Offset _defaultPosition() {
    final size = widget.canvasSize;
    return Offset(size.width - _ballSize - _edgeMargin, size.height * 0.55);
  }

  Offset _clampFree(Offset raw) {
    final size = widget.canvasSize;
    final maxX = size.width - _ballSize;
    final maxY = size.height - _ballSize;
    return Offset(raw.dx.clamp(0.0, maxX), raw.dy.clamp(0.0, maxY));
  }

  void _snapToNearestWall(Offset raw) {
    final size = widget.canvasSize;
    final maxX = size.width - _ballSize;
    final maxY = size.height - _ballSize;
    final clamped = _clampFree(raw);
    double dx = clamped.dx;
    double dy = clamped.dy;

    final distLeft = dx;
    final distRight = maxX - dx;
    final distTop = dy;
    final distBottom = maxY - dy;
    final minDist = [distLeft, distRight, distTop, distBottom].reduce(math.min);

    _StickyEdge edge;
    if (minDist == distLeft) {
      edge = _StickyEdge.left;
      dx = _edgeMargin;
    } else if (minDist == distRight) {
      edge = _StickyEdge.right;
      dx = maxX - _edgeMargin;
    } else if (minDist == distTop) {
      edge = _StickyEdge.top;
      dy = _edgeMargin;
    } else {
      edge = _StickyEdge.bottom;
      dy = maxY - _edgeMargin;
    }

    setState(() {
      _animDuration = const Duration(milliseconds: 220);
      _position = Offset(dx, dy);
      _edge = edge;
    });
  }

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);

  void _closeMenu() {
    if (_menuOpen) setState(() => _menuOpen = false);
  }

  Future<void> _handleAuthTap() async {
    _closeMenu();
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;

    if (_authState.isLoggedIn) {
      final confirmed = await showDialog<bool>(
        context: navContext,
        builder: (context) => _LogoutConfirmDialog(username: _authState.username),
      );
      if (confirmed == true) {
        await _authState.logout();
      }
    } else {
      LoginDialog.show(navContext, onLoginSuccess: _authState.refresh);
    }
  }

  Future<void> _handleAdminTap() async {
    _closeMenu();
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;

    final granted = await AdminPasswordDialog.show(navContext);
    if (granted == true) {
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    }
  }

  void _handleThemeToggle() {
    _closeMenu();
    ThemeController.instance.toggle();
  }

  Offset _inwardDirection() {
    switch (_edge) {
      case _StickyEdge.left:
        return const Offset(1, 0);
      case _StickyEdge.right:
        return const Offset(-1, 0);
      case _StickyEdge.top:
        return const Offset(0, 1);
      case _StickyEdge.bottom:
        return const Offset(0, -1);
    }
  }

  List<Widget> _buildSubButtons() {
    final position = _position;
    if (position == null) return [];

    final mainCenter = Offset(position.dx + _ballSize / 2, position.dy + _ballSize / 2);
    final inward = _inwardDirection();
    final perpendicular = Offset(-inward.dy, inward.dx);

    final specs = <_SubButtonSpec>[
      _SubButtonSpec(
        icon: _authState.isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
        label: _authState.isLoggedIn
            ? 'خروج دستگاه (${_authState.username})'
            : 'ورود دستگاه',
        color: _authState.isLoggedIn ? AppColors.errorContainer : AppColors.primary,
        onTap: _handleAuthTap,
      ),
      _SubButtonSpec(
        icon: Icons.admin_panel_settings_rounded,
        label: 'تنظیمات ادمین',
        color: AppColors.slateDark,
        onTap: _handleAdminTap,
      ),
      _SubButtonSpec(
        icon: ThemeController.instance.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        label: ThemeController.instance.isDark ? 'حالت روشن' : 'حالت تیره',
        color: AppColors.slateDark,
        onTap: _handleThemeToggle,
      ),
    ];

    final size = widget.canvasSize;
    final widgets = <Widget>[];
    for (var i = 0; i < specs.length; i++) {
      final offsetAlongPerp = (i - (specs.length - 1) / 2) * _subButtonGap;
      final targetCenter = _menuOpen
          ? mainCenter + inward * _subButtonDistance + perpendicular * offsetAlongPerp
          : mainCenter;

      var topLeft = targetCenter - const Offset(_subBallSize / 2, _subBallSize / 2);
      topLeft = Offset(
        topLeft.dx.clamp(0.0, size.width - _subBallSize),
        topLeft.dy.clamp(0.0, size.height - _subBallSize),
      );

      widgets.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          left: topLeft.dx,
          top: topLeft.dy,
          child: IgnorePointer(
            ignoring: !_menuOpen,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _menuOpen ? 1 : 0,
              child: _SubBallButton(spec: specs[i], size: _subBallSize),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _mainBall() {
    final loggedIn = _authState.isLoggedIn;
    final accent = loggedIn ? AppColors.emeraldGreen : AppColors.primary;
    return Container(
      width: _ballSize,
      height: _ballSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceContainerHigh, AppColors.surfaceContainerLow],
        ),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        _menuOpen ? Icons.close_rounded : Icons.apps_rounded,
        color: accent,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _position ??= _defaultPosition();
    final position = _position!;

    return Stack(
      children: [
        if (_menuOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),
          ),
        ..._buildSubButtons(),
        AnimatedPositioned(
          duration: _animDuration,
          curve: Curves.easeOutCubic,
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanStart: (_) {
              setState(() {
                _menuOpen = false;
                _animDuration = Duration.zero;
              });
            },
            onPanUpdate: (details) {
              setState(() => _position = _clampFree(position + details.delta));
            },
            onPanEnd: (_) => _snapToNearestWall(_position!),
            onTap: _toggleMenu,
            child: _mainBall(),
          ),
        ),
      ],
    );
  }
}

class _SubButtonSpec {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SubButtonSpec({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _SubBallButton extends StatelessWidget {
  final _SubButtonSpec spec;
  final double size;

  const _SubBallButton({required this.spec, required this.size});

  @override
  Widget build(BuildContext context) {
    // Note: this tree lives outside the app's Navigator/Overlay (by design,
    // so it survives across every screen), so widgets that need an Overlay
    // ancestor - like Tooltip - can't be used here. Semantics works fine.
    return Semantics(
      label: spec.label,
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: spec.onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spec.color,
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(spec.icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  final String username;

  const _LogoutConfirmDialog({required this.username});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.primary, size: 40),
            const SizedBox(height: 16),
            Text(
              'خروج دستگاه ($username)',
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'آیا مطمئن هستید می‌خواهید از حساب این دستگاه خارج شوید؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('انصراف', style: TextStyle(fontFamily: 'Peyda')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorContainer),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'خروج',
                      style: TextStyle(fontFamily: 'Peyda', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
