import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.Route,
    required this.isSelected,
  });

  final RouteData Route;
  final bool isSelected;

  String formatTime(List<int> times) {
    // Convert minutes to hours and minutes
    int startHours = times[0] ~/ 60;
    int startMinutes = times[0] % 60;
    int endHours = times[1] ~/ 60;
    int endMinutes = times[1] % 60;

    // Determine AM or PM for start and end times
    String startPeriod = startHours >= 12 ? 'PM' : 'AM';
    String endPeriod = endHours >= 12 ? 'PM' : 'AM';

    // Convert hours to 12-hour format
    if (startHours > 12) {
      startHours -= 12;
    }
    if (endHours > 12) {
      endHours -= 12;
    }

    // Format the time strings
    String startTime = '$startHours:${startMinutes.toString().padLeft(2, '0')} $startPeriod';
    String endTime = '$endHours:${endMinutes.toString().padLeft(2, '0')} $endPeriod';

    return '$startTime - $endTime';
  }


  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 0.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
      title: Text(Route.routeName, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 1,),
      subtitle: Text(formatTime(Route.routeTime), style: const TextStyle(color: Colors.white54), overflow: TextOverflow.ellipsis, maxLines: 1,),
      selectedTileColor: Colors.white10,
      selected: isSelected,
      trailing: Icon(Icons.circle, color: Color(Route.routeColor)),
    );
  }
}