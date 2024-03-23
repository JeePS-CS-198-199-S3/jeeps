import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/shared_locations_map.dart';
import 'package:transitrack_web/models/ping_model.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/style/constants.dart';

class SharedLocationsPage extends StatefulWidget {
  final RouteData routeData;
  const SharedLocationsPage({super.key, required this.routeData});

  @override
  State<SharedLocationsPage> createState() => _SharedLocationsPageState();
}

class _SharedLocationsPageState extends State<SharedLocationsPage> {
  late List<PingData>? pings;
  late List<PingData>? boundedPings;
  late Timestamp? earliest;
  late Timestamp? latest;

  late Timestamp? startBound;
  late Timestamp? endBound;

  bool isHover = false;
  bool mapLoaded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      pings = null;
      boundedPings = null;
      earliest = null;
      latest = null;
      startBound = null;
      endBound = null;
    });
    fetchPingData();
  }

  void hover(bool value) {
    setState(() {
      isHover = value;
    });
  }

  void fetchPingData() async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('pings')
        .where('ping_route', isEqualTo: widget.routeData.routeId);

    query = query.orderBy('ping_timestamp', descending: true);

    QuerySnapshot querySnapshot = await query.get();

    setState(() {
      pings = querySnapshot.docs.map((DocumentSnapshot document) {
        return PingData.fromFirestore(document);
      }).toList();
      boundedPings = pings;
      earliest = pings!.last.ping_timestamp;
      latest = pings!.first.ping_timestamp;

      startBound = earliest!;
      endBound = latest!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 700,
        child: Stack(
          children: [
            SharedLocationsMap(
                routeData: widget.routeData,
                pings: boundedPings,
                isHover: isHover,
                mapLoaded: (bool value) {
                  setState(() {
                    mapLoaded = value;
                  });
                }),
            Positioned(
              top: Constants.defaultPadding,
              right: Constants.defaultPadding,
              child: MouseRegion(
                onEnter: (_) => hover(true),
                onExit: (_) => hover(false),
                child: Container(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  width: 350,
                  decoration: BoxDecoration(
                      color: Constants.bgColor,
                      borderRadius:
                          BorderRadius.circular(Constants.defaultPadding / 2)),
                  child: (mapLoaded && earliest != null && latest != null)
                      ? Column(
                          children: [
                            SharedLocationsDateScrollerWidget(
                              routeData: widget.routeData,
                              earliest: earliest!,
                              latest: latest!,
                              bounds: (List<Timestamp> bounds) {
                                setState(() {
                                  startBound = bounds[0];
                                  endBound = bounds[1];
                                  boundedPings = pings!
                                      .where((ping) =>
                                          ping.ping_timestamp.seconds >=
                                              startBound!.seconds &&
                                          ping.ping_timestamp.seconds <=
                                              endBound!.seconds)
                                      .toList();
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('MMM d')
                                    .format(startBound!.toDate())),
                                Text(DateFormat('MMM d')
                                    .format(endBound!.toDate())),
                              ],
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

class SharedLocationsDateScrollerWidget extends StatefulWidget {
  final RouteData routeData;
  final Timestamp earliest;
  final Timestamp latest;
  final ValueChanged<List<Timestamp>> bounds;
  const SharedLocationsDateScrollerWidget(
      {super.key,
      required this.routeData,
      required this.earliest,
      required this.latest,
      required this.bounds});

  @override
  State<SharedLocationsDateScrollerWidget> createState() =>
      _SharedLocationsDateScrollerWidgetState();
}

class _SharedLocationsDateScrollerWidgetState
    extends State<SharedLocationsDateScrollerWidget> {
  late int _startValue;
  late int _endValue;

  @override
  void initState() {
    super.initState();
    setState(() {
      _startValue = widget.earliest.millisecondsSinceEpoch;
      _endValue = widget.latest.millisecondsSinceEpoch;
    });
  }

  int _calculateDaysDifference(Timestamp timestamp1, Timestamp timestamp2) {
    DateTime dateTime1 =
        DateTime.fromMillisecondsSinceEpoch(timestamp1.seconds * 1000);
    DateTime dateTime2 =
        DateTime.fromMillisecondsSinceEpoch(timestamp2.seconds * 1000);

    Duration difference = dateTime2.difference(dateTime1);

    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: RangeValues(_startValue.toDouble(), _endValue.toDouble()),
      min: widget.earliest.millisecondsSinceEpoch.toDouble(),
      max: widget.latest.millisecondsSinceEpoch.toDouble(),
      divisions: _calculateDaysDifference(widget.earliest, widget.latest),
      activeColor: Color(widget.routeData.routeColor),
      inactiveColor: Color(widget.routeData.routeColor).withOpacity(0.2),
      onChanged: (RangeValues values) {
        setState(() {
          if (values.start.toInt() < values.end.toInt() - 86400) {
            _startValue = values.start.toInt();
            _endValue = values.end.toInt();
          }

          widget.bounds([
            Timestamp.fromMillisecondsSinceEpoch(_startValue),
            Timestamp.fromMillisecondsSinceEpoch(_endValue)
          ]);
        });
      },
    );
  }
}
