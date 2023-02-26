import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewCubit extends HydratedCubit<int> {

  static int defaultState = 0;
  static ReviewCubit of(BuildContext context) => BlocProvider.of<ReviewCubit>(context);

  ReviewCubit(super.state);

  Future<void> appStarted() async {
    if (state < 0) return;
    emit(state + 1);  
  }

  Future<bool> requestReview() async {
    if (!await InAppReview.instance.isAvailable()) return false;

    if ([10, 25, 50, 100].contains(state)) {
      await Future.delayed(const Duration(milliseconds: 500));
      InAppReview.instance.requestReview();
      return true;
    } else if (state > 100) {
      emit(-1);
    }
    return false;
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    return json["value"];
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    return {"value" : state};
  }
}