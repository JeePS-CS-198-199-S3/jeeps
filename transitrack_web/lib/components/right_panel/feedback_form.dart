import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/account_model.dart';
import '../../models/feedback_model.dart';
import '../../models/jeep_model.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';
import '../../style/style.dart';
import '../button.dart';
import '../text_field.dart';

class FeedbackForm extends StatefulWidget {
  AccountData driver;
  AccountData? user;
  JeepData jeep;
  RouteData route;
  FeedbackForm({super.key,
    required this.user,
    required this.driver,
    required this.jeep,
    required this.route
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {

  final feedBackController = TextEditingController();

  int _rating = -1;

  String feedbackType = "Both";

  void sendFeedback() async {
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
    if (feedBackController.text.isNotEmpty) {
      if (_rating != -1) {
        try {
          // Add a new document with auto-generated ID
          await FirebaseFirestore.instance.collection('feedbacks').add({
            'feedback_sender': widget.user!.account_email,
            'feedback_recepient': widget.driver.account_email,
            'feedback_jeepney': widget.jeep.device_id,
            'timestamp': FieldValue.serverTimestamp(),
            'feedback_content': feedBackController.text,
            'feedback_rating': _rating,
            'feedback_type': FeedbackData.feedbackTypeMap[feedbackType]
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

        errorMessage("You need to rate!");
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
              PrimaryText(text: "Feedback", color: Colors.white, size: 40, fontWeight: FontWeight.w700,)
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
              const Text("Plate Number"),
              Text(widget.jeep.device_id),
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

          const Divider(color: Colors.white),

          const SizedBox(height: Constants.defaultPadding),

          const Text("Driving Quality"),

          if (_rating != -1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Color(widget.route.routeColor),
                    size: 40,
                  ),
                  onPressed: () {
                    if (_rating == index + 1) {
                      setState(() {
                        _rating = -1;
                      });
                    } else {
                      setState(() {
                        _rating = index + 1;
                      });
                    }
                  },
                );
              }),
            ),

          if (_rating == -1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(
                    Icons.star_border,
                    color: Colors.grey,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),

          const SizedBox(height: Constants.defaultPadding),

          const Text("Vehicle Quality"),

          if (_rating != -1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Color(widget.route.routeColor),
                    size: 40,
                  ),
                  onPressed: () {
                    if (_rating == index + 1) {
                      setState(() {
                        _rating = -1;
                      });
                    } else {
                      setState(() {
                        _rating = index + 1;
                      });
                    }
                  },
                );
              }),
            ),

          if (_rating == -1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(
                    Icons.star_border,
                    color: Colors.grey,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),

          const SizedBox(height: Constants.defaultPadding),

          const Divider(color: Colors.white),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: feedBackController, hintText: "Feedback", obscureText: false, lines: 4, limit: 150),

          const SizedBox(height: Constants.defaultPadding),

          Button(onTap: () => sendFeedback(), text: "Send Feedback",),

        ],
      ),
    );
  }
}
