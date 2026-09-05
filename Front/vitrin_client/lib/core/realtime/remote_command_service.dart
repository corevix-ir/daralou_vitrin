import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../config/app_config.dart';
import '../network/auth_token_storage.dart';

typedef RemoteCommandHandler = void Function(Map<String, dynamic> payload);

/// Persistent Socket.IO connection the backend uses to push commands to
/// this exact kiosk in near-real-time (open a settings screen, prompt an
/// update check, ...) instead of waiting on a polling interval. See
/// `Back/Realtime/Hub.go` for the server side of this contract.
///
/// Authenticates with the very same access token already used for every
/// REST call (see [AuthInterceptor]) - only a logged-in device can receive
/// commands, matching every other authenticated endpoint in this app. The
/// token is re-read from storage on every (re)connection attempt via
/// `OptionBuilder.setAuthFn`, so a rotated token or a fresh login is
/// picked up automatically without recreating the socket.
///
/// This service only knows how to dispatch a `{type, payload}` envelope to
/// whichever handler is registered for that `type` - it has no idea what
/// any individual command actually does. New remote commands are added in
/// one place, [RemoteCommandBindings], by registering one more handler
/// here; nothing in this file ever needs to change for that.
class RemoteCommandService {
  RemoteCommandService._internal();
  static final RemoteCommandService instance = RemoteCommandService._internal();

  final AuthTokenStorage _tokenStorage = AuthTokenStorage.instance;
  final Map<String, RemoteCommandHandler> _handlers = {};

  socket_io.Socket? _socket;

  void registerHandler(String type, RemoteCommandHandler handler) {
    _handlers[type] = handler;
  }

  /// Opens (or resumes) the socket connection. Safe to call repeatedly -
  /// only the first call actually builds the socket; later calls just make
  /// sure it's connected.
  void connect() {
    final existing = _socket;
    if (existing != null) {
      if (!existing.connected) existing.connect();
      return;
    }

    final socket = socket_io.io(
      AppConfig.current.baseUrl,
      socket_io.OptionBuilder()
          .disableAutoConnect()
          // This package has no real polling transport on native platforms
          // (dart:io) - it silently substitutes a WebSocket transport for
          // whatever name the manager asks for, but still labels the
          // handshake as "polling" by default, which the Go server doesn't
          // accept as a valid upgrade. Forcing 'websocket' here makes the
          // very first attempt match what actually works.
          .setTransports(['websocket'])
          .setAuthFn((callback) {
            _tokenStorage.getAccessToken().then((token) {
              callback({'token': token ?? ''});
            });
          })
          .build(),
    );

    socket.on('command', _handleIncoming);

    if (AppConfig.current.isDebug) {
      socket.onConnect((_) => _log('متصل شد'));
      socket.onConnectError((err) => _log('خطای اتصال: $err'));
      socket.onDisconnect((reason) => _log('قطع شد: $reason'));
    }

    _socket = socket;
    socket.connect();
  }

  /// Closes the connection - called on logout, since a signed-out device
  /// can't authenticate a new handshake anyway (see `Hub.authenticate` on
  /// the backend).
  void disconnect() {
    _socket?.disconnect();
  }

  void _handleIncoming(dynamic data) {
    if (data is! Map) return;

    final type = data['type']?.toString();
    if (type == null || type.isEmpty) return;

    final rawPayload = data['payload'];
    final payload = rawPayload is Map ? rawPayload.cast<String, dynamic>() : <String, dynamic>{};

    _handlers[type]?.call(payload);
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[RemoteCommandService] $message');
  }
}
