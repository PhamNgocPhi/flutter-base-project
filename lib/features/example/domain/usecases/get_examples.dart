import '../../../../core/error/result.dart';
import '../entities/example.dart';
import '../repositories/example_repository.dart';

class GetExamples {
  const GetExamples(this._repo);
  final ExampleRepository _repo;

  Future<Result<List<Example>>> call() => _repo.getExamples();
}
