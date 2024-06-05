import 'package:flutter/material.dart';
import 'package:transitrack_web/components/left_drawer/live_test_instructions.dart';
import 'package:transitrack_web/style/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileResearch extends StatefulWidget {
  final Function pin;
  const MobileResearch({super.key, required this.pin});

  @override
  State<MobileResearch> createState() => _MobileResearchState();
}

class _MobileResearchState extends State<MobileResearch> {
  List<Widget> pages = [];
  int page = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      pages = [
        Column(
          children: [
            const Text(
                "We are studying the effectiveness of JeePS in improving the commute experience in UP Diliman."),
            const SizedBox(
              height: Constants.defaultPadding,
            ),
            const Text("5 random respondents will be rewarded 200 pesos! To qualify, make sure you fill up the pretest and post test forms with your email."),
            const Divider(color: Colors.white),
            Row(
              children: [
                const Text("Step 1: Fill out our pretest survey "),
                GestureDetector(
                  onTap: () {
                    _launchURL("https://forms.gle/QbrdVAWe3HuMrKwP7");
                  },
                  child: const Text(
                    'here!',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 500,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const Text("Step 2: Explore the JeePS app!"),
                const SizedBox(
                  height: Constants.defaultPadding,
                ),
                const Text(
                    "Follow the instructions down below.\n\nCreate a commuter account, have it verified, log in, and make sure location tracking is enabled!"),
                const SizedBox(
                  height: Constants.defaultPadding,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Pin instructions to dashboard"),
                    IconButton(
                        onPressed: () => widget.pin(),
                        icon: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 24,
                          child: Icon(
                            Icons.pin_invoke,
                            color: Constants.bgColor,
                          ),
                        ))
                  ],
                ),
                const Divider(color: Colors.white),
                const LiveTestInstructions()
              ],
            ),
          ),
        ),
        Column(
          children: [
            const Text(
                "Great! You have experienced the features intended for the commuters."),
            const SizedBox(
              height: Constants.defaultPadding,
            ),
            const Text("Please use the same email for this step."),
            const Divider(color: Colors.white),
            Row(
              children: [
                const Text("Step 3: Fill out our post test survey "),
                GestureDetector(
                  onTap: () {
                    _launchURL("https://forms.gle/B8oFDn7DYUfAxDoL8");
                  },
                  child: const Text(
                    'here!',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ];
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(Constants.defaultPadding)),
      child: Column(
        children: [
          pages[page],
          const SizedBox(height: Constants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: IconButton(
                    onPressed: () {
                      if (page > 0) {
                        setState(() {
                          page--;
                        });
                      }
                    },
                    icon: Icon(Icons.arrow_back)),
              ),
              Expanded(
                child: IconButton(
                    onPressed: () {
                      if (page < pages.length - 1) {
                        setState(() {
                          page++;
                        });
                      }
                    },
                    icon: Icon(Icons.arrow_forward)),
              )
            ],
          )
        ],
      ),
    );
  }
}
