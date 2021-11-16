import 'package:json_annotation/json_annotation.dart';

import 'regex_value.dart';

/// This allows the `Trophy` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'extra_information.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab)
class ExtraInformation {
  ExtraInformation();

  @JsonKey(defaultValue: {})
  Map<String, String> description = {};
  @JsonKey(defaultValue: {})
  Map<String, String> example = {};
  @JsonKey(defaultValue: "")
  String item = "";
  @JsonKey(defaultValue: {})
  Map<String, String> label = {};
  RegexValue? regex;

  factory ExtraInformation.fromJson(Map<String, dynamic> json) =>
      _$ExtraInformationFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraInformationToJson(this);
}
