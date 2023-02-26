import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class TutotialCubit extends HydratedCubit<int> {
  
  static const int openSettingsStep = 1;
  static const int openScientificKeyboardStep = 2;
  static const int switchScientificKeyboardStep = 3;
  static const int openHistoryStep = 4;
  static const int openDrawerStep = 5;
  static const int done = 6;
  
  static TutotialCubit of(BuildContext context) => BlocProvider.of<TutotialCubit>(context);

  TutotialCubit() : super(0);

  Future<void> init() async {
    if (state != 0) return;
    await Future.delayed(const Duration(seconds: 0));
    emit(openSettingsStep);
  }

  Future<void> goToState(int nextState) async {
    if (state == nextState - 1) {
      await Future.delayed(const Duration(milliseconds: 800));
      emit(nextState);
    }
  }

  Future<void> skipTo(int nextState) async {
    emit(nextState);
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    return json["value"];
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    if (state == TutotialCubit.done) {
          return {"value" : TutotialCubit.done};
    }
    return null;
  }
}