import 'package:flutter/material.dart';
import 'package:transitrack_web/style/constants.dart';

class LiveTestInstructions extends StatelessWidget {
  const LiveTestInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '1. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Realtime GPS Location] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text:
                    "In the left menu, you will see the different routes. Select ",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Ikot',
                style: TextStyle(
                  color: Colors.yellow,
                ),
              ),
              TextSpan(
                text:
                    ' to view the ikot PUVs in realtime. Please do note that you are seeing simulated PUVs for the sake of this testing.',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.defaultPadding,
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '2. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Fare Matrix] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text:
                    "You can see the base fare price for every route. Tap on the discounted fare to toggle the fare price for students, PWDs, and senior citizens.",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.defaultPadding,
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '3. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Basic PUV Information] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text:
                    "In the map view, tap on any PUV. You will see relevant information at the bottom part of the screen like driver, plate number, etc.",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.defaultPadding,
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '4. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Passenger Counting] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text: "You can also see the passenger capacity of the PUV.",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.defaultPadding,
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '5. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Rough Time Estimation] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text:
                    "There is also rough time estimation between you and the PUV. The path is represented by the white dashed line.",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.defaultPadding,
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '6. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Feedback System] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text:
                    "You can see a Feedback button on the PUV details. You may create a feedback.",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.defaultPadding,
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '7. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Report System] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text:
                    "You can see a Report button on the PUV details. You may issue a report.",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.defaultPadding,
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '8. ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '[Passenger Demand System] ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text:
                    "You can see a location icon button at the bottom right corner of the screen. This will allow you to momentarily broadcast your location to alert PUV drivers that you are in need of their service.",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
