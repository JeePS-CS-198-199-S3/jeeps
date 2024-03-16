import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/models/jeep_model.dart';

import '../../../models/route_model.dart';
import '../../../style/constants.dart';
import '../../../style/style.dart';
import '../../text_field.dart';
import '../../button.dart';

class EditJeep extends StatefulWidget {
  final RouteData route;
  final JeepData jeepData;
  const EditJeep({super.key, required this.route, required this.jeepData});

  @override
  State<EditJeep> createState() => _EditJeepState();
}

class _EditJeepState extends State<EditJeep> {
  final jeepNameController = TextEditingController();
  final jeepCapacityController = TextEditingController();

  late String currentName;

  @override
  void initState() {
    super.initState();

    setState(() {
      currentName = widget.jeepData.device_id;
      jeepNameController.text = widget.jeepData.device_id;
      jeepCapacityController.text = widget.jeepData.max_capacity.toString();
    });
  }

  @override
  void didUpdateWidget(covariant EditJeep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if route choice changed
    if (widget.jeepData.device_id != currentName) {
      setState(() {
        currentName = widget.jeepData.device_id;
      });
    }
  }

  void editJeep() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    // feedback field is not empty
    if (jeepNameController.text.isNotEmpty) {
      if (jeepCapacityController.text.isNotEmpty &&
          int.parse(jeepCapacityController.text) > 0) {
        try {
          // Get reference to Firestore collection
          CollectionReference jeepsCollection =
              FirebaseFirestore.instance.collection('jeeps_realtime');

          // Query Firestore for documents where 'device_id' is equal to given deviceId
          QuerySnapshot querySnapshot = await jeepsCollection
              .where('device_id',
                  isEqualTo: jeepNameController.text.toUpperCase())
              .get();

          // Check if any documents exist matching the query
          if ((jeepNameController.text != currentName &&
                  querySnapshot.docs.isEmpty) ||
              jeepNameController.text == currentName) {
            Map<String, dynamic> newJeepSettings = {
              'device_id': jeepNameController.text.toUpperCase(),
              'max_capacity': int.parse(jeepCapacityController.text)
            };

            // Query Firestore for documents where 'device_id' is equal to given deviceId
            QuerySnapshot querySnapshot2 = await jeepsCollection
                .where('device_id', isEqualTo: currentName)
                .get();
            await jeepsCollection
                .doc(querySnapshot2.docs.first.id)
                .update(newJeepSettings)
                .then((value) => Navigator.pop(context))
                .then((value) => Navigator.pop(context));
            errorMessage("Success!");
          } else {
            Navigator.pop(context);
            errorMessage("Plate Number already exists.");
          }
        } catch (e) {
          Navigator.pop(context);
          errorMessage(e.toString());
        }
      } else {
        // pop loading circle
        Navigator.pop(context);
        errorMessage("Input PUV Maximum Capacity");
      }
    } else {
      // pop loading circle
      Navigator.pop(context);

      // password dont match
      errorMessage("Input PUV Plate Number");
    }
    // try sign up
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
                style: const TextStyle(color: Colors.white),
              )));
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              PrimaryText(
                text: "Edit PUV",
                color: Colors.white,
                size: 40,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
          const Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Route"),
              Row(
                children: [
                  Text(widget.route.routeName),
                  const SizedBox(width: Constants.defaultPadding / 2),
                  Icon(Icons.circle, color: Color(widget.route.routeColor))
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: jeepNameController,
              hintText: "Plate Number",
              obscureText: false),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: jeepCapacityController,
              hintText: "Max Capacity",
              obscureText: false,
              type: TextInputType.number),
          const SizedBox(height: Constants.defaultPadding),
          const Divider(color: Colors.white),
          const SizedBox(height: Constants.defaultPadding),
          Button(
            onTap: () => editJeep(),
            text: "Save",
          ),
        ],
      ),
    );
  }
}
