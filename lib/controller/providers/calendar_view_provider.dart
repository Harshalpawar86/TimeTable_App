import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodos_app/model/calendar_view.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewController extends StateNotifier<CalendarView> {
  CalendarViewController()
    : super(
        CalendarView(
          focusedDay: DateTime.now(),
          selectedDay: null,
          rangeStart: null,
          rangeEnd: null,
          rangeSelectionMode: RangeSelectionMode.toggledOff,
        ),
      );
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    state =  CalendarView(
      selectedDay: selectedDay,
      rangeStart: null,
      rangeEnd: null,
      focusedDay: focusedDay,
      rangeSelectionMode: RangeSelectionMode.toggledOff,
    );
  }

  void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    state = CalendarView(
      selectedDay: null,
      rangeStart: start,
      rangeEnd: end,
      focusedDay: focusedDay,
      rangeSelectionMode: RangeSelectionMode.toggledOn,
    );
  }
}

StateNotifierProvider<CalendarViewController, CalendarView>
calendarViewProvider =
    StateNotifierProvider<CalendarViewController, CalendarView>((Ref ref) {
      return CalendarViewController();
    });
