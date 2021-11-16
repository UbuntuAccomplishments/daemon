import 'package:json_annotation/json_annotation.dart';

/// This allows the `Trophy` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'collection_meta.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab)
class CollectionMeta {
  CollectionMeta();

  String? langdefault;
  String? name;

  factory CollectionMeta.fromJson(Map<String, dynamic> json) =>
      _$CollectionMetaFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionMetaToJson(this);
}
