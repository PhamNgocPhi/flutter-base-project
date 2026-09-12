part of 'example_bloc.dart';

sealed class ExampleState extends Equatable {
  const ExampleState();
  @override
  List<Object?> get props => [];
}

final class ExampleInitial extends ExampleState {
  const ExampleInitial();
}

final class ExampleLoading extends ExampleState {
  const ExampleLoading();
}

final class ExampleLoaded extends ExampleState {
  const ExampleLoaded(this.items);
  final List<Example> items;
  @override
  List<Object?> get props => [items];
}

final class ExampleFailure extends ExampleState {
  const ExampleFailure(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
