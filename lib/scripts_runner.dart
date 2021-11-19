import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:process/process.dart';

import 'api.dart';

enum ScriptsState {
  running,
  stopped,
}

class ScriptsRunner {
  final Accomplishments parent;

  final scriptsQueue = Queue();
  final procman = LocalProcessManager();

  ScriptsState state = ScriptsState.stopped;

  ScriptsRunner(this.parent);

  startScriptRunner() async {
    if (state == ScriptsState.running) {
      return;
    }

    state = ScriptsState.running;

    var queuesize = scriptsQueue.length;
    stdout.writeln(
        "--- Starting Running Scripts - $queuesize items on the queue ---");
    final timestart = DateTime.now();
    if (!parent.testMode) {
      parent.service.scriptrunnerStart();
    }

    var unlockedNewTrophies = false;
    while (queuesize > 0) {
      final String accomID = scriptsQueue.removeFirst();
      stdout.writeln("Running $accomID, left on queue: ${queuesize - 1}");

      if (await parent.checkIfAccomIsAccomplished(accomID)) {
        unlockedNewTrophies =
            (unlockedNewTrophies) ? true : await parent.accomplish(accomID);
      } else {
        final scriptpath = parent.getAccomScriptPath(accomID);
        if (scriptpath == null) {
          stdout.writeln("...No script for this accomplishment, skipping");
        } else if (!await parent.isAllExtraInformationAvailable(accomID)) {
          stdout.writeln(
              "...Extra information required, but not available, skipping");
        } else {
          final extraInformation = await parent.getAllExtraInformation();
          final ei = {};
          for (var item in extraInformation) {
            ei[item['needs-information']] = item['value'];
          }
          final result = await procman.run([scriptpath, jsonEncode(ei)]);
          switch (result.exitCode) {
            case 0:
              stdout.writeln("...Accomplished");
              await parent.accomplish(accomID);
              break;
            case 1:
              stdout.writeln("...Not Accomplished");
              break;
            case 2:
              stdout.writeln("....Error");
              break;
            case 4:
              stdout.writeln("...Could not get extra-information");
              break;
            default:
              stdout.writeln("...Error code ${result.exitCode}");
          }
        }

        queuesize = scriptsQueue.length;
      }
    }

    stdout.writeln("The queue is now empty - stopping the scriptrunner.");

    final timeend = DateTime.now();
    final timeelapsed = timeend.difference(timestart).inSeconds;

    stdout.writeln("--- Emptied the scripts queue in $timeelapsed seconds---");
    if (!parent.testMode) {
      parent.service.scriptrunnerFinish();
    }

    state = ScriptsState.stopped;
    if (unlockedNewTrophies) {
      Timer(Duration(seconds: 30), () => parent.runScripts([]));
    }
  }
}
