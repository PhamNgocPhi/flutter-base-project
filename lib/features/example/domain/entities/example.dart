import 'package:equatable/equatable.dart';

class Example extends Equatable {
  const Example({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
