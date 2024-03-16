import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/left_drawer/route_list_tile.dart';
import '../../models/route_model.dart';

class RouteList extends StatefulWidget {
  final List<RouteData>? routes;
  final int routeChoice;
  final ValueChanged<int> newRouteChoice;
  final Function() hoverToggle;
  RouteList(
      {super.key,
      required this.routeChoice,
      required this.routes,
      required this.newRouteChoice,
      required this.hoverToggle});

  @override
  State<RouteList> createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.routes != null)
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.routes!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  widget.newRouteChoice(index);
                },
                child: RouteListTile(
                  route: widget.routes![index],
                  isSelected: widget.routeChoice == index,
                  hoverToggle: widget.hoverToggle,
                ),
              );
            },
          ),
        if (widget.routes == null)
          const Center(child: CircularProgressIndicator())
      ],
    );
  }
}
