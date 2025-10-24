  import 'package:bloc/bloc.dart';

mixin CancelableBaseBloc<T> on BlocBase<T> {
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }
}

