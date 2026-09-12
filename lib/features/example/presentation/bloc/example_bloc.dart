import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/example.dart';
import '../../domain/usecases/get_examples.dart';

part 'example_event.dart';
part 'example_state.dart';

class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  ExampleBloc(this._getExamples) : super(const ExampleInitial()) {
    on<ExampleRequested>(_onRequested);
  }

  final GetExamples _getExamples;

  Future<void> _onRequested(
    ExampleRequested event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());
    final result = await _getExamples();
    emit(switch (result) {
      Success(:final data) => ExampleLoaded(data),
      Error(:final failure) => ExampleFailure(failure),
    });
  }
}
