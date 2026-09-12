import 'package:flutter_bloc/flutter_bloc.dart';

/// Ví dụ feature đơn giản: chỉ Cubit + Screen, không cần tầng data/domain.
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
