import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:xdg_directories/xdg_directories.dart';

import 'constants.dart';

final scriptpath = Platform.script.toFilePath(windows: Platform.isWindows);

class AccomConfig {
  late String accomsInstallpaths;
  late String trophiesPath;
  late String mediaDirPath;
  late String cacheDirPath;
  late String configDirPath;
  late String dataDirPath;
  late String autostartDirPath;
  late RSAPublicKey stagingPubkey;
  late RSAPublicKey productionPubkey;
  bool hasU1 = false;
  bool hasVerif = false;
  bool showNotifications = true;
  String matrixUsername = productionId;

  AccomConfig() {
    final rootdir = Platform.environment['ACCOMPLISHMENTS_ROOT_DIR'];
    final snapdir = Platform.environment['SNAP'];
    final snapuserdata = Platform.environment['SNAP_USER_DATA'];

    if (rootdir != null && rootdir != "") {
      dataDirPath = path.join(rootdir, "data");
      mediaDirPath = path.join(dataDirPath, "media");
      configDirPath = path.join(rootdir, "accomplishments");
      cacheDirPath =
          path.join(rootdir, "accomplishments", ".cache", "accomplishments");
      autostartDirPath = path.join(configHome.path, "autostart");
    } else {
      dataDirPath = '/usr/share/accomplishments';
      mediaDirPath = path.join(dataDirPath, "data", "media");
      configDirPath = path.join(configHome.path, "accomplishments");
      cacheDirPath = path.join(cacheHome.path, "accomplishments");
      autostartDirPath = path.join(configHome.path, "autostart");

      if (snapdir != null &&
          snapdir != "" &&
          snapdir.contains('ubuntu-accomplishments')) {
        dataDirPath = path.join(
          path.dirname(snapdir),
          "usr",
          "share",
          "accomplishments",
        );
        configDirPath = path.join(path.dirname(snapuserdata!), 'current',
            '.config', 'accomplishments');
      }
    }

    final configDir = Directory(configDirPath);
    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }

    final dataDir = Directory(dataDirPath);
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }

    final cacheDir = Directory(cacheDirPath);
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }

    final gpgkeyPath = path.join(dataDirPath, "daemon", "validation-key.pub");
    final stagingGpgkeyPath =
        path.join(path.dirname(gpgkeyPath), "staging-validation-key.pub");

    if (File(stagingGpgkeyPath).existsSync()) {
      stagingPubkey = parseKeyFromFileSync<RSAPublicKey>(stagingGpgkeyPath);
    }
    productionPubkey = parseKeyFromFileSync<RSAPublicKey>(gpgkeyPath);

    loadConfigFile();
  }

  T parseKeyFromFileSync<T extends RSAAsymmetricKey>(String filename) {
    final file = File(filename);
    final key = file.readAsStringSync();
    final parser = RSAKeyParser();
    return parser.parse(key) as T;
  }

  void loadConfigFile() {
    final cfile = File(path.join(configDirPath, ".accomplishments"));

    if (cfile.existsSync()) {
      final data = cfile.readAsStringSync();
      Map<String, dynamic> config = jsonDecode(data);
      if (config.isNotEmpty) {
        log("Loading configuration file: $cfile");
        final _accomsInstallpaths = config['accompath'];
        if (_accomsInstallpaths != null) {
          accomsInstallpaths = _accomsInstallpaths;
          log("...setting accomplishments install paths to: $accomsInstallpaths");
        }
        final _trophiesPath = config['trophypath'];
        if (_trophiesPath != null) {
          trophiesPath = _trophiesPath;
          log("...setting trophies path to: $_trophiesPath");
        }
        final _hasU1 = config['has_u1'];
        if (_hasU1 != null) {
          hasU1 = _hasU1.toLowerCase() == 'true';
        }
        final _hasVerif = config['has_verif'];
        if (_hasVerif != null) {
          hasVerif = _hasVerif.toLowerCase() == 'true';
        }
        if (config['staging'] != null) {
          matrixUsername = stagindId;
        } else {
          matrixUsername = productionId;
        }
      } else {
        setDefaultConfig();
      }
    } else {
      setDefaultConfig();
    }
  }

  void setDefaultConfig() {
    final accompath = "$configDirPath:$dataDirPath";
    log('Configuration file not found...creating it!');

    hasVerif = false;
    accomsInstallpaths = accompath;
    log("...setting accomplishments install paths to: $accomsInstallpaths");
    log('You can set this to different locations in your config file.');

    trophiesPath = path.join(configDirPath, "trophies");
    log("...setting trophies path to: $trophiesPath");

    if (!Directory(trophiesPath).existsSync()) {
      Directory(trophiesPath).createSync(recursive: true);
    }

    writeConfigFile();
  }

  void writeConfigFile() {
    log("Writing the configuration file");
    final cfile = File(path.join(configDirPath, ".accomplishments"));
    Map<String, String> config = {};

    config['has_u1'] = hasU1.toString();
    config['has_verif'] = hasVerif.toString();
    config['accompath'] = accomsInstallpaths;
    config['trophypath'] = trophiesPath;

    cfile.writeAsStringSync(jsonEncode(config));
  }

  Future<void> writeConfigFileItem(String item, String value) async {
    log("Set configuration file value: $item = $value");
    final cfile = File(path.join(configDirPath, ".accomplishments"));
    final data = await cfile.readAsString();
    Map<String, String> config = jsonDecode(data);
    config[item] = value;
    await cfile.writeAsString(jsonEncode(config));
    loadConfigFile();
  }

  Future<dynamic> getConfigValue(String item) async {
    log("Returning configuration values for: $item");
    final configfile = File(path.join(configDirPath, ".accomplishments"));
    final data = await configfile.readAsString();
    Map<String, String> config = jsonDecode(data);
    if (config[item] != null) {
      if (item == "has_u1") {
        return config[item]?.toLowerCase() == 'true';
      } else if (item == "has_verif") {
        return config[item]?.toLowerCase() == 'true';
      } else if (item == "daemon_sessionstart") {
        return config[item]?.toLowerCase() == 'true';
      } else {
        return config[item];
      }
    } else {
      return "No option";
    }
  }
}
