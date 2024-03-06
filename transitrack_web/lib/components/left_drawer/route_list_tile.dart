import 'package:flutter/material.dart';
import '../../models/route_model.dart';
import '../../services/format_time.dart';
import '../../style/constants.dart';

class RouteListTile extends StatefulWidget {
  final RouteData route;
  final bool isSelected;
  final Function() hoverToggle;

  RouteListTile({
    super.key,
    required this.route,
    required this.isSelected,
    required this.hoverToggle
  });

  @override
  State<RouteListTile> createState() => _RouteListTileState();
}

class _RouteListTileState extends State<RouteListTile> {
  bool routeManageOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          isThreeLine: true,
          horizontalTitleGap: 0.0,
          contentPadding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
          title: Text(widget.route.routeName, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 1),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  formatTime(widget.route.routeTime),
                  style: const TextStyle(color: Colors.white54),
                  overflow: TextOverflow.ellipsis
              ),
              Text(
                  widget.route.routeFare == widget.route.routeFareDiscounted
                      ? "${widget.route.routeFare} pesos"
                      : "${widget.route.routeFareDiscounted} - ${widget.route.routeFare} pesos",
                  style: const TextStyle(color: Colors.white54),
                  overflow: TextOverflow.ellipsis
              ),
            ],
          ),
          selectedTileColor: Colors.white10,
          selected: widget.isSelected,
          trailing: Icon(Icons.circle, color: Color(widget.route.routeColor))
        ),
      ],
    );
  }
}