import 'package:bloc_test/bloc_test.dart';
import 'package:fluenary/core/error/failure.dart';
import 'package:fluenary/core/error/result.dart';
import 'package:fluenary/features/example/domain/entities/example.dart';
import 'package:fluenary/features/example/domain/usecases/get_examples.dart';
import 'package:fluenary/features/example/presentation/bloc/example_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetExamples extends Mock implements GetExamples {}

void main() {
  late _MockGetExamples getExamples;
  const items = [Example(id: 1, title: 'a')];

  setUp(() => getExamples = _MockGetExamples());

  group('ExampleBloc', () {
    blocTest<ExampleBloc, ExampleState>(
      'emits [Loading, Loaded] khi usecase thành công',
      build: () {
        when(() => getExamples()).thenAnswer((_) async => const Success(items));
        return ExampleBloc(getExamples);
      },
      act: (bloc) => bloc.add(const ExampleRequested()),
      expect: () => const [ExampleLoading(), ExampleLoaded(items)],
    );

    blocTest<ExampleBloc, ExampleState>(
      'emits [Loading, Failure] khi usecase lỗi',
      build: () {
        when(() => getExamples())
            .thenAnswer((_) async => const Error(NetworkFailure()));
        return ExampleBloc(getExamples);
      },
      act: (bloc) => bloc.add(const ExampleRequested()),
      expect: () => const [ExampleLoading(), ExampleFailure(NetworkFailure())],
    );
  });
}
