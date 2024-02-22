import 'package:flutter/cupertino.dart';
import '../models/route_model.dart';
import 'drawer_list_tile.dart';

class RouteList extends StatefulWidget {
  final List<RouteData> routes;
  final int routeChoice;
  final ValueChanged<int> newRouteChoice;
  final int isAdmin;
  const RouteList({super.key, required this.routeChoice, required this.routes, required this.newRouteChoice, required this.isAdmin});

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
              child: DrawerListTile(
                route: widget.routes[index],
                isSelected: widget.routeChoice == index,
                isAdmin: widget.isAdmin == index,
              ),
            );
          },
        )
      ],
    );
  }
}
