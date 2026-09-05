import 'dart:async';
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

class _FloatingAssistiveBallState extends State<FloatingAssistiveBall>
    with SingleTickerProviderStateMixin {
  static const double _ballSize = 84;
  static const double _subBallSize = 64;
  static const double _edgeMargin = 10;
  static const double _subButtonDistance = 104;
  static const double _subButtonGap = 88;

  // How long the ball sits untouched before it "rests" against the wall,
  // and how far it sinks into it — like a water droplet that has mostly
  // (but not fully) soaked into the edge, leaving a small bulge visible.
  static const Duration _idleDelay = Duration(seconds: 4);
  static const double _idleShrinkScale = 0.8;
  static const double _idleSinkFraction = 0.72;
  static const double _idleOpacity = 0.8;

  final AuthState _authState = AuthState.instance;

  Offset? _position;
  bool _menuOpen = false;
  bool _idle = false;
  _StickyEdge _edge = _StickyEdge.right;
  Duration _animDuration = Duration.zero;
  Curve _mainCurve = Curves.easeOutCubic;

  Timer? _idleTimer;
  late final AnimationController _breatheController;
  late final Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _authState.addListener(_onAuthChanged);
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _breathe = CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut);
    _scheduleIdle();
  }

  @override
  void dispose() {
    _authState.removeListener(_onAuthChanged);
    _idleTimer?.cancel();
    _breatheController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _scheduleIdle() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleDelay, () {
      if (!mounted || _menuOpen || _idle) return;
      setState(() {
        _idle = true;
        _animDuration = const Duration(milliseconds: 520);
        _mainCurve = Curves.easeInOutSine;
      });
    });
  }

  // Direction pointing away from the canvas, through the wall the ball is
  // resting against — used to push the idle ball partly off-stage so it
  // reads as "sunk into" the edge rather than merely shrunk in place.
  Offset _idleOutwardOffset() {
    final inward = _inwardDirection();
    return -inward * (_ballSize * _idleSinkFraction);
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
      _mainCurve = Curves.easeOutCubic;
      _position = Offset(dx, dy);
      _edge = edge;
    });
    _scheduleIdle();
  }

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);

  void _closeMenu() {
    if (_menuOpen) setState(() => _menuOpen = false);
    _scheduleIdle();
  }

  // Tapping the resting (idle) droplet first pops it back to the full ball
  // — a little bounce "coming up" off the wall — and only once that
  // settles does the radial menu actually open, per how a real button
  // would surface itself before reacting.
  void _handleMainTap() {
    _idleTimer?.cancel();
    if (_idle) {
      const wakeDuration = Duration(milliseconds: 360);
      setState(() {
        _idle = false;
        _animDuration = wakeDuration;
        _mainCurve = Curves.easeOutBack;
      });
      Future.delayed(wakeDuration, () {
        if (!mounted) return;
        setState(() => _menuOpen = true);
      });
    } else {
      _toggleMenu();
      if (!_menuOpen) _scheduleIdle();
    }
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

  /// Pops the current screen, whatever it is - a one-tap "back" reachable
  /// from anywhere in the app. On a large kiosk touchscreen, the in-screen
  /// back button (top corner of e.g. the news list/detail screens) can be
  /// an awkward reach; this stays right next to the ball wherever it's
  /// docked. A no-op if there's nothing to pop (already on the home
  /// screen), same as any other back action.
  void _handleBackTap() {
    _closeMenu();
    rootNavigatorKey.currentState?.maybePop();
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
      _SubButtonSpec(
        icon: Icons.arrow_forward_rounded,
        label: 'بازگشت',
        color: AppColors.slateDark,
        onTap: _handleBackTap,
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

      // Each sub-button gets a slightly longer delay than the last so they
      // cascade open instead of popping in all at once.
      final stagger = _menuOpen ? i * 35 : 0;
      widgets.add(
        AnimatedPositioned(
          duration: Duration(milliseconds: 200 + stagger),
          curve: Curves.easeOutBack,
          left: topLeft.dx,
          top: topLeft.dy,
          child: IgnorePointer(
            ignoring: !_menuOpen,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 150 + stagger),
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
            color: AppColors.scrim.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1).animate(anim),
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: Icon(
          _menuOpen ? Icons.close_rounded : Icons.apps_rounded,
          key: ValueKey(_menuOpen),
          color: accent,
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _position ??= _defaultPosition();
    final position = _position!;
    final renderPosition = _idle ? position + _idleOutwardOffset() : position;

    return Stack(
      children: [
        if (_menuOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeMenu,
              child: Container(color: AppColors.scrim.withValues(alpha: 0.15)),
            ),
          ),
        ..._buildSubButtons(),
        AnimatedPositioned(
          duration: _animDuration,
          curve: _mainCurve,
          left: renderPosition.dx,
          top: renderPosition.dy,
          child: GestureDetector(
            onPanStart: (_) {
              _idleTimer?.cancel();
              setState(() {
                _menuOpen = false;
                _idle = false;
                _animDuration = Duration.zero;
              });
            },
            onPanUpdate: (details) {
              setState(() => _position = _clampFree(position + details.delta));
            },
            onPanEnd: (_) => _snapToNearestWall(_position!),
            onTap: _handleMainTap,
            child: AnimatedBuilder(
              animation: _breathe,
              builder: (context, child) {
                // A very small, continuous "living" wobble on top of the
                // idle shrink — only noticeable while the droplet is
                // resting, so it reads as alive rather than frozen.
                final wobble = 1 + (_breathe.value - 0.5) * 0.07;
                return Transform.scale(scale: _idle ? wobble : 1.0, child: child);
              },
              child: AnimatedScale(
                scale: _idle ? _idleShrinkScale : 1.0,
                duration: _animDuration,
                curve: _mainCurve,
                child: AnimatedOpacity(
                  opacity: _idle ? _idleOpacity : 1.0,
                  duration: _animDuration,
                  curve: _mainCurve,
                  child: _mainBall(),
                ),
              ),
            ),
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
              border: Border.all(color: AppColors.onDarkBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.scrim.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(spec.icon, color: AppColors.onDark, size: 24),
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
                      style: TextStyle(fontFamily: 'Peyda', color: AppColors.onDark),
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
