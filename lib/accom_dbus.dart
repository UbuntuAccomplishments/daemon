import 'package:dbus/dbus.dart';

import 'api.dart';

const endpointsNeedingArgs = [
  'write_config_file_item',
  'get_config_value',
  'register_trophy_dir',
  'create_extra_information_file',
  'write_extra_information_file',
  'get_extra_information',
  'run_script',
  'get_accom_data',
  'get_accom_exists',
  'get_accom_title',
  'get_accom_description',
  'get_accom_collection',
  'get_accom_categories',
  'get_accom_keywords',
  'get_accom_needs_signing',
  'get_accom_depends',
  'get_accom_is_unlocked',
  'get_trophy_path',
  'get_accom_is_accomplished',
  'get_accom_script_path',
  'get_accom_icon',
  'get_accom_icon_path',
  'get_accom_needs_info',
  'get_trophy_data',
  'get_collection_name',
  'get_collection_exists',
  'get_collection_authors',
  'get_collection_categories',
  'get_collection_data',
  'list_depending_on',
];

class AccomDBus extends DBusObject {
  late final Accomplishments api;

  AccomDBus() : super(DBusObjectPath('/org/ubuntu/Accomplishments')) {
    api = Accomplishments(this);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    final trophyReceivedSignal = DBusIntrospectSignal('trophy_received');

    final testMethod = DBusIntrospectMethod('Test');
    final writeConfigFileItemMethod =
        DBusIntrospectMethod('write_config_file_item', args: [
      DBusIntrospectArgument(DBusSignature('vvv'), DBusArgumentDirection.in_),
    ]);
    final getConfigValueMethod =
        DBusIntrospectMethod('get_config_value', args: [
      DBusIntrospectArgument(DBusSignature('vv'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('v'), DBusArgumentDirection.out),
    ]);
    final registerTrophyDirMethod =
        DBusIntrospectMethod('register_trophy_dir', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out),
    ]);
    final createExtraInformationFileMethod =
        DBusIntrospectMethod('create_extra_information_file', args: [
      DBusIntrospectArgument(DBusSignature('ss'), DBusArgumentDirection.in_),
    ]);
    final writeExtraInformationFileMethod =
        DBusIntrospectMethod('write_extra_information_file', args: [
      DBusIntrospectArgument(DBusSignature('ss'), DBusArgumentDirection.in_),
    ]);
    final invalidateExtraInformationMethod =
        DBusIntrospectMethod('invalidate_extra_information', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_)
    ]);
    final getExtraInformationRequiredMethod =
        DBusIntrospectMethod('get_all_extra_information_required', args: [
      DBusIntrospectArgument(
          DBusSignature('aa{sv}'), DBusArgumentDirection.out),
    ]);
    final getAllExtraInformationMethod =
        DBusIntrospectMethod('get_all_extra_information', args: [
      DBusIntrospectArgument(
          DBusSignature('aa{sv}'), DBusArgumentDirection.out),
    ]);
    final getExtraInformationMethod =
        DBusIntrospectMethod('get_extra_information', args: [
      DBusIntrospectArgument(DBusSignature('ss'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('sv'), DBusArgumentDirection.out),
    ]);
    final runScriptsMethod = DBusIntrospectMethod('run_scripts', args: [
      DBusIntrospectArgument(DBusSignature('v'), DBusArgumentDirection.in_)
    ]);
    final runScriptMethod = DBusIntrospectMethod('run_script', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_)
    ]);
    final accomplishMethod = DBusIntrospectMethod('accomplish', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
    ]);
    final reloadAccomDatabaseMethod =
        DBusIntrospectMethod('reload_accom_database');
    final getAccomDataMethod = DBusIntrospectMethod('get_accom_data', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('a{sv}'), DBusArgumentDirection.out),
    ]);
    final getAccomExistsMethod =
        DBusIntrospectMethod('get_accom_exists', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out),
    ]);
    final getAccomTitleMethod = DBusIntrospectMethod('get_accom_title', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getAccomDescriptionMethod =
        DBusIntrospectMethod('get_accom_description', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getAccomCollectionMethod =
        DBusIntrospectMethod('get_accom_collection', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getAccomCategoriesMethod =
        DBusIntrospectMethod('get_accom_categories', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final getAccomKeywordsMethod =
        DBusIntrospectMethod('get_accom_keywords', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final getAccomNeedsSigningMethod =
        DBusIntrospectMethod('get_accom_needs_signing', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out),
    ]);
    final getAccomDependsMethod =
        DBusIntrospectMethod('get_accom_depends', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final getAccomIsUnlockedMethod =
        DBusIntrospectMethod('get_accom_is_unlocked', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out),
    ]);
    final getTrophyPathMethod = DBusIntrospectMethod('get_trophy_path', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getAccomIsAccomplished =
        DBusIntrospectMethod('get_accom_is_accomplished', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out),
    ]);
    final getPublishedStatusMethod =
        DBusIntrospectMethod('get_published_status', args: [
      DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out),
    ]);
    final getAccomScriptPathMethod =
        DBusIntrospectMethod('get_accom_script_path', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getAccomIconMethod = DBusIntrospectMethod('get_accom_icon', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getAccomIconPathMethod =
        DBusIntrospectMethod('get_accom_icon_path', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getAccomNeedsInfoMethod =
        DBusIntrospectMethod('get_accom_needs_info', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('v'), DBusArgumentDirection.out),
    ]);
    final getTrophyDataMethod = DBusIntrospectMethod('get_trophy_data', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('a{sv}'), DBusArgumentDirection.out),
    ]);
    final getCollectionNameMethod =
        DBusIntrospectMethod('get_collection_name', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getCollectionExistsMethod =
        DBusIntrospectMethod('get_collection_exists', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out),
    ]);
    final getCollectionAuthorsMethod =
        DBusIntrospectMethod('get_collection_authors', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final getCollectionCategoriesMethod =
        DBusIntrospectMethod('get_collection_categories', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(
          DBusSignature('a{sas}'), DBusArgumentDirection.out),
    ]);
    final getCollectionDataMethod =
        DBusIntrospectMethod('get_collection_data', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('v'), DBusArgumentDirection.out),
    ]);
    final listAccomsMethod = DBusIntrospectMethod('list_accoms', args: [
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final listTrophiesMethod = DBusIntrospectMethod('list_trophies', args: [
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final listOpportunitiesMethod =
        DBusIntrospectMethod('list_opportunities', args: [
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final listDependingOnMethod =
        DBusIntrospectMethod('list_depending_on', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_),
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final listUnlockedMethod = DBusIntrospectMethod('list_unlocked', args: [
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final listUnlockedNotCompletedMethod =
        DBusIntrospectMethod('list_unlocked_not_completed', args: [
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final listCollectionsMethod =
        DBusIntrospectMethod('list_collections', args: [
      DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out),
    ]);
    final buildViewerDatabaseMethod =
        DBusIntrospectMethod('build_viewer_database', args: [
      DBusIntrospectArgument(
          DBusSignature('aa{sv}'), DBusArgumentDirection.out),
    ]);
    final getAPIVersionMethod = DBusIntrospectMethod('get_API_version', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final stopDaemonMethod = DBusIntrospectMethod('stop_daemon');
    final publishTrophiesOnlineMethod =
        DBusIntrospectMethod('publish_trophies_online');
    final unpublishTrophiesOnlineMethod =
        DBusIntrospectMethod('unpublish_trophies_online');
    final getShareIDMethod = DBusIntrospectMethod('get_share_id', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final getShareNameMethod = DBusIntrospectMethod('get_share_name', args: [
      DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out),
    ]);
    final createAllTrophyIconsMethod =
        DBusIntrospectMethod('create_all_trophy_icons');

    return [
      DBusIntrospectInterface('org.ubuntu.Accomplishments', methods: [
        testMethod,
        writeConfigFileItemMethod,
        getConfigValueMethod,
        registerTrophyDirMethod,
        createExtraInformationFileMethod,
        writeExtraInformationFileMethod,
        invalidateExtraInformationMethod,
        getExtraInformationRequiredMethod,
        getAllExtraInformationMethod,
        getExtraInformationMethod,
        runScriptsMethod,
        runScriptMethod,
        accomplishMethod,
        reloadAccomDatabaseMethod,
        getAccomDataMethod,
        getAccomExistsMethod,
        getAccomTitleMethod,
        getAccomDescriptionMethod,
        getAccomCollectionMethod,
        getAccomCategoriesMethod,
        getAccomKeywordsMethod,
        getAccomNeedsSigningMethod,
        getAccomDependsMethod,
        getAccomIsUnlockedMethod,
        getTrophyPathMethod,
        getAccomIsAccomplished,
        getPublishedStatusMethod,
        getAccomScriptPathMethod,
        getAccomIconMethod,
        getAccomIconPathMethod,
        getAccomNeedsInfoMethod,
        getTrophyDataMethod,
        getCollectionNameMethod,
        getCollectionExistsMethod,
        getCollectionAuthorsMethod,
        getCollectionCategoriesMethod,
        getCollectionDataMethod,
        listAccomsMethod,
        listTrophiesMethod,
        listOpportunitiesMethod,
        listDependingOnMethod,
        listUnlockedMethod,
        listUnlockedNotCompletedMethod,
        listCollectionsMethod,
        buildViewerDatabaseMethod,
        getAPIVersionMethod,
        stopDaemonMethod,
        publishTrophiesOnlineMethod,
        unpublishTrophiesOnlineMethod,
        getShareIDMethod,
        getShareNameMethod,
        createAllTrophyIconsMethod,
      ], properties: [], signals: [
        trophyReceivedSignal
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.ubuntu.Accomplishments') {
      if (endpointsNeedingArgs.contains(methodCall.name) &&
          methodCall.values.isEmpty) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      switch (methodCall.name) {
        case 'Test':
          return DBusMethodSuccessResponse([DBusString('Hello World!')]);
        case 'write_config_file_item':
          final section = methodCall.values[0].toNative();
          final item = methodCall.values[1].toNative();
          final value = methodCall.values[2].toNative();
          api.writeConfigFileItem(section, item, value);
          return DBusMethodSuccessResponse();
        case 'get_config_value':
          final section = methodCall.values[0].toNative();
          final item = methodCall.values[1].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(await api.getConfigValue(section, item))]);
        case 'register_trophy_dir':
          final trophydir = methodCall.values[0].toNative();
          api.registerTrophyDir(trophydir);
          return DBusMethodSuccessResponse();
        case 'create_extra_information_file':
          final item = methodCall.values[0].toNative();
          final data = methodCall.values[1].toNative();
          api.createExtraInformationFile(item, data);
          return DBusMethodSuccessResponse();
        case 'write_extra_information_file':
          final item = methodCall.values[0].toNative();
          final data = methodCall.values[1].toNative();
          await api.writeExtraInformationFile(item, data);
          return DBusMethodSuccessResponse();
        case 'invalidate_extra_information':
          // final extrainfo = methodCall.values[0].toNative();
          // api.invalidate_extra_information(extrainfo);
          return DBusMethodErrorResponse.notSupported();
        case 'get_all_extra_information_required':
          return DBusMethodSuccessResponse(
              [arrayValueMapper((await api.getAllExtraInformationRequired()))]);
        case 'get_all_extra_information':
          return DBusMethodSuccessResponse(
              [arrayValueMapper((await api.getAllExtraInformation()))]);
        case 'get_extra_information':
          final coll = methodCall.values[0].toNative();
          final item = methodCall.values[1].toNative();
          return DBusMethodSuccessResponse(
              [dictValueMapper(await api.getExtraInformation(coll, item))]);
        case 'run_scripts':
          List<String> accomIDlist = [];
          if (methodCall.values.length == 1) {
            accomIDlist = (methodCall.values[0] as DBusArray)
                .children
                .map<String>((item) => item.toNative())
                .toList();
          }
          api.runScripts(accomIDlist);
          return DBusMethodSuccessResponse();
        case 'run_script':
          final accomID = methodCall.values[0].toNative();
          api.runScript(accomID);
          return DBusMethodSuccessResponse();
        case 'reload_accom_database':
          await api.reloadAccomDatabase();
          return DBusMethodSuccessResponse();
        case 'get_accom_data':
          final accomID = methodCall.values[0].toNative();
          final data = api.getAccomData(accomID);
          return DBusMethodSuccessResponse([dictValueMapper(data)]);
        case 'get_accom_exists':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusBoolean(api.getAccomExists(accomID))]);
        case 'get_accom_title':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(api.getAccomTitle(accomID))]);
        case 'get_accom_description':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(api.getAccomDescription(accomID))]);
        case 'get_accom_collection':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(api.getAccomCollection(accomID))]);
        case 'get_accom_categories':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [arrayValueMapper(api.getAccomCategories(accomID))]);
        case 'get_accom_keywords':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [arrayValueMapper(api.getAccomKeywords(accomID))]);
        case 'get_accom_needs_signing':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusBoolean(api.getAccomNeedsSigning(accomID))]);
        case 'get_accom_depends':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [arrayValueMapper(api.getAccomDepends(accomID))]);
        case 'get_accom_is_unlocked':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusBoolean(api.getAccomIsUnlocked(accomID))]);
        case 'get_trophy_path':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(api.getTrophyPath(accomID))]);
        case 'get_accom_is_accomplished':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusBoolean(api.getAccomIsAccomplished(accomID))]);
        case 'get_published_status':
          return DBusMethodSuccessResponse(
              [DBusBoolean(await api.getPublishedStatus())]);
        case 'get_accom_script_path':
          final accomID = methodCall.values[0].toNative();
          final path = api.getAccomScriptPath(accomID);
          if (path == null) {
            return DBusMethodErrorResponse.failed();
          }
          return DBusMethodSuccessResponse([DBusString(path)]);
        case 'get_accom_icon':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(api.getAccomIcon(accomID))]);
        case 'get_accom_icon_path':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(api.getAccomIconPath(accomID))]);
        case 'get_accom_needs_info':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [arrayValueMapper(api.getAccomNeedsInfo(accomID))]);
        case 'get_trophy_data':
          final accomID = methodCall.values[0].toNative();
          final data = await api.getTrophyData(accomID);
          return DBusMethodSuccessResponse([dictValueMapper(data)]);
        case 'get_collection_name':
          final collection = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusString(api.getCollectionName(collection))]);
        case 'get_collection_exists':
          final collection = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [DBusBoolean(await api.getCollectionExists(collection))]);
        case 'get_collection_authors':
          final collection = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [arrayValueMapper(api.getCollectionAuthors(collection))]);
        case 'get_collection_categories':
          final collection = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [arrayValueMapper(api.getCollectionCategories(collection))]);
        case 'get_collection_data':
          final collection = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [dictValueMapper(api.getCollectionData(collection))]);
        case 'list_accoms':
          return DBusMethodSuccessResponse(
              [arrayValueMapper(await api.listAccoms())]);
        case 'list_trophies':
          return DBusMethodSuccessResponse(
              [arrayValueMapper(await api.listTrophies())]);
        case 'list_opportunities':
          return DBusMethodSuccessResponse(
              [arrayValueMapper<String>(await api.listOpportunities())]);
        case 'list_depending_on':
          final accomID = methodCall.values[0].toNative();
          return DBusMethodSuccessResponse(
              [arrayValueMapper(await api.listDependingOn(accomID))]);
        case 'list_unlocked':
          return DBusMethodSuccessResponse(
              [arrayValueMapper(await api.listUnlocked())]);
        case 'list_unlocked_not_completed':
          // return DBusMethodSuccessResponse(
          //     [arrayValueMapper(await api.list_unlocked_not_completed())]);
          return DBusMethodErrorResponse.notSupported();
        case 'list_collections':
          return DBusMethodSuccessResponse(
              [arrayValueMapper(await api.listCollections())]);
        case 'build_viewer_database':
          final data = await api.buildViewerDatabase();
          return DBusMethodSuccessResponse([arrayValueMapper(data)]);
        case 'get_API_version':
          return DBusMethodSuccessResponse([DBusString(api.getAPIVersion())]);
        case 'stop_daemon':
          return DBusMethodErrorResponse.notSupported();
        case 'publish_trophies_online':
          return DBusMethodErrorResponse.notSupported();
        case 'unpublish_trophies_online':
          return DBusMethodErrorResponse.notSupported();
        case 'get_share_id':
          return DBusMethodErrorResponse.notSupported();
        case 'get_share_name':
          return DBusMethodErrorResponse.notSupported();
        case 'create_all_trophy_icons':
          // await api.createAllTrophyIcons();
          return DBusMethodSuccessResponse();
        default:
          return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  DBusDict dictValueMapper(Map<dynamic, dynamic> i) {
    i.removeWhere((key, value) => value == null);
    return DBusDict(DBusSignature('s'), DBusSignature('v'), i.map((key, value) {
      if (value is String) {
        return MapEntry(DBusString(key), DBusVariant(DBusString(value)));
      }
      if (value is bool) {
        return MapEntry(DBusString(key), DBusVariant(DBusBoolean(value)));
      }
      if (value is Iterable<String>) {
        return MapEntry(
            DBusString(key),
            DBusVariant(DBusArray(
                DBusSignature('s'), value.map((s) => DBusString(s)))));
      }
      if (value is Map) {
        return MapEntry(DBusString(key), DBusVariant(dictValueMapper(value)));
      }
      throw DBusNotSupportedException(DBusMethodErrorResponse.notSupported());
    }));
  }

  DBusArray arrayValueMapper<T>(Iterable<T> list) {
    var sig = DBusSignature('s');
    if (list is Iterable<String>) {
      sig = DBusSignature('s');
      return DBusArray(sig, list.map((item) => DBusString(item as String)));
    }
    if (list is Iterable<Map<String, dynamic>>) {
      sig = DBusSignature('a{sv}');
      final listOfDict = list as Iterable<Map<String, dynamic>>;
      return DBusArray(sig, listOfDict.map(dictValueMapper));
    }
    throw DBusNotSupportedException(DBusMethodErrorResponse.notSupported());
  }

  void trophyReceived(String trophy) {
    client?.emitSignal(
        interface: 'org.ubuntu.Accomplishments',
        path: DBusObjectPath('/org/ubuntu/Accomplishments'),
        name: 'trophy_received',
        values: [DBusString(trophy)]);
  }

  void publishTrophiesOnlineCompleted(String url) {
    client?.emitSignal(
        interface: 'org.ubuntu.Accomplishments',
        path: DBusObjectPath('/org/ubuntu/Accomplishments'),
        name: 'publish_trophies_online_completed',
        values: [DBusString(url)]);
  }

  void scriptrunnerStart() {
    client?.emitSignal(
        interface: 'org.ubuntu.Accomplishments',
        path: DBusObjectPath('/org/ubuntu/Accomplishments'),
        name: 'scriptrunner_start');
  }

  void scriptrunnerFinish() {
    client?.emitSignal(
        interface: 'org.ubuntu.Accomplishments',
        path: DBusObjectPath('/org/ubuntu/Accomplishments'),
        name: 'scriptrunner_finish');
  }

  void accomsCollectionsReloaded() {
    client?.emitSignal(
        interface: 'org.ubuntu.Accomplishments',
        path: DBusObjectPath('/org/ubuntu/Accomplishments'),
        name: 'accoms_collections_reloaded');
  }
}
