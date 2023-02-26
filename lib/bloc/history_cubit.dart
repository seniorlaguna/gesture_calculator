import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:gesture_calculator/ui/index.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'history_cubit.freezed.dart';
part 'history_cubit.g.dart';

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState(
      {required List<String> entries}) = _HistoryState;

  factory HistoryState.fromJson(Map<String, Object?> json) =>
      _$HistoryStateFromJson(json);
}


class HistoryCubit extends HydratedCubit<HistoryState> {

  static const HistoryState defaultState = HistoryState(entries: []);

  static HistoryCubit of(BuildContext context) =>
      BlocProvider.of<HistoryCubit>(context);

  HistoryCubit(super.state);


  Future<void> add(String entry) async {
    // dont add same entry twice in a row
    if (state.entries.isNotEmpty && state.entries.first == entry) return;

    
    List<String> h = List.from(state.entries);
    h.insert(0, entry);
    emit(state.copyWith(entries: h));
  }

  Future<void> remove(int index) async {
    List<String> h = List.from(state.entries);
    h.removeAt(index);
    emit(state.copyWith(entries: h));
  } 

  Future<void> clearHistory() async {
    emit(state.copyWith(entries: []));
  }

  @override
  HistoryState? fromJson(Map<String, dynamic> json) {
    return HistoryState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HistoryState state) {
    return state.toJson();
  }

}