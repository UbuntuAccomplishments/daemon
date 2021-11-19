import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'accom_dbus.dart';
import 'config.dart';
import 'models/accomdb.dart';
import 'models/accomplishment.dart';
import 'models/collection.dart';
import 'models/collection_meta.dart';
import 'notification.dart';
import 'scripts_runner.dart';

class Accomplishments {
  late final AccomConfig config = AccomConfig();
  late final ScriptsRunner scriptsRunner = ScriptsRunner(this);

  final bool testMode;

  AccomDBus service;

  Signer? signer;

  var accomDB = AccomDB();
  var shareFound = false;
  String? shareName;
  String? shareID;

  Accomplishments(this.service, {this.testMode = false}) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    stdout.writeln(
        "------------------- Ubuntu Accomplishments Daemon - ${formatter.format(DateTime.now())} -------------------");

    stdout
        .writeln("Accomplishments install paths: ${config.accomsInstallpaths}");
    stdout.writeln("Trophies path: ${config.trophiesPath}");

    signer = Signer(
        RSASigner(RSASignDigest.SHA256, publicKey: config.productionPubkey));
  }

  Future<String?> getMediaFile(String mediaFileName) async {
    mediaFileName = path.join(config.mediaDirPath, mediaFileName);

    if (!await File(mediaFileName).exists()) {
      return null;
    }

    return mediaFileName;
  }

  Image createReducedOpacityTrophyIcon(Image im, {int opacity = 255}) {
    return colorOffset(im, alpha: -opacity);
  }

  Future<dynamic> getConfigValue(String section, String item) =>
      config.getConfigValue(item);

  Future<void> writeConfigFileItem(String section, String item, String value) {
    return config.writeConfigFileItem(item, value);
  }

  // Future<void> createAllTrophyIcons() async {
  //   final cols = await listCollections();

  //   for (var col in cols) {
  //     final colImagesDir = Directory(path.join(
  //         accomDB.collections[col]?.basePath ?? '/tmp', 'trophyimages'));
  //     final cacheTrophyImagesDir =
  //         Directory(path.join(config.cacheDirPath, "trophyimages", col));
  //     final lockImageFile = File(path.join(config.mediaDirPath, "lock.png"));
  //     if (!await cacheTrophyImagesDir.exists()) {
  //       await cacheTrophyImagesDir.create(recursive: true);
  //     }

  //     // First, delete all cached images:
  //     final cachedlist = cacheTrophyImagesDir.list();
  //     await for (var c in cachedlist) {
  //       await c.delete();
  //     }

  //     final mark = decodeImage(await lockImageFile.readAsBytes());
  //     Future<void> recurse(FileSystemEntity file) async {
  //       final st = await file.stat();
  //       if (st.type == FileSystemEntityType.directory) {
  //         return recurse(file);
  //       }
  //       final origImage = File(file.absolute.path);

  //       final im = decodeImage(await origImage.readAsBytes());
  //       if (im == null) {
  //         return;
  //       }

  //       final filename = path.join(
  //           cacheTrophyImagesDir.path, path.basename(file.absolute.path));
  //       final filecore = path.withoutExtension(filename);
  //       final filetype = path.extension(filename);

  //       final reduced = createReducedOpacityTrophyIcon(im, opacity: 199);
  //       File("$filecore-opportunity$filetype").writeAsBytes(encodePng(reduced));

  //       if (mark != null) {
  //         final xpos = im.width - mark.width;
  //         final ypos = im.height - mark.height;
  //         final img = drawImage(reduced, mark, dstX: xpos, dstY: ypos);
  //         await File("$filecore-locked$filetype").writeAsBytes(encodePng(img));
  //       }

  //       await origImage.copy(path.join(
  //           cacheTrophyImagesDir.path, path.basename(file.absolute.path)));
  //     }

  //     await for (var dir in colImagesDir.list()) {
  //       await recurse(dir);
  //     }
  //   }
  // }

  void completeRefreshingShareData(shares) {
    List<Map<String, dynamic>> matchingshares = [];

    for (var s in shares) {
      if (s["other_username"] == config.matrixUsername &&
          s["subscribed"] == "True") {
        matchingshares.add({
          'name': s["name"],
          'share-id': s["volume_id"],
        });
      }
    }

    if (matchingshares.isEmpty || matchingshares.length > 1) {
      stdout.writeln("Could not find unique active share.");
      shareFound = false;
    } else {
      shareName = matchingshares[0]['name'];
      shareID = matchingshares[0]['share-id'];
      shareFound = true;
    }
  }

  String getShareName() {
    if (shareFound) {
      return shareName ?? "";
    }
    return "";
  }

  String getShareID() {
    if (shareFound) {
      return shareID ?? "";
    }
    return "";
  }

  void publishTrophiesOnline() {
    throw UnimplementedError();
  }

  void unpublishTrophiesOnline() {
    throw UnimplementedError();
  }

  Future<List<Map<String, dynamic>>> getAllExtraInformation() async {
    final accoms = listAccoms();

    final List<Map<String, dynamic>> infoneeded = [];

    final trophyextrainfo =
        Directory(path.join(config.trophiesPath, ".extrainformation"));
    if (!await trophyextrainfo.exists()) {
      await trophyextrainfo.create(recursive: true);
    }

    for (var accom in accoms) {
      var collection = collFromAccomID(accom);

      var ei = getAccomNeedsInfo(accom);
      if (ei.isNotEmpty) {
        for (var i in ei) {
          var label =
              accomDB.collections[collection]?.extraInformation[i]?.label;
          var desc =
              accomDB.collections[collection]?.extraInformation[i]?.description;
          var example =
              accomDB.collections[collection]?.extraInformation[i]?.example;
          var regex = accomDB
              .collections[collection]?.extraInformation[i]?.regex?.value;

          String? value;
          var valuefile = File(path.join(trophyextrainfo.path, i));
          if (await valuefile.exists() && (await valuefile.stat()).size > 0) {
            var valuedata = (await valuefile.readAsLines());
            if (valuedata.isNotEmpty) {
              value = valuedata.first;
            }
          }

          infoneeded.add({
            'collection': collection,
            'needs-information': i,
            'label': label,
            'description': desc,
            'example': example,
            'regex': regex,
            'value': value,
          });
        }
      }
    }

    final List<Map<String, dynamic>> result = [];
    for (var x in infoneeded) {
      if (!result.contains(x)) {
        result.add(x);
      }
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllExtraInformationRequired() async {
    final data = await getAllExtraInformation();
    List<Map<String, dynamic>> result = [];

    for (var i in data) {
      if (i['value'] == null || i['value'] == '') {
        result.add(i);
      }
    }

    return result;
  }

  void createExtraInformationFile(String item, String data) async {
    stdout.writeln("Creating Extra Information file: $item");
    final extrainfodir =
        Directory(path.join(config.trophiesPath, ".extrainformation"));

    if (!await extrainfodir.exists()) {
      await extrainfodir.create(recursive: true);
    }

    final extrainfofile = File(path.join(extrainfodir.path, item));
    if (!await extrainfofile.exists()) {
      await extrainfofile.writeAsString(data);
    }
  }

  Future<void> processValidTrophyReceived(String trophy) async {
    stdout.writeln("Valid trophy received...");
    String accomID;
    if (trophy.endsWith(".asc")) {
      accomID =
          trophy.substring(config.trophiesPath.length + 1, trophy.length - 11);
      displayAccomplishedBubble(accomID);
      displayUnlockedBubble(accomID);
    } else {
      accomID =
          trophy.substring(config.trophiesPath.length + 1, trophy.length - 7);
    }
    final justUnlocked = await markAsAccomplished(accomID);
    service.trophyReceived(accomID);
    runScripts(justUnlocked);
  }

  Future<void> processReceivedTrophyFile(String trophy) async {
    stdout.writeln("Trophy file received: validating...");

    if (trophy.startsWith(config.trophiesPath)) {
      if (trophy.endsWith(".asc")) {
        stdout.writeln("Processing signature: $trophy");
        final valid = await getIsAscCorrect(trophy);
        if (valid) {
          processValidTrophyReceived(trophy);
        } else {
          stdout.writeln("Invalid .asc signature received from the server!");
        }
      } else {
        stdout.writeln("Processing unsigned trophy: $trophy");
        if (getAccomNeedsSigning(path.basenameWithoutExtension(trophy))) {
          stdout.writeln("Trophy needs signing, skipping");
        } else {
          processValidTrophyReceived(trophy);
        }
      }
    }
  }

  Future<void> writeExtraInformationFile(String item, String? data) async {
    stdout.writeln("Saving Extra Information file: $item, $data");
    if (item == "launchpad-email" && data != null && data != "") {
      await accomplish("ubuntu-desktop/accomplishments-edit-credentials");
    }
    final extrainfodir =
        Directory(path.join(config.trophiesPath, ".extrainformation"));

    if (!await extrainfodir.exists()) {
      await extrainfodir.create(recursive: true);
    }

    final extrainfofile = File(path.join(extrainfodir.path, item));
    if (data != null && data != "") {
      await extrainfofile.writeAsString(data);
    } else if (await extrainfofile.exists()) {
      await extrainfofile.delete();
    }
  }

  Future<bool> isAllExtraInformationAvailable(String accomID) async {
    final infoReqd = getAccomNeedsInfo(accomID);
    if (infoReqd.isEmpty) {
      return true;
    }

    final collection = collFromAccomID(accomID);
    if (collection == "") {
      return false;
    }

    for (var info in infoReqd) {
      final ei = await getExtraInformation(collection, info);
      if (ei['item'] == null || ei['item'] == "") {
        stdout.writeln(
            "$info is missing for $accomID, is_all_extra_information_available returning False");
        return false;
      }
    }

    return true;
  }

  void invalidateExtraInformation() {
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> getExtraInformation(
      String collection, String item) async {
    final extrainfopath = path.join(config.trophiesPath, ".extrainformation");
    final authfilepath = path.join(extrainfopath, item);

    if (!getCollectionExists(collection)) {
      stdout.writeln("No such collection: $collection");
      return {};
    }

    final label =
        accomDB.collections[collection]?.extraInformation[item]?.label;

    final authfile = File(authfilepath);
    if (await authfile.exists()) {
      final data = await authfile.readAsString();
      return {'item': data, 'id': item, 'label': label};
    }
    return {'item': "", 'id': item, 'label': label};
  }

  Future<void> reloadAccomDatabase() async {
    accomDB = AccomDB();
    final installpaths = config.accomsInstallpaths.split(":");
    for (var installpath in installpaths) {
      stdout.writeln('Scanning for collections in $installpath');

      final dir = Directory(path.join(installpath, 'accomplishments'));
      if (!await dir.exists()) {
        continue;
      }

      final collections = dir.list();
      for (var element in await collections.toList()) {
        final collection = path.basename(element.path);

        stdout.writeln('Found collection $collection');

        final collpath = path.join(dir.path, collection);
        final aboutpath = path.join(collpath, 'ABOUT');

        final data = await File(aboutpath).readAsString();
        final meta = CollectionMeta.fromJson(jsonDecode(data));

        if (meta.langdefault == null || meta.name == null) {
          stdout.writeln(aboutpath);
          throw "Accomplishment collection with invalid ABOUT file ";
        }

        final langdefault = meta.langdefault ?? "en";
        final collectionname = meta.name;

        Set<String> collauthors = {};
        Map<String, List<String>> collcategories = {};

        final langdefaultpath = path.join(collpath, langdefault);
        final setsslist = Directory(langdefaultpath).list();
        var accno = 0;

        for (var setssfile in await setsslist.toList()) {
          var accomset = path.basename(setssfile.path);
          if (path.extension(accomset) == '.accomplishment') {
            var accom = path.basenameWithoutExtension(accomset);
            stdout.writeln('Found accomplishment $collection/$accom');

            var accompath = path.join(langdefaultpath, accomset);
            var translatedpath =
                path.join(collpath, Intl.systemLocale, accomset);
            String readpath;
            String langused;
            if (await File(translatedpath).exists()) {
              readpath = translatedpath;
              langused = Intl.systemLocale;
            } else {
              translatedpath = path.join(
                  collpath, Intl.systemLocale.split("_")[0], accomset);
              if (await File(translatedpath).exists()) {
                readpath = translatedpath;
                langused = Intl.systemLocale.split("_")[0];
              } else {
                readpath = accompath;
                langused = langdefault;
              }
            }

            var data = await File(readpath).readAsString();
            var accomplishment = Accomplishment.fromJson(jsonDecode(data));

            var accomID = "$collection/$accom";
            accomplishment.id = accomID;

            var author = accomplishment.author;
            if (author != "") {
              collauthors.add(author);
            }

            accomplishment.set = "";
            accomplishment.collection = collection;
            accomplishment.lang = langused;
            accomplishment.basePath = collpath;
            accomplishment.scriptPath = path.join(
                installpath,
                'scripts',
                collection,
                "${accomset.substring(0, accomset.length - 15)}.py");
            accomplishment.iconPath =
                path.join(collpath, 'trophyimages', accomplishment.icon);

            List<String> cats = accomplishment.category.split(",");
            for (var cat in cats) {
              var catsplitted = cat.trim().split(":");
              accomplishment.categories.add(cat.trim());
              if (collcategories.containsValue(catsplitted[0])) {
                continue;
              }
              collcategories[catsplitted[0]] = [];
              if (catsplitted.length > 1) {
                if (!(collcategories[catsplitted[0]]
                        ?.contains(catsplitted[1]) ??
                    true)) {
                  collcategories[catsplitted[0]]?.add(catsplitted[1]);
                }
              }
            }

            accomDB.accomplishments[accomID] = accomplishment;
            accno = accno + 1;
          } else {
            var setID = "$collection:$accomset";
            stdout.writeln('Found accomplishment set $setID');

            var setdata = {'type': "set", 'name': accomset};
            accomDB.sets[setID] = setdata;
            var setdir = path.join(langdefaultpath, accomset);
            var accomfiles = Directory(setdir).list();
            for (var element in await accomfiles.toList()) {
              var accom = path.basenameWithoutExtension(element.path);
              var accomID = "$collection/$accom";
              stdout.writeln('Found accomplishment: $setID/$accom ($accomID)');

              var accomfile = path.basename(element.path);
              var accompath = path.join(langdefaultpath, accomset, accomfile);
              var translatedpath =
                  path.join(collpath, Intl.systemLocale, accomset, accomfile);
              var readpath = "";
              var langused = "";
              if (await File(translatedpath).exists()) {
                readpath = translatedpath;
                langused = Intl.systemLocale;
              } else {
                translatedpath = path.join(collpath,
                    Intl.systemLocale.split("_")[0], accomset, accomfile);
                if (await File(translatedpath).exists()) {
                  readpath = translatedpath;
                  langused = Intl.systemLocale.split("_")[0];
                } else {
                  readpath = accompath;
                  langused = langdefault;
                }
              }
              var data = await File(readpath).readAsString();
              var accomplishment = Accomplishment.fromJson(jsonDecode(data));

              accomplishment.id = accomID;

              if (accomplishment.author != "") {
                collauthors.add(accomplishment.author);
              }
              accomplishment.set = accomset;
              accomplishment.collection = collection;
              accomplishment.lang = langused;
              accomplishment.basePath = collpath;
              accomplishment.scriptPath = path.join(
                  installpath,
                  'scripts',
                  collection,
                  accomset,
                  "${accomfile.substring(0, accomfile.length - 15)}.py");
              accomplishment.iconPath =
                  path.join(collpath, 'trophyimages', accomplishment.icon);

              if (accomplishment.category != "") {
                String accomcategory = accomplishment.category;
                var cats =
                    accomcategory.split(",").map<String>((c) => c.trim());
                accomplishment.categories = cats.toList();
                for (var cat in cats) {
                  var catsplitted = cat.trim().split(":");
                  if (collcategories.containsValue(catsplitted[0])) {
                    continue;
                  }
                  collcategories[catsplitted[0]] = [];
                  if (catsplitted.length > 1) {
                    if (!(collcategories[catsplitted[0]]
                            ?.contains(catsplitted[1]) ??
                        true)) {
                      collcategories[catsplitted[0]]?.add(catsplitted[1]);
                    }
                  }
                }
              } else {
                accomplishment.categories = [];
              }
              accomDB.accomplishments[accomID] = accomplishment;
              accno = accno + 1;
            }
          }
        }

        var extrainfodir = path.join(collpath, "extrainformation");
        var extrainfolist = Directory(extrainfodir).list();
        Map<String, Map<String, dynamic>> ei = {};
        for (var element in await extrainfolist.toList()) {
          var extrainfofile = path.basename(element.path);
          var extrainfopath = path.join(extrainfodir, extrainfofile);
          var data = await File(extrainfopath).readAsString();
          ei[extrainfofile] = jsonDecode(data);
        }

        accomDB.collections[collection] = Collection.fromJson({
          'langdefault': langdefault,
          'name': collectionname,
          'acc_num': accno,
          'base-path': collpath,
          'categories': collcategories,
          'extra-information': ei,
          'authors': collauthors.toList()
        });
      }
    }

    stdout.writeln('Finished scanning for accomplishments');

    await updateAllLockedAndAccomplishedStatuses();

    if (!testMode) {
      service.accomsCollectionsReloaded();
    }
  }

  Map<String, dynamic> getAccomData(String accomID) =>
      accomDB.accomplishments[accomID]?.toJson() ?? {};

  bool getAccomExists(String accomID) =>
      accomDB.accomplishments.containsKey(accomID);

  String getAccomTitle(String accomID) =>
      accomDB.accomplishments[accomID]?.title ?? '';

  String getAccomDescription(String accomID) =>
      accomDB.accomplishments[accomID]?.description ?? '';

  Iterable<String> getAccomKeywords(String accomID) =>
      accomDB.accomplishments[accomID]?.keywords
          .split(",")
          .map((String a) => a.trim()) ??
      [""];

  bool getAccomNeedsSigning(String accomID) =>
      accomDB.accomplishments[accomID]?.needsSigning ?? true;

  Iterable<String> getAccomDepends(String accomID) =>
      (accomDB.accomplishments[accomID]?.depends
                  .split(",")
                  .map((String a) => a.trim()) ??
              [])
          .where((dependency) => dependency != "");

  bool getAccomIsUnlocked(String accomID) =>
      !(accomDB.accomplishments[accomID]?.locked ?? false);

  String getTrophyPath(String accomID) {
    if (!getAccomExists(accomID)) {
      return "";
    }
    return path.join(config.trophiesPath, "$accomID.trophy");
  }

  bool getAccomIsAccomplished(String accomID) =>
      accomDB.accomplishments[accomID]?.accomplished ?? false;

  String? getAccomScriptPath(String accomID) {
    final res = accomDB.accomplishments[accomID]?.scriptPath;
    if (res != null && File(res).existsSync()) {
      return res;
    }
  }

  String getAccomIcon(String accomID) =>
      accomDB.accomplishments[accomID]?.icon ?? '';

  String getAccomIconPath(String accomID) {
    final accom = accomDB.accomplishments[accomID];
    if (accom == null) {
      return '';
    }
    return path.join(accom.basePath, 'trophyimages', accom.icon);
  }

  List<String> getAccomNeedsInfo(String accomID) {
    final needinfo = accomDB.accomplishments[accomID]?.needsInformation;
    if (needinfo == null || needinfo == "") {
      return [];
    }
    return needinfo.split(",").map((String a) => a.trim()).toList();
  }

  String getAccomCollection(String accomID) =>
      accomDB.accomplishments[accomID]?.collection ?? '';

  List<String> getAccomCategories(String accomID) =>
      accomDB.accomplishments[accomID]?.categories ?? [];

  String getAccomDateAccomplished(String accomID) =>
      accomDB.accomplishments[accomID]?.dateAccomplished ?? '';

  Future<Map<String, String>> getTrophyData(String accomID) async {
    if (getAccomIsAccomplished(accomID)) {
      final data = await File(getTrophyPath(accomID)).readAsString();
      return jsonDecode(data);
    }
    return {};
  }

  String getCollectionName(String collection) =>
      accomDB.collections[collection]?.name ?? '';

  bool getCollectionExists(String collection) =>
      listCollections().contains(collection);

  List<String> getCollectionAuthors(String collection) =>
      accomDB.collections[collection]?.authors ?? [];

  Iterable<String> getCollectionCategories(String collection) =>
      accomDB.collections[collection]?.categories.keys ?? [];

  Map<String, dynamic> getCollectionData(String collection) =>
      accomDB.collections[collection]?.toJson() ?? {};

  List<String> listAccoms() => accomslist();

  List<String> listTrophies() =>
      accomslist().where((accom) => getAccomIsAccomplished(accom)).toList();

  List<String> listOpportunities() =>
      accomslist().where((accom) => !getAccomIsAccomplished(accom)).toList();

  List<String> listDependingOn(String accomID) => accomslist()
      .where((accom) => getAccomDepends(accom).contains(accomID))
      .toList();

  List<String> listUnlocked() =>
      accomslist().where((accom) => getAccomIsUnlocked(accom)).toList();

  List<String> listUnlockedNotAccomplished() {
    final accoms = accomslist();
    final filtered = accoms.where(
        (accom) => getAccomIsUnlocked(accom) && !getAccomIsAccomplished(accom));
    return filtered.toList();
  }

  List<String> listCollections() => collslist();

  void runScript(String accomID) {
    if (getAccomExists(accomID)) {
      runScripts([accomID]);
    }
  }

  Future<void> runScripts(List<String> which) async {
    List<String> toSchedule;
    if (which.isEmpty || (which.length == 1 && which[0] == "all")) {
      toSchedule = listUnlockedNotAccomplished();
    } else {
      toSchedule = which;
    }

    if (toSchedule.isEmpty) {
      stdout.writeln(
          "No scripts to run, returning without starting scriptrunner");
      return;
    }

    stdout.writeln("Adding to scripts queue: ${toSchedule.join(', ')}");
    for (var i in toSchedule) {
      if (!scriptsRunner.scriptsQueue.contains(i)) {
        scriptsRunner.scriptsQueue.add(i);
      }
    }
    await scriptsRunner.startScriptRunner();
    await checkSignatures();
  }

  Future<List<Map<String, dynamic>>> buildViewerDatabase() async {
    final accoms = listAccoms();
    List<Map<String, dynamic>> db = [];
    for (var accom in accoms) {
      db.add({
        'title': getAccomTitle(accom),
        'accomplished': getAccomIsAccomplished(accom),
        'locked': !getAccomIsUnlocked(accom),
        'date-accomplished': getAccomDateAccomplished(accom),
        'icon-path': getAccomIconPath(accom),
        'collection': getAccomCollection(accom),
        'collectionhuman': getCollectionName(getAccomCollection(accom)),
        'categories': getAccomCategories(accom),
        'keywords': getAccomKeywords(accom),
        'id': accom,
      });
    }
    return db;
  }

  Future<void> checkSignatures() async {
    stdout.writeln('Checking for required trophy signatures');
    for (var accomID in accomDB.accomplishments.keys) {
      final accomFile = File(path.join(config.trophiesPath, '$accomID.trophy'));
      final accomAscFile = File('${accomFile.path}.asc');
      if (getAccomNeedsSigning(accomID) && (await accomFile.exists())) {
        final ascExists = await accomAscFile.exists();
        if (ascExists && await getIsAscCorrect(accomAscFile.path)) {
          continue;
        }
        if (ascExists) {
          await accomAscFile.delete();
        }

        stdout.writeln(
            'Requesting signature from accomplishments service for $accomID');
        final response = await http.post(
          Uri.parse(
              'https://ubuntuaccomplishments.herokuapp.com/accomplish/$accomID'),
          body: await accomFile.readAsString(),
        );

        await accomAscFile.writeAsString(response.body);

        await processReceivedTrophyFile(accomAscFile.path);
      }
    }
    stdout.writeln('Trophy signatures check has completed');
  }

  Future<bool> getPublishedStatus() async {
    final trophydir = await config.getConfigValue("trophypath") as String?;
    if (trophydir != null &&
        File(path.join(trophydir, "WEBVIEW")).existsSync()) {
      return true;
    }
    return false;
  }

  Future<bool> accomplish(String accomID) async {
    stdout.writeln("Accomplishing: $accomID");
    if (!getAccomExists(accomID)) {
      stdout.writeln("There is no such accomplishment.");
      return false;
    }

    if (getAccomIsAccomplished(accomID)) {
      stdout.writeln(
          "Not accomplishing $accomID, it has already been accomplished.");
      return true;
    }

    if (!getAccomIsUnlocked(accomID)) {
      stdout
          .writeln("This accomplishment cannot be accomplished; it's locked.");
      return false;
    }

    createTrophyFile(accomID);

    if (!getAccomNeedsSigning(accomID)) {
      if (!testMode) {
        service.trophyReceived(accomID);
      }
      displayAccomplishedBubble(accomID);
      displayUnlockedBubble(accomID);
      final justUnlocked = await markAsAccomplished(accomID);
      runScripts(justUnlocked);
    }

    return true;
  }

  registerTrophyDir(String trophydirpath) async {
    final trophydir = File(trophydirpath);
    if (!await trophydir.exists()) {
      trophydir.create(recursive: true);
    }

    return;
  }

  Future<void> createTrophyFile(String accomID) async {
    final trophypath = getTrophyPath(accomID);

    final needssigning = getAccomNeedsSigning(accomID);
    final needsinfo = getAccomNeedsInfo(accomID);
    final collection = getAccomCollection(accomID);

    var overwrite = true;

    if (needssigning && File(trophypath).existsSync()) {
      overwrite = false;

      final data = await File(trophypath).readAsString();
      Map<String, dynamic> cfg = jsonDecode(data);

      if (needsinfo.isNotEmpty) {
        for (var i in needsinfo) {
          final extinfo = await getExtraInformation(collection, i);
          if (!(cfg[i].trim() == extinfo['item'].trim())) {
            overwrite = true;
            stdout.writeln(
                "Trophy file $trophypath already exists, but contains different extra-information.");
            break;
          }
        }
      }
    }

    if (!overwrite) {
      stdout.writeln("Not overwriting $trophypath as it already exists.");
      return;
    }

    Map<String, dynamic> trophy = {};
    trophy['version'] = '0.2';
    trophy['id'] = accomID;
    final now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    trophy['date-accomplished'] = formatter.format(now);
    if (needssigning) {
      trophy['needs-signing'] = needssigning.toString();
    }
    if (needsinfo.isNotEmpty) {
      trophy['needs-information'] = needsinfo.join(', ');
      for (var i in needsinfo) {
        final info = await getExtraInformation(collection, i);
        trophy[i] = info['item'];
      }
    }
    final dir = Directory(path.dirname(trophypath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    stdout.writeln("Writing to trophy file at $trophypath");
    File(trophypath).writeAsString(jsonEncode(trophy));
  }

  void setDaemonSessionStart(bool value) {
    throw UnimplementedError();
  }

  Future<bool> getDaemonSessionStart() async {
    return await config.getConfigValue('daemon_sessionstart') as bool;
  }

  String collFromAccomID(accomID) {
    return accomID.split('/')[0];
  }

  void displayAccomplishedBubble(accomID) {
    if (config.showNotifications) {
      final accomName = getAccomTitle(accomID);
      notify("You've achieved a new accomplishment for $accomName!");
    }
  }

  void displayUnlockedBubble(accomID) {
    final unlocked = listDependingOn(accomID).length;
    if (unlocked != 0) {
      if (config.showNotifications) {
        notify("New opportunities have been unlocked!");
      }
    }
  }

  List<String> accomslist() => accomDB.accomplishments.keys.toList();

  List<String> collslist() => accomDB.collections.keys.toList();

  Future<bool> getIsAscCorrect(String filepath) async {
    final file = File(filepath);
    if (!await file.exists()) {
      stdout.writeln(
          "Cannot check if signature is correct, because file $filepath does not exist");
      return false;
    }
    final trophypath = filepath.substring(0, filepath.length - 4);
    final trophyfile = File(trophypath);
    if (!await trophyfile.exists()) {
      stdout.writeln(
          "Cannot check if signature is correct, because file $trophypath does not exist");
      return false;
    }
    final signed = await file.readAsString();
    final plaintext = await trophyfile.readAsString();
    return signer?.verify64(plaintext, signed) ?? false;
  }

  Future<bool> checkIfAccomIsAccomplished(String accomID) async {
    final trophypath = getTrophyPath(accomID);
    final trophyfile = File(trophypath);
    if (!await trophyfile.exists()) {
      return false;
    }
    if (!getAccomNeedsSigning(accomID)) {
      return true;
    }
    final ascpath = "$trophypath.asc";
    if (!await File(ascpath).exists()) {
      return false;
    }
    return getIsAscCorrect(ascpath);
  }

  bool checkIfAccomIsLocked(String accomID) {
    final dep = getAccomDepends(accomID);
    if (dep.isEmpty) {
      stdout.writeln('Accomplishment $accomID is unlocked');
      return false;
    }
    var locked = false;
    for (var d in dep) {
      if (!getAccomIsAccomplished(d)) {
        locked = true;
      }
    }
    if (locked) {
      stdout.writeln(
          'Accomplishment $accomID is locked because it depends on ${dep.join(',')}');
      return true;
    } else {
      stdout.writeln('Accomplishment $accomID is unlocked');
      return false;
    }
  }

  Future<void> updateAllLockedAndAccomplishedStatuses() async {
    final accoms = listAccoms();
    for (var accom in accoms) {
      final accomplished = await checkIfAccomIsAccomplished(accom);
      accomDB.accomplishments[accom]?.accomplished = accomplished;
      if (accomplished) {
        accomDB.accomplishments[accom]?.dateAccomplished =
            await getTrophyDateAccomplished(accom);
      } else {
        accomDB.accomplishments[accom]?.dateAccomplished = "None";
      }
      accomDB.accomplishments[accom]?.locked = checkIfAccomIsLocked(accom);
    }
  }

  Future<String> getTrophyDateAccomplished(String accomID) async {
    final trophypath = getTrophyPath(accomID);
    final trophyfile = File(trophypath);
    if (!await trophyfile.exists()) {
      return '';
    }

    final data = await trophyfile.readAsString();
    if (data.trim().isEmpty) {
      return '';
    }

    final trophy = Accomplishment.fromJson(jsonDecode(data));
    return trophy.dateAccomplished;
  }

  Future<List<String>> markAsAccomplished(String accomID) async {
    accomDB.accomplishments[accomID]?.accomplished = true;
    accomDB.accomplishments[accomID]?.dateAccomplished =
        await getTrophyDateAccomplished(accomID);
    final accoms = listDependingOn(accomID);
    List<String> res = [];
    for (var accom in accoms) {
      final before = accomDB.accomplishments[accom]?.locked ?? true;
      accomDB.accomplishments[accom]?.locked = checkIfAccomIsLocked(accom);
      if (before && !(accomDB.accomplishments[accom]?.locked ?? true)) {
        res.add(accom);
      }
    }
    return res;
  }

  String getAPIVersion() => '0.2';

  void stopDaemon() {
    throw UnimplementedError();
  }
}
