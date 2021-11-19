import 'dart:async';

import 'package:accom_daemon/accom_dbus.dart';
import 'package:dbus/dbus.dart';

void main(List<String> arguments) async {
  final client = DBusClient.session();
  await client.requestName('org.ubuntu.Accomplishments');

  final dbusService = AccomDBus();
  await client.registerObject(dbusService);

  await dbusService.api.reloadAccomDatabase();

  // Hourly repeating timer to regularly check for new accomplishments
  Timer.periodic(Duration(hours: 1), (_) => dbusService.api.runScripts([]));

  // Oneshot timer for initial startup rescan
  Timer(Duration(minutes: 5), () => dbusService.api.runScripts([]));
}
