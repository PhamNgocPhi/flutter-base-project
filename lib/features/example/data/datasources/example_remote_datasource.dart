import 'package:dio/dio.dart';

import '../models/example_dto.dart';

class ExampleRemoteDataSource {
  const ExampleRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<ExampleDto>> fetchExamples() async {
    // Demo dùng API public; thay bằng endpoint thật (baseUrl từ env).
    final res = await _dio.get<List<dynamic>>(
      'https://jsonplaceholder.typicode.com/todos',
      queryParameters: {'_limit': 20},
    );
    return (res.data ?? [])
        .map((e) => ExampleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
