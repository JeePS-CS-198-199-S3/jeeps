import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/models/jeep_model.dart';

import '../../../style/constants.dart';
import '../../../style/style.dart';
import '../../button.dart';

// This widget allows the route manager to deletea PUV

class DeleteJeep extends StatefulWidget {
  final JeepData jeepData;
  const DeleteJeep({super.key, required this.jeepData});

  @override
  State<DeleteJeep> createState() => _DeleteJeepState();
}

class _DeleteJeepState extends State<DeleteJeep> {
  late JeepData _jeepData;

  @override
  void initState() {
    super.initState();

    setState(() {
      _jeepData = widget.jeepData;
    });
  }

  @override
  void didUpdateWidget(covariant DeleteJeep oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.jeepData.device_id != _jeepData.device_id) {
      setState(() {
        _jeepData = widget.jeepData;
      });
    }
  }

  void deleteJeep() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      // Get reference to Firestore collection
      CollectionReference jeepsCollection =
          FirebaseFirestore.instance.collection('jeeps_realtime');

      // Query Firestore for documents where 'device_id' is equal to given deviceId
      QuerySnapshot querySnapshot = await jeepsCollection
          .where('device_id', isEqualTo: _jeepData.device_id)
          .get();

      await jeepsCollection
          .doc(querySnapshot.docs.first.id)
          .delete()
          .then((value) => Navigator.pop(context))
          .then((value) => Navigator.pop(context));
      errorMessage("Success!");
    } catch (e) {
      Navigator.pop(context);
      errorMessage(e.toString());
    }
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
                text: "Delete PUV",
                color: Colors.white,
                size: 40,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
          const Divider(color: Colors.white),
          Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Constants.defaultPadding),
              height: 100,
              child: Center(
                child: Text(
                  "You are about to delete PUV with plate number\n\n${_jeepData.device_id}.",
                  textAlign: TextAlign.center,
                ),
              )),
          const Divider(color: Colors.white),
          const SizedBox(height: Constants.defaultPadding),
          Button(
            onTap: () => deleteJeep(),
            text: "Confirm and Delete",
          ),
        ],
      ),
    );
  }
}
