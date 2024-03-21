import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/filters.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/reports_map.dart';
import 'package:transitrack_web/models/account_model.dart';
import 'package:transitrack_web/models/feedback_model.dart';
import 'package:transitrack_web/models/filter_model.dart';
import 'package:transitrack_web/models/report_model.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/style/constants.dart';

class ReportsTable extends StatefulWidget {
  final RouteData route;
  final bool isDispose;
  final ValueChanged<bool> hover;
  const ReportsTable(
      {super.key,
      required this.route,
      required this.hover,
      required this.isDispose});

  @override
  State<ReportsTable> createState() => _ReportsTableState();
}

class _ReportsTableState extends State<ReportsTable> {
  TextEditingController searchController = TextEditingController();

  bool mapLoaded = false;
  int selected = -1;
  late ReportData? selectedReport;

  List<ReportData>? reports;

  String searchString = "";

  FilterParameters orderBy =
      FilterParameters(filterSearch: "timestamp", filterDescending: true);

  @override
  void initState() {
    super.initState();

    loadReports();
  }

  void select(int index, ReportData? report) {
    setState(() {
      selected = index;
      selectedReport = report;
    });
  }

  Future<void> loadReports() async {
    setState(() {
      reports = null;
    });
    select(-1, null);

    Query<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('reports')
        .where('report_route', isEqualTo: widget.route.routeId);

    query = query.orderBy(orderBy.filterSearch,
        descending: orderBy.filterDescending);

    QuerySnapshot querySnapshot = await query.limit(20).get();

    setState(() {
      reports = querySnapshot.docs.map((DocumentSnapshot document) {
        return ReportData.fromFirestore(document);
      }).toList();
    });
  }

  Future<UsersAdditionalInfo?> loadReportDetails(
      String sender, String recepient) async {
    AccountData? senderData = await AccountData.getAccountByEmail(sender);
    AccountData? recepientData = await AccountData.getAccountByEmail(recepient);

    if (senderData != null && recepientData != null) {
      return UsersAdditionalInfo(
          senderData: senderData, recepientData: recepientData);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: Constants.defaultPadding),
        child: Row(
          children: [
            SizedBox(
              height: 700,
              width: 500,
              child: Column(
                children: [
                  SearchBar(
                    controller: searchController,
                    overlayColor: MaterialStateProperty.all(
                        Colors.white.withOpacity(0.2)),
                    elevation: MaterialStateProperty.all(0.0),
                    onChanged: (String value) {
                      setState(() {
                        searchString = value;
                      });
                      select(-1, null);
                    },
                    hintText: 'Search report message',
                    hintStyle: MaterialStateProperty.all(
                        TextStyle(color: Color(widget.route.routeColor))),
                    leading: const Icon(Icons.search),
                    shape: MaterialStateProperty.all(
                        const ContinuousRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    )),
                    trailing: <Widget>[
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                reports = null;
                              });
                              loadReports();
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                          IconButton(
                            onPressed: () => AwesomeDialog(
                              dialogType: DialogType.noHeader,
                              context: (context),
                              width: 500,
                              body: MouseRegion(
                                  onEnter: (_) => widget.hover(true),
                                  onExit: (_) => widget.hover(false),
                                  child: Filters(
                                    route: widget.route,
                                    dropdownList:
                                        FilterParameters.reportsOrderBy,
                                    oldFilter: orderBy,
                                    newFilter: (FilterParameters newFilter) {
                                      setState(() {
                                        orderBy = newFilter;
                                      });
                                      loadReports();
                                    },
                                  )),
                            ).show(),
                            icon: const Icon(Icons.filter_list),
                          )
                        ],
                      )
                    ],
                  ),
                  if (reports == null || !mapLoaded)
                    SizedBox(
                        height: 500,
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Color(widget.route.routeColor),
                        ))),
                  if (reports != null && mapLoaded)
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: reports!.length,
                          itemBuilder: (context, index) {
                            ReportData report = reports![index];

                            if (searchString.isNotEmpty &&
                                !report.report_content
                                    .toLowerCase()
                                    .contains(searchString.toLowerCase())) {
                              return const SizedBox();
                            }
                            return ListTile(
                              onTap: () async {
                                if (selected == index) {
                                  select(-1, null);
                                } else {
                                  select(index, report);
                                }
                              },
                              selected: index == selected,
                              selectedColor: Colors.white,
                              selectedTileColor: Color(widget.route.routeColor)
                                  .withOpacity(0.1),
                              hoverColor: Colors.white.withOpacity(0.2),
                              trailing: Text(
                                DateFormat('MMM d')
                                    .format(report.timestamp.toDate()),
                                style: const TextStyle(fontSize: 13),
                              ),
                              title: RichText(
                                  textAlign: TextAlign.justify,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text:
                                              "[${ReportData.reportType[report.report_type]}]",
                                          style: TextStyle(
                                              color: Color(
                                                  widget.route.routeColor),
                                              fontWeight: FontWeight.w200)),
                                      TextSpan(
                                        text: ' - "${report.report_content}"',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  )),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Constants.defaultPadding),
            Expanded(
                child: SizedBox(
              height: 700,
              child: Stack(
                children: [
                  ReportsMap(
                    isHover: false,
                    isDispose: widget.isDispose,
                    reportData: reports ?? [],
                    selectedReport: selectedReport,
                    mapLoaded: (bool value) {
                      setState(() {
                        mapLoaded = value;
                      });
                    },
                    deselect: () => select(-1, null),
                  ),
                  if (selectedReport != null)
                    Positioned(
                        right: Constants.defaultPadding,
                        top: Constants.defaultPadding,
                        child: Container(
                          width: 350,
                          height: 200,
                          decoration: BoxDecoration(
                              color: Constants.bgColor,
                              borderRadius: BorderRadius.circular(
                                  Constants.defaultPadding / 2)),
                          child: Text("content"),
                        ))
                ],
              ),
            ))
          ],
        ));
  }
}
