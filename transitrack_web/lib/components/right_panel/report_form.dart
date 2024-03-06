import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/account_model.dart';
import '../../models/jeep_model.dart';
import '../../models/report_model.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';
import '../../style/style.dart';
import '../button.dart';
import '../text_field.dart';

class ReportForm extends StatefulWidget {
  AccountData driver;
  AccountData? user;
  JeepData jeep;
  RouteData route;
  ReportForm({super.key,
    required this.user,
    required this.driver,
    required this.jeep,
    required this.route
  });

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final reportController = TextEditingController();

  String reportType = "Lost Item";

  void sendReport() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator()
          );
        }
    );

    // feedback field is not empty
    if (reportController.text.isNotEmpty) {
      try {
        // Add a new document with auto-generated ID
        await FirebaseFirestore.instance.collection('reports').add({
          'report_sender': widget.user!.account_email,
          'report_recepient': widget.driver.account_email,
          'report_jeepney': widget.jeep.device_id,
          'timestamp': FieldValue.serverTimestamp(),
          'report_content': reportController.text,
          'report_type': ReportData.reportTypeMap[reportType],
          'report_location': widget.jeep.location
        }).then((value) => Navigator.pop(context)).then((value) => Navigator.pop(context));

        errorMessage("Success!");
      } catch (e) {
        // pop loading circle
        Navigator.pop(context);
        errorMessage(e.toString());
      }
    } else {
      // pop loading circle
      Navigator.pop(context);

      // password dont match
      errorMessage("Feedback field is empty!");
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
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  )
              )
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              PrimaryText(text: "Report", color: Colors.white, size: 40, fontWeight: FontWeight.w700,)
            ],
          ),

          const Divider(color: Colors.white),

          const SizedBox(height: Constants.defaultPadding),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Route"),
              Row(
                children: [
                  Text(widget.route.routeName),

                  const SizedBox(width: Constants.defaultPadding/2),

                  Icon(Icons.circle, color: Color(widget.route.routeColor))
                ],
              ),
            ],
          ),

          const SizedBox(height: Constants.defaultPadding),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Driver"),
              Text(widget.driver.account_name),
            ],
          ),

          const SizedBox(height: Constants.defaultPadding),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Plate Number"),
              Text(widget.jeep.device_id),
            ],
          ),

          const SizedBox(height: Constants.defaultPadding),

          const Divider(color: Colors.white),

          const SizedBox(height: Constants.defaultPadding/2),

          const Text("Report Type"),

          const SizedBox(height: 5),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding/2, vertical: 4),
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.white, // Set border color here
                width: 1, // Set border width here
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: reportType, // Initial value
                onChanged: (String? newValue) {
                  // Handle dropdown value change
                  if (newValue != null) {
                    setState(() {
                      reportType = newValue;
                    });
                  }
                },
                items: ReportData.reportTypeMap.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: reportController, hintText: "Report", obscureText: false, lines: 4, limit: 150),

          const SizedBox(height: Constants.defaultPadding),

          Button(onTap: () => sendReport(), text: "Send Report",),

        ],
      ),
    );
  }
}
