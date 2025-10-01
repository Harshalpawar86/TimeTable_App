import 'package:table_calendar/table_calendar.dart';

class CalendarView {
  DateTime? selectedDay;
  DateTime focusedDay;
  DateTime? rangeStart;
  DateTime? rangeEnd;
  RangeSelectionMode rangeSelectionMode;

  CalendarView({
    required this.selectedDay,
    required this.rangeStart,
    required this.rangeEnd,
    required this.focusedDay,
    required this.rangeSelectionMode,
  });
}
