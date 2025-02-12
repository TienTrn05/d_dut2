part of 'root_bloc.dart';

sealed class MainEvent {}

class ChangePage extends MainEvent {
  final int pageIndex;
  ChangePage(this.pageIndex);
}
