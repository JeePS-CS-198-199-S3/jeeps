import 'package:flutter/cupertino.dart';
import 'package:transitrack_web/components/left_drawer/route_list_tile.dart';
import '../../models/account_model.dart';
import '../../models/route_model.dart';

class RouteList extends StatefulWidget {
  final List<RouteData> routes;
  final int routeChoice;
  final ValueChanged<int> newRouteChoice;
  final AccountData? account;
  final Function() hoverToggle;
  const RouteList({super.key,
    required this.routeChoice,
    required this.routes,
    required this.newRouteChoice,
    this.account,
    required this.hoverToggle}
  );

  @override
  State<RouteList> createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.routes.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                widget.newRouteChoice(index);
              },
              child: RouteListTile(
                route: widget.routes[index],
                isSelected: widget.routeChoice == index,
                isAdmin: widget.account != null
                    ? widget.account!.is_verified && widget.account!.account_type == 2 && widget.account!.route_id == index
                    : false,
                hoverToggle: widget.hoverToggle,
              ),
            );
          },
        )
      ],
    );
  }
}
