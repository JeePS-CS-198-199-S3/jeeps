import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/left_drawer/route_list_tile.dart';
import 'package:transitrack_web/models/account_model.dart';
import '../../models/route_model.dart';

class RouteList extends StatefulWidget {
  final List<RouteData>? routes;
  final int routeChoice;
  final AccountData? user;
  final ValueChanged<int> newRouteChoice;
  final Function() hoverToggle;
  RouteList(
      {super.key,
      required this.routeChoice,
      required this.routes,
      required this.user,
      required this.newRouteChoice,
      required this.hoverToggle});

  @override
  State<RouteList> createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  int hover = -1;

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
              if ((widget.routes![index].enabled) ||
                  (widget.user != null &&
                      widget.user!.account_type == 2 &&
                      widget.user!.is_verified &&
                      widget.user!.route_id == index)) {
                return MouseRegion(
                  onExit: (_) => setState(() {
                    hover = -1;
                  }),
                  onHover: (_) => setState(() {
                    hover = index;
                  }),
                  child: GestureDetector(
                    onTap: () {
                      widget.newRouteChoice(index);
                    },
                    child: RouteListTile(
                      route: widget.routes![index],
                      isSelected: widget.routeChoice == index || hover == index,
                      hoverToggle: widget.hoverToggle,
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        if (widget.routes == null)
          const Center(child: CircularProgressIndicator())
      ],
    );
  }
}
