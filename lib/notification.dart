import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:path/path.dart' as path;

var client = NotificationsClient();

Future<void> notify(String message) async {
  try {
    await client.notify(
      message,
      appName: 'Ubuntu Accomplishments',
      appIcon:
          path.join(path.current, 'data/ubuntu-accomplishments-system.svg'),
    );
  } catch (_) {}
}
