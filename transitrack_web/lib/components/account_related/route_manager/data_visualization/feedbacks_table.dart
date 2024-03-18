import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transitrack_web/models/account_model.dart';
import 'package:transitrack_web/models/feedback_model.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/style/constants.dart';

class FeedbacksTable extends StatefulWidget {
  final RouteData route;
  const FeedbacksTable({super.key, required this.route});

  @override
  State<FeedbacksTable> createState() => _FeedbacksTableState();
}

class FeedbackAdditionalInfo {
  AccountData senderData;
  AccountData recepientData;

  FeedbackAdditionalInfo({
    required this.senderData,
    required this.recepientData,
  });
}

class _FeedbacksTableState extends State<FeedbacksTable> {
  TextEditingController searchController = TextEditingController();

  int selected = -1;

  List<FeedbackData>? feedbacks;

  String searchString = "";

  @override
  void initState() {
    super.initState();

    loadFeedbacks();
  }

  void select(int index) {
    setState(() {
      selected = index;
    });
  }

  Future<void> loadFeedbacks() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('feedbacks')
        .where('feedback_route', isEqualTo: widget.route.routeId)
        .get();

    setState(() {
      feedbacks = querySnapshot.docs.map((DocumentSnapshot document) {
        return FeedbackData.fromFirestore(document);
      }).toList();
    });
  }

  Future<FeedbackAdditionalInfo?> loadFeedbackDetails(
      String sender, String recepient) async {
    AccountData? senderData = await AccountData.getAccountByEmail(sender);
    AccountData? recepientData = await AccountData.getAccountByEmail(recepient);

    if (senderData != null && recepientData != null) {
      return FeedbackAdditionalInfo(
          senderData: senderData, recepientData: recepientData);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
        child: Column(
          children: [
            SearchBar(
              controller: searchController,
              overlayColor:
                  MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
              elevation: MaterialStateProperty.all(0.0),
              onChanged: (String value) {
                setState(() {
                  searchString = value;
                });
              },
              hintText: 'Search feedback content',
              hintStyle: MaterialStateProperty.all(
                  TextStyle(color: Color(widget.route.routeColor))),
              leading: const Icon(Icons.search),
              shape: MaterialStateProperty.all(const ContinuousRectangleBorder(
                borderRadius: BorderRadius.zero,
              )),
              trailing: <Widget>[
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          feedbacks = null;
                        });
                        select(-1);
                        loadFeedbacks();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list),
                    )
                  ],
                )
              ],
            ),
            if (feedbacks == null)
              SizedBox(
                  height: 500,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Color(widget.route.routeColor),
                  ))),
            if (feedbacks != null)
              ListView.builder(
                shrinkWrap: true,
                itemCount: feedbacks!.length,
                itemBuilder: (context, index) {
                  FeedbackData feedback = feedbacks![index];
                  bool isSelected = index == selected;

                  if (searchString.isNotEmpty &&
                      !feedback.feedback_content
                          .toLowerCase()
                          .contains(searchString.toLowerCase())) {
                    return const SizedBox();
                  }
                  return ListTile(
                    onTap: () {
                      if (selected == index) {
                        select(-1);
                      } else {
                        select(index);
                      }
                    },
                    selected: isSelected,
                    selectedColor: Colors.white,
                    selectedTileColor:
                        Color(widget.route.routeColor).withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.2),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '"${feedback.feedback_content}"',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(width: Constants.defaultPadding),
                        Text(DateFormat('MMMM d, y')
                            .format(feedback.timestamp.toDate()))
                      ],
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Driver"),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index <
                                                  feedback
                                                      .feedback_driving_rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: index <
                                                  feedback
                                                      .feedback_driving_rating
                                              ? Color(widget.route.routeColor)
                                              : Colors.grey,
                                          size: 20,
                                        );
                                      }),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: Constants.defaultPadding * 2),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Jeepney"),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index <
                                                  feedback
                                                      .feedback_jeepney_rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: index <
                                                  feedback
                                                      .feedback_jeepney_rating
                                              ? Color(widget.route.routeColor)
                                              : Colors.grey,
                                          size: 20,
                                        );
                                      }),
                                    )
                                  ],
                                ),
                              ),
                            ]),
                        if (isSelected)
                          Column(
                            children: [
                              const Divider(color: Colors.white),
                              FutureBuilder(
                                  future: loadFeedbackDetails(
                                      feedback.feedback_sender,
                                      feedback.feedback_recepient),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                            color:
                                                Color(widget.route.routeColor)),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Center(
                                        child: Text(
                                            'Feedback Details cannot be recovered.'),
                                      );
                                    }

                                    FeedbackAdditionalInfo
                                        feedbackAdditionalInfo = snapshot.data!;

                                    return SizedBox(
                                      width: double.maxFinite,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Feedback by ${feedbackAdditionalInfo.senderData.account_name} (${feedback.feedback_sender})'),
                                          const SizedBox(
                                              height: Constants.defaultPadding),
                                          RichText(
                                              textAlign: TextAlign.justify,
                                              text: TextSpan(
                                                children: [
                                                  const WidgetSpan(
                                                      child: SizedBox(
                                                          width: 40.0)),
                                                  TextSpan(
                                                      text:
                                                          '"${feedback.feedback_content}"',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          fontWeight:
                                                              FontWeight.w200)),
                                                ],
                                              )),
                                          const SizedBox(
                                              height: Constants.defaultPadding),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Driver"),
                                              const SizedBox(
                                                  width:
                                                      Constants.defaultPadding),
                                              Expanded(
                                                child: Text(
                                                  '${feedbackAdditionalInfo.recepientData.account_name} (${feedback.feedback_recepient})',
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                              height:
                                                  Constants.defaultPadding / 2),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("PUV"),
                                              const SizedBox(
                                                  width:
                                                      Constants.defaultPadding),
                                              Expanded(
                                                child: Text(
                                                  feedback.feedback_jeepney,
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                              const Divider(color: Colors.white),
                            ],
                          )
                      ],
                    ),
                  );
                },
              ),
          ],
        ));
  }
}
