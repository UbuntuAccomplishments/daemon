import 'dart:async';

import 'package:accom_daemon/accom_dbus.dart';
import 'package:dbus/dbus.dart';

void main(List<String> arguments) async {
  final client = DBusClient.session();
  await client.requestName('org.ubuntu.Accomplishments');

  final dbusService = AccomDBus();
  await client.registerObject(dbusService);

  Timer.periodic(Duration(hours: 1), (_) async {
    await dbusService.api.runScripts([]);
    await dbusService.api.checkSignatures();
  });
}
