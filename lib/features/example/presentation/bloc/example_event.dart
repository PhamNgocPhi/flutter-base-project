part of 'example_bloc.dart';

sealed class ExampleEvent extends Equatable {
  const ExampleEvent();
  @override
  List<Object?> get props => [];
}

final class ExampleRequested extends ExampleEvent {
  const ExampleRequested();
}
