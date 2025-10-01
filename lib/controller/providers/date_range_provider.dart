import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateRangeController extends StateNotifier<int> {
  DateRangeController() : super(0);
  void updateRange(int updatedTime) {
    state = updatedTime;
  }
}

StateNotifierProvider<DateRangeController, int> dateRangeProvider =
    StateNotifierProvider<DateRangeController, int>((Ref ref) {
      return DateRangeController();
    });
