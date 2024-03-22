import 'package:flutter/material.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/feedbacks_table.dart';
import 'package:transitrack_web/components/account_related/route_manager/data_visualization/reports_table.dart';
import 'package:transitrack_web/components/left_drawer/logo.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/style/constants.dart';
import 'package:transitrack_web/style/style.dart';

class DataVisualizationTab extends StatefulWidget {
  final RouteData route;
  final ValueChanged<bool> hover;
  const DataVisualizationTab(
      {super.key, required this.route, required this.hover});

  @override
  State<DataVisualizationTab> createState() => _DataVisualizationTabState();
}

class DataVisualizationMenuList {
  String menuName;
  Widget menuWidget;

  DataVisualizationMenuList({required this.menuName, required this.menuWidget});
}

class _DataVisualizationTabState extends State<DataVisualizationTab> {
  late List<DataVisualizationMenuList> menuList = [
    DataVisualizationMenuList(
        menuName: "Feedbacks",
        menuWidget: FeedbacksTable(
          route: widget.route,
          hover: (bool hover) {
            widget.hover(hover);
          },
        )),
    DataVisualizationMenuList(
        menuName: "Reports",
        menuWidget: ReportsTable(
            route: widget.route,
            isDispose: selected == 1,
            hover: (bool hover) {
              widget.hover(hover);
            })),
    DataVisualizationMenuList(
        menuName: "Shared Locations", menuWidget: const SizedBox())
  ];

  int selected = -1;

  void selectOption(int index) {
    setState(() {
      selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Constants.defaultPadding,
          right: Constants.defaultPadding,
          bottom: Constants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              PrimaryText(
                text: widget.route.routeName,
                color: Colors.white,
                size: 40,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
          const Divider(color: Colors.white),
          const SizedBox(height: Constants.defaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: menuList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      selected: selected == index,
                      selectedColor: Constants.bgColor,
                      selectedTileColor: Color(widget.route.routeColor),
                      hoverColor: Colors.white.withOpacity(0.2),
                      title: Text(menuList[index].menuName),
                      onTap: () {
                        if (selected == index) {
                          selectOption(-1);
                        } else {
                          selectOption(index);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: selected == -1
                    ? const SizedBox(
                        height: 700,
                        child: Center(
                          child: Logo(),
                        ))
                    : menuList[selected].menuWidget,
              )
            ],
          )
        ],
      ),
    );
  }
}