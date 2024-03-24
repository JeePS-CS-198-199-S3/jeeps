import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/config/keys.dart';
import 'package:transitrack_web/config/map_settings.dart';
import 'package:transitrack_web/models/report_model.dart';
import 'package:transitrack_web/services/int_to_hex.dart';

class ReportsMap extends StatefulWidget {
  final bool isHover;
  final bool isDispose;
  final ValueChanged<bool> mapLoaded;
  final List<ReportData> reportData;
  final ReportData? selectedReport;
  final VoidCallback deselect;
  final ValueChanged<ReportData> selectedFromMap;
  const ReportsMap(
      {super.key,
      required this.isHover,
      required this.isDispose,
      required this.mapLoaded,
      required this.selectedReport,
      required this.deselect,
      required this.selectedFromMap,
      required this.reportData});

  @override
  State<ReportsMap> createState() => _ReportsMapState();
}

class _ReportsMapState extends State<ReportsMap> {
  late MapboxMapController _mapController;
  late bool isHover;
  late List<ReportData> reportData;
  late ReportData? selectedReport;

  List<ReportEntity> reportEntities = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      isHover = widget.isHover;
      reportData = widget.reportData;
      selectedReport = null;
    });
  }

  @override
  void didUpdateWidget(covariant ReportsMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isDispose) {
      _mapController.dispose();
    }

    if (widget.isHover != isHover) {
      setState(() {
        isHover = widget.isHover;
      });
    }

    if (widget.reportData != reportData) {
      setState(() {
        reportData = widget.reportData;
      });

      if (reportData.isNotEmpty) {
        showReportData();
      }
    }

    if (widget.selectedReport != selectedReport) {
      if (selectedReport != null && selectedReport!.report_type > 0) {
        _mapController.updateCircle(
            reportEntities
                .firstWhere((reportEntity) =>
                    reportEntity.reportData.report_id ==
                    selectedReport!.report_id)
                .reportCircle,
            const CircleOptions(circleStrokeWidth: 0));
      }
      setState(() {
        selectedReport = widget.selectedReport;
      });

      if (selectedReport != null && selectedReport!.report_type > 0) {
        _mapController.updateCircle(
            reportEntities
                .firstWhere((element) =>
                    element.reportData.report_id == selectedReport!.report_id)
                .reportCircle,
            const CircleOptions(circleStrokeWidth: 2));
        _mapController.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(selectedReport!.report_location.latitude,
                selectedReport!.report_location.longitude),
            mapStartZoom));
      }
    }
  }

  void onCircleTapped(Circle pressedCircle) {
    if (selectedReport != null && selectedReport!.report_type > 0) {
      if (pressedCircle ==
          reportEntities
              .firstWhere((element) =>
                  element.reportData.report_id == selectedReport!.report_id)
              .reportCircle) {
        widget.deselect();
        _mapController.updateCircle(
            pressedCircle, const CircleOptions(circleStrokeWidth: 0));
      } else {
        _mapController.updateCircle(
            reportEntities
                .firstWhere((element) =>
                    element.reportData.report_id == selectedReport!.report_id)
                .reportCircle,
            const CircleOptions(circleStrokeWidth: 0));
        _mapController.updateCircle(
            pressedCircle, const CircleOptions(circleStrokeWidth: 2));
        widget.selectedFromMap(reportEntities
            .firstWhere((element) => element.reportCircle == pressedCircle)
            .reportData);
      }
    } else {
      _mapController.updateCircle(
          pressedCircle, const CircleOptions(circleStrokeWidth: 2));
      widget.selectedFromMap(reportEntities
          .firstWhere((element) => element.reportCircle == pressedCircle)
          .reportData);
    }
  }

  void showReportData() {
    if (reportEntities.isNotEmpty) {
      _mapController.clearCircles().then((value) => reportEntities.clear());
    }

    for (ReportData report
        in reportData.where((report) => report.report_type > 0)) {
      _mapController
          .addCircle(CircleOptions(
              circleRadius: 5,
              circleOpacity: 0.5,
              circleStrokeColor: intToHexColor(Colors.white.value),
              circleColor: intToHexColor(ReportData
                  .reportDetails[report.report_type].reportColors.value),
              geometry: LatLng(report.report_location.latitude,
                  report.report_location.longitude)))
          .then((reportCircle) => reportEntities.add(
              ReportEntity(reportData: report, reportCircle: reportCircle)));
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: Keys.MapBoxKey,
      styleString: Keys.MapBoxNight,
      doubleClickZoomEnabled: false,
      minMaxZoomPreference: MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
      scrollGesturesEnabled: !isHover,
      zoomGesturesEnabled: !isHover,
      rotateGesturesEnabled: !isHover,
      tiltGesturesEnabled: !isHover,
      compassEnabled: true,
      compassViewPosition: CompassViewPosition.TopLeft,
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController.onCircleTapped.add(onCircleTapped);
      },
      onStyleLoadedCallback: () async {
        widget.mapLoaded(true);
        showReportData();
      },
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: mapStartZoom,
      ),
      onMapClick: (point, latLng) {
        if (selectedReport != null) {
          if (selectedReport!.report_type > 0) {
            _mapController.updateCircle(
                reportEntities
                    .firstWhere((report) =>
                        report.reportData.report_id ==
                        selectedReport!.report_id)
                    .reportCircle,
                const CircleOptions(circleStrokeWidth: 0));
          }

          widget.deselect();
        }
      },
    );
  }
}
