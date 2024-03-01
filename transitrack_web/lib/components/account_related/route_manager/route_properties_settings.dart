import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:transitrack_web/services/format_time.dart';

import '../../../models/route_model.dart';
import '../../../style/constants.dart';
import '../../../style/style.dart';
import '../../button.dart';
import '../../text_field.dart';

class PropertiesSettings extends StatefulWidget {
  RouteData route;
  PropertiesSettings({super.key, required this.route});

  @override
  State<PropertiesSettings> createState() => _PropertiesSettingsState();
}

class _PropertiesSettingsState extends State<PropertiesSettings> {
  final nameController = TextEditingController();
  final fareController = TextEditingController();
  final fareDiscountedController = TextEditingController();
  late bool enabled;
  late List<int> route_time;
  late RangeValues selectedRange;
  late Color selectedColor;
  late Color chosenColor;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.route.routeName;
    fareController.text = widget.route.routeFare.toString();
    fareDiscountedController.text = widget.route.routeFareDiscounted.toString();
    enabled = widget.route.enabled;
    route_time = widget.route.routeTime;
    selectedRange = RangeValues(route_time[0].toDouble(), route_time[1].toDouble());
    selectedColor = Color(widget.route.routeColor);
  }

  void errorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Constants.bgColor,
              title: Center(
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  )
              )
          );
        }
    );
  }

  void update() async {
    bool cleared = true;
    if (nameController.text == "" || nameController.text.length > 15) {
      errorMessage("The route name must be between 1 and 15 characters long.");
      cleared = false;
    }

    if (fareController.text == "") {
      errorMessage("The regular fare must not be empty.");
      cleared = false;
    }

    if (fareDiscountedController.text == "") {
      errorMessage("The discounted fare must not be empty.");
      cleared = false;
    }

    if (cleared) {
      // show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
      );
      try {
        Map<String, dynamic> newAccountSettings = {
          'route_name': nameController.text,
          'route_fare': double.tryParse(fareController.text),
          'route_fare_discounted': double.tryParse(fareDiscountedController.text),
          'enabled': enabled,
          'route_time': [selectedRange.start.round(), selectedRange.end.round()],
          'route_color': selectedColor.value
        };
        RouteData.updateRouteFirestore(widget.route.routeId, newAccountSettings);
        Navigator.pop(context);
        Navigator.pop(context);
      } catch (e) {
        // pop loading circle
        Navigator.pop(context);
        errorMessage(e.toString());
      }
    }
  }

  Widget buildColorPicker() {
    chosenColor = selectedColor;

    return ColorPicker(
      pickerColor: chosenColor,
      enableAlpha: false,
      labelTypes: [],
      onColorChanged: (color) {
        setState(() {
          chosenColor = color;
        });
      }
    );
  }

  void pickColor(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Set Route Color'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildColorPicker(),

              const SizedBox(height: Constants.defaultPadding),

              TextButton(
                child: const Text(
                  'SELECT',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  setState(() {
                    selectedColor = chosenColor;
                  });
                  Navigator.of(context).pop();
                }
              ),
            ],
          )
      )
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InputTextField(controller: nameController, hintText: "Route Name", obscureText: false),

        const SizedBox(height: Constants.defaultPadding),

        InputTextField(controller: fareController, hintText: "Regular Fare", obscureText: false, type: TextInputType.number,),

        const SizedBox(height: Constants.defaultPadding),

        InputTextField(controller: fareDiscountedController, hintText: "Discounted Fare (Students/Senior Citizen)", obscureText: false, type: TextInputType.number),

        const SizedBox(height: Constants.defaultPadding),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Enable Route"),
            Switch(
              activeColor: selectedColor,
              activeTrackColor: selectedColor.withOpacity(0.5),
              inactiveThumbColor: selectedColor,
              value: enabled,
              onChanged: (value) {
                setState(() {
                  enabled = value;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: Constants.defaultPadding),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Route Color"),
            GestureDetector(
              onTap: () => pickColor(context),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor
                ),
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),

        const SizedBox(height: Constants.defaultPadding),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Operating Hours:'),
                Text(formatTime([selectedRange.start.round(), selectedRange.end.round()]))
              ],
            ),
            RangeSlider(
              activeColor: selectedColor,
              values: selectedRange,
              min: 0,
              max: 1440,
              divisions: 48,
              onChanged: (RangeValues values) {
                if (values.start <= values.end) {
                  setState(() {
                    selectedRange = values;
                  });
                } else {
                  setState(() {
                    selectedRange = RangeValues(values.start, values.start);
                  });
                }
              },
            ),
          ],
        ),

        const SizedBox(height: Constants.defaultPadding),

        Button(onTap: update, text: "Save",),

      ],
    );
  }
}
