import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/hour_slider.dart';
import 'package:transitrack_web/components/calendar.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/style/constants.dart';

// This widget is used for the historical puv data to select a specific hour.

class CalendarSelector extends StatefulWidget {
  final RouteData routeData;
  final DateTime selectedDate;
  final ValueChanged<DateTime> newSelectedDate;
  const CalendarSelector(
      {super.key,
      required this.routeData,
      required this.selectedDate,
      required this.newSelectedDate});

  @override
  State<CalendarSelector> createState() => _CalendarSelectorState();
}

class _CalendarSelectorState extends State<CalendarSelector> {
  late DateTime _selectedDate;
  late int hour;

  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedDate = widget.selectedDate;
      hour = widget.selectedDate.hour;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
      child: Column(
        children: [
          CalendarWidget(
            routeData: widget.routeData,
            selectedDate: _selectedDate,
            newSelectedDate: (DateTime newSelectedDate) => setState(() {
              _selectedDate = newSelectedDate;
            }),
          ),
          const Divider(color: Colors.white),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Select an hour"),
            ],
          ),
          HourSlider(
              routeData: widget.routeData,
              hour: _selectedDate.hour.toDouble(),
              newHour: (double newHour) => setState(() {
                    hour = newHour.toInt();
                  })),
          const Divider(color: Colors.white),
          IconButton(
              onPressed: () {
                widget.newSelectedDate(DateTime(_selectedDate.year,
                    _selectedDate.month, _selectedDate.day, hour));
              },
              icon: Text(
                  "Show Historical PUV Data on ${DateFormat('MMM d, yyyy').format(_selectedDate)} (${formatSliderValue(hour.toDouble())} - ${formatSliderValue(hour.toDouble() + 1)})"))
        ],
      ),
    );
  }
}

String formatSliderValue(double value) {
  if (value == 24) {
    return "12 MN";
  }
  int hours = value.toInt() % 12;
  if (hours == 0) hours = 12;
  String period = value < 12 ? 'AM' : 'PM';
  return '$hours $period';
}
