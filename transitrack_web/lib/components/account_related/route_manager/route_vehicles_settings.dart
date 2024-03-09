import 'package:flutter/material.dart';

import '../../../models/jeep_model.dart';
import '../../../models/route_model.dart';
import 'register_jeep.dart';
import '../../../style/constants.dart';
import '../../button.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class VehiclesSettings extends StatefulWidget {
  final RouteData route;
  final List<JeepData> jeeps;
  final ValueChanged<bool> isHover;

  const VehiclesSettings(
      {super.key,
      required this.route,
      required this.jeeps,
      required this.isHover});

  @override
  State<VehiclesSettings> createState() => _VehiclesSettingsState();
}

class _VehiclesSettingsState extends State<VehiclesSettings> {
  List<JeepData>? _jeeps;

  @override
  void initState() {
    super.initState();

    setState(() {
      _jeeps = widget.jeeps;
    });
  }

  @override
  void didUpdateWidget(covariant VehiclesSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if jeepney changed
    if (widget.jeeps != _jeeps) {
      setState(() {
        _jeeps = widget.jeeps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Plate #'),
          Text("Active"),
        ]),
        const SizedBox(height: Constants.defaultPadding),
        Expanded(
          child: ListView.builder(
            itemCount: _jeeps!.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const Divider(color: Constants.white),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Constants.defaultPadding / 2),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_jeeps![index].device_id),
                          Icon(Icons.circle,
                              color: _jeeps![index].is_active
                                  ? Colors.green
                                  : Colors.red),
                        ]),
                  ),
                  if (index == _jeeps!.length - 1)
                    const Divider(color: Colors.white),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: Constants.defaultPadding),
        Button(
            onTap: () {
              AwesomeDialog(
                dialogType: DialogType.noHeader,
                context: (context),
                width: 500,
                body: MouseRegion(
                  onEnter: (_) => widget.isHover(true),
                  onExit: (_) => widget.isHover(false),
                  child: RegisterJeep(
                    route: widget.route,
                  ),
                ),
              ).show();
            },
            text: '+',
            color: Color(widget.route.routeColor),
            isMobile: true)
      ]),
    );
  }
}