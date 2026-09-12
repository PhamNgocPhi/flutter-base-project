import '../../../../core/error/result.dart';
import '../entities/example.dart';

abstract interface class ExampleRepository {
  Future<Result<List<Example>>> getExamples();
}
