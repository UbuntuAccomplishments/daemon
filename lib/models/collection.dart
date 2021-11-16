import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';
import 'extra_information.dart';

/// This allows the `Trophy` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'collection.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab, explicitToJson: true)
class Collection {
  Collection();

  @JsonKey(defaultValue: "")
  String basePath = "";
  @JsonKey(defaultValue: "")
  String langdefault = "";
  @JsonKey(defaultValue: "")
  String name = "";
  @JsonKey(defaultValue: {})
  Map<String, ExtraInformation> extraInformation = {};
  @JsonKey(defaultValue: "")
  String scriptPath = "";
  @JsonKey(defaultValue: "")
  String icon = "";
  @JsonKey(defaultValue: 0)
  // ignore: non_constant_identifier_names
  int acc_num = 0;
  @JsonKey(defaultValue: {})
  Map<String, List<String>> categories = {};
  @JsonKey(defaultValue: [])
  List<String> authors = [];
  @JsonKey(fromJson: truthy, defaultValue: false)
  bool accomplished = false;

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);
}
