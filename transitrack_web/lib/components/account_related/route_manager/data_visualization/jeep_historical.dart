import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/calendar_selector.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/jeep_historical_map.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/minute_slider.dart';
import 'package:transitrack_web/models/jeep_model.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/style/constants.dart';

class JeepHistoricalPage extends StatefulWidget {
  final RouteData routeData;
  const JeepHistoricalPage({super.key, required this.routeData});

  @override
  State<JeepHistoricalPage> createState() => _JeepHistoricalPageState();
}

class _JeepHistoricalPageState extends State<JeepHistoricalPage> {
  DateTime? _selectedDate;

  bool mapLoaded = false;

  List<JeepHistoricalData>? jeepHistoricalData = [];

  int _second = 0;

  List<JeepData>? processedJeeps;

  void processHistoricalData() {
    setState(() {
      processedJeeps = jeepHistoricalData!
          .map((e) => e.data.firstWhere((element) => element.timestamp
              .toDate()
              .isBefore(_selectedDate!
                  .subtract(const Duration(hours: 1))
                  .add(Duration(seconds: _second)))))
          .toList();
    });
  }

  void fetchHistoricalData() async {
    setState(() {
      jeepHistoricalData = null;
      processedJeeps = null;
    });

    List<JeepHistoricalData>? data =
        await getJeepHistoricalData(widget.routeData.routeId, _selectedDate!);

    if (data != null) {
      setState(() {
        jeepHistoricalData = data;
        _second = 0;
      });

      print("Loaded ${jeepHistoricalData!.length} Documents.");

      processHistoricalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 700,
        child: Stack(
          children: [
            JeepHistoricalMap(
              mapLoaded: (bool value) {
                setState(() {
                  mapLoaded = value;
                });
              },
              jeepHistoricalData: processedJeeps,
              routeData: widget.routeData,
            ),
            Positioned(
              top: Constants.defaultPadding,
              right: Constants.defaultPadding,
              child: PointerInterceptor(
                child: Container(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  width: 350,
                  decoration: BoxDecoration(
                      color: Constants.bgColor,
                      borderRadius:
                          BorderRadius.circular(Constants.defaultPadding / 2)),
                  child: (mapLoaded)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: _selectedDate == null
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () => AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.noHeader,
                                        padding: const EdgeInsets.only(
                                            bottom: Constants.defaultPadding),
                                        width: 600,
                                        body: PointerInterceptor(
                                            child: CalendarSelector(
                                          routeData: widget.routeData,
                                          selectedDate: _selectedDate ??
                                              DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day),
                                          newSelectedDate:
                                              (DateTime newSelectedDate) {
                                            setState(() {
                                              _selectedDate = newSelectedDate;
                                            });

                                            // print(_selectedDate);
                                            fetchHistoricalData();
                                          },
                                        ))).show(),
                                    icon: const Text("Select Date"),
                                  ),
                                  if (_selectedDate != null &&
                                      jeepHistoricalData != null)
                                    Text(
                                        '${DateFormat('MMM d, yyyy').format(_selectedDate!)} - ${formatSliderValue(_selectedDate!.hour.toDouble())}')
                                ]),
                            if (jeepHistoricalData != null &&
                                _selectedDate != null)
                              Column(
                                children: [
                                  const Divider(color: Colors.white),
                                  SecondSlider(
                                      routeData: widget.routeData,
                                      second: _second.toDouble(),
                                      newSecond: (double newSecond) {
                                        setState(() {
                                          _second = newSecond.toInt();
                                        });
                                        processHistoricalData();
                                      }),
                                  Center(
                                      child: Text(DateFormat('hh:mm:ss a')
                                          .format(DateTime(
                                              _selectedDate!.year,
                                              _selectedDate!.month,
                                              _selectedDate!.day,
                                              _selectedDate!.hour,
                                              _second ~/ 60,
                                              _second % 60))))
                                ],
                              ),
                            if (jeepHistoricalData == null)
                              Center(
                                child: CircularProgressIndicator(
                                  color: Color(widget.routeData.routeColor),
                                ),
                              )
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(
                          color: Color(widget.routeData.routeColor),
                        )),
                ),
              ),
            )
          ],
        ));
  }
}
