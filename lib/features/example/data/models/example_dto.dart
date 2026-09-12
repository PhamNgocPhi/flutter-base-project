import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/example.dart';

part 'example_dto.freezed.dart';
part 'example_dto.g.dart';

@freezed
abstract class ExampleDto with _$ExampleDto {
  const ExampleDto._();

  const factory ExampleDto({
    required int id,
    required String title,
    @Default(false) bool completed,
  }) = _ExampleDto;

  factory ExampleDto.fromJson(Map<String, dynamic> json) =>
      _$ExampleDtoFromJson(json);

  Example toEntity() => Example(id: id, title: title);
}
