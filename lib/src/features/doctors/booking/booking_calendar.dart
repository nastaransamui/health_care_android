import 'package:flutter/material.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BookingCalendar extends StatefulWidget {
  const BookingCalendar({
    super.key,
    required this.bookingInformation,
    required this.setCalendarValue,
  });

  final BookingInformation bookingInformation;
  final void Function(DateTime) setCalendarValue;

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  final DateRangePickerController dateRangePickerController = DateRangePickerController();
  @override
  void dispose() {
    dateRangePickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BookingInformation bookingInformation = widget.bookingInformation;
    final String homeThemeName = Provider.of<ThemeProvider>(context, listen: false).homeThemeName;

    final Set<DateTime> availableDates = {
      for (final slot in bookingInformation.availableSlots)
        ..._generateDateRange(
          slot.startDate.toLocal(),
          slot.finishDate.toLocal(),
        )
    };
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SfDateRangePicker(
        controller: dateRangePickerController,
        view: DateRangePickerView.month,
        showNavigationArrow: true,
        monthViewSettings: const DateRangePickerMonthViewSettings(enableSwipeSelection: false),
        enablePastDates: false,
        selectionColor: Colors.transparent,
        selectionMode: DateRangePickerSelectionMode.single,
        minDate: DateTime.now().isAfter(widget.bookingInformation.availableSlots.first.startDate)
            ? DateTime.now()
            : widget.bookingInformation.availableSlots.first.startDate,
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          final DateTime selectedDate = args.value;
          final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

          if (availableDates.contains(selectedDay)) {
            widget.setCalendarValue(selectedDay);
            // proceed with this date
          }
        },
        cellBuilder: (BuildContext context, DateRangePickerCellDetails cellDetails) {
          final now = DateTime.now();
          final date = cellDetails.date;
          final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
          final cellDay = DateTime(date.year, date.month, date.day);
          final selectedDate = dateRangePickerController.selectedDate;
          final isSelected =
              selectedDate != null && selectedDate.year == date.year && selectedDate.month == date.month && selectedDate.day == date.day;
          final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
          bool isAvailable = availableDates.contains(cellDay);

          Color bgColor = Colors.transparent;
          TextStyle textStyle = TextStyle(color: textColor);
          Color borderColor = Colors.transparent;

          if (isPast) {
            textStyle = const TextStyle(color: Colors.grey);
          } else if (isAvailable) {
            bgColor = theme.primaryColor;
            textStyle = TextStyle(color: homeThemeName == 'oceanBlue' ? Colors.black : textColor, fontWeight: FontWeight.bold);
            borderColor = theme.primaryColorLight;
          }
          if (isSelected) {
            bgColor = theme.primaryColorLight;
            borderColor = theme.primaryColor;
            textStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
          }
          if (!isPast && !isSelected && isWeekend) {
            textStyle = TextStyle(color: theme.primaryColorLight, fontWeight: FontWeight.w600);
          }
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              height: 15,
              width: 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: BoxBorder.all(color: borderColor, width: 1),
              ),
              child: Text('${date.day}', style: textStyle),
            ),
          );
        },
      ),
    );
  }
}


Set<DateTime> _generateDateRange(DateTime start, DateTime end) {
  final Set<DateTime> days = {};
  DateTime current = DateTime(start.year, start.month, start.day);
  DateTime finalDay = DateTime(end.year, end.month, end.day);

  while (!current.isAfter(finalDay)) {
    days.add(current);
    current = current.add(const Duration(days: 1));
  }

  return days;
}
