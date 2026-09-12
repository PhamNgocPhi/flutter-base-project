import '../../../../core/error/result.dart';
import '../../domain/entities/example.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_remote_datasource.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  const ExampleRepositoryImpl(this._remote);
  final ExampleRemoteDataSource _remote;

  @override
  Future<Result<List<Example>>> getExamples() => guard(() async {
        final dtos = await _remote.fetchExamples();
        return dtos.map((d) => d.toEntity()).toList();
      });
}
