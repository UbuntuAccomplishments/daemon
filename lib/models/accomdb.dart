import 'accomplishment.dart';
import 'collection.dart';

class AccomDB {
  AccomDB();

  Map<String, Accomplishment> accomplishments = {};
  Map<String, Collection> collections = {};
  Map<String, Map<String, String>> sets = {};
}
