import 'package:json_annotation/json_annotation.dart';

/// This allows the `Trophy` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'regex_value.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab)
class RegexValue {
  RegexValue();

  String? value;

  factory RegexValue.fromJson(Map<String, dynamic> json) =>
      _$RegexValueFromJson(json);

  Map<String, dynamic> toJson() => _$RegexValueToJson(this);
}
