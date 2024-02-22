import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.route,
    required this.isSelected,
    required this.isAdmin
  });

  final RouteData route;
  final bool isSelected;
  final bool? isAdmin;

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
      isThreeLine: true,
      horizontalTitleGap: 0.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
      title: Text(route.routeName, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(
          "${formatTime(route.routeTime)}\n${route.routeFare == route.routeFareDiscounted
              ? "${route.routeFare} pesos"
              : "${route.routeFareDiscounted} - ${route.routeFare} pesos"}",
          style: const TextStyle(color: Colors.white54),
          overflow: TextOverflow.ellipsis
      ),
      selectedTileColor: Colors.white10,
      selected: isSelected,
      trailing: Column(
        children: [
          Icon(Icons.circle, color: Color(route.routeColor),
          ),

          const SizedBox(height: Constants.defaultPadding/2),

          if (isAdmin != null && isAdmin!)
            GestureDetector(
              onTap: () {

                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final Offset offset = renderBox.localToGlobal(Offset.zero);
                final double iconWidth = renderBox.size.width - 20;
                final double iconHeight = renderBox.size.height - 20;

                showMenu(
                  context: context,
                    position: RelativeRect.fromLTRB(
                      offset.dx + iconWidth, // Right position of the icon
                      offset.dy + iconHeight, // Bottom position of the icon
                      offset.dx + iconWidth, // Right position of the menu
                      offset.dy + iconHeight, // Bottom position of the menu
                    ),
                    items: [
                      PopupMenuItem(
                        child: Text('Route Settings'),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text('Change Route Coordinates'),
                        value: 2,
                      ),
                      PopupMenuItem(
                        child: Text('Manage Route Vehicles'),
                        value: 3,
                      ),
                    ],
                    elevation: 8, // Adjust elevation as needed
                ).then((value) {
                  if (value != null) {
                    print('Selected item: $value');
                  }
                });
              },
              child: const Icon(Icons.filter_list, color: Colors.white, size: 15)
            )

        ],
      ),
    );
  }
}