import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../MenuController.dart';

import '../components/account_related/account_stream.dart';
import '../components/header.dart';
import '../components/logo.dart';
import '../components/map_related/map.dart';
import '../components/route_list.dart';
import '../config/responsive.dart';
import '../config/size_config.dart';
import '../models/account_model.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isHover = false;
  List<RouteData> _routes = [];

  // Account Detection
  User? currentUserAuth;
  AccountData? currentUserFirestore;
  late StreamSubscription<User?> userAuthStream;                // Firebase Auth
  late StreamSubscription userFirestoreStream;   // Firebase Firestore Account



  void hovering() {
    setState(() {
      isHover = !isHover;
    });
  }

  @override
  void initState() {
    super.initState();
    currentUserAuth = FirebaseAuth.instance.currentUser;
    listenToUserAuth();
    listenToUserFirestore();
    fetchRoutes();
  }

  void listenToUserAuth() {
    userAuthStream = FirebaseAuth.instance
      .authStateChanges()
      .listen((user) {
        setState(() {
          currentUserAuth = user;
        });
      },
      onError: (e) {
        print('Error listening to authentication state changes: $e');
      }
    );
  }

  void listenToUserFirestore() {
    userFirestoreStream = FirebaseFirestore.instance
      .collection('accounts')
      .where('account_email', isEqualTo: currentUserAuth?.email!)
      .snapshots()
      .listen((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            currentUserFirestore = AccountData.fromSnapshot(snapshot.docs.first);
          });
        }
    });
  }

  void fetchRoutes() async {
    // Fetch data from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('routes')
        .where('enabled', isEqualTo: true)
        .orderBy('route_id')
        .get();
    setState(() {
      _routes = snapshot.docs
          .map((doc) => RouteData.fromFirestore(doc))
          .toList();
    });
  }

  @override
  void dispose() {
    userAuthStream.cancel();
    userFirestoreStream.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuControllers>().scaffoldKey,
      drawer: Drawer(
        elevation: 0.0,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DrawerHeader(
                child: Logo()
              ),
              // DrawerListTile(
              //     Route: JeepRoutes[0],
              //     icon: Image.asset(JeepSide[0]),
              //     isSelected: route_choice == 0,
              //     press: (){
              //       if(route_choice == 0){
              //         switchRoute(-1);
              //       } else {
              //         setState(() {
              //           _isLoaded = false;
              //         });
              //         switchRoute(0);
              //       }
              //     }),

              const SizedBox(height: Constants.defaultPadding),

              AccountStream(
                hoverToggle: hovering,
                currentUser: currentUserAuth,
                user: currentUserFirestore,
              ),

              const SizedBox(height: Constants.defaultPadding),

              Container(
                  padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                  child: const Divider()
              ),

              RouteListWidget(routes: _routes),
            ],
          ),
        )
      ),
      body:  SafeArea(
        child: Stack(
          children: [
            MapWidget(isHover: isHover),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(Responsive.isDesktop(context))
                  Expanded(
                    flex: 1,
                    child: Drawer(
                      elevation: 0.0,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const DrawerHeader(
                              child: Logo(),
                            ),
                            const SizedBox(height: Constants.defaultPadding),

                            AccountStream(
                              hoverToggle: hovering,
                              currentUser: currentUserAuth,
                              user: currentUserFirestore,
                            ),

                            const SizedBox(height: Constants.defaultPadding),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                              child: const Divider()
                            ),

                            RouteListWidget(routes: _routes),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: SizeConfig.screenHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: !Responsive.isMobile(context)
                                  ? const Header()
                                  : Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                            height: 220,
                                            decoration: const BoxDecoration(
                                              color: Constants.secondaryColor,
                                            ),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.all(Constants.defaultPadding),
                                                            child: const Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    "Select a route",
                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  Text(
                                                                    "press the menu icon at the top left\npart of the screen!",
                                                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ]
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  bottom: -50,
                                                  right: -40,
                                                  child: Transform.rotate(
                                                      angle: -15 * 3.1415926535 / 180, // Rotate 45 degrees counter-clockwise (NW direction)
                                                      child: const Icon(Icons.touch_app_rounded, color: Colors.white12, size: 270)
                                                  ),
                                                ),
                                              ],
                                            )
                                        )
                                      ]
                                    ),
                                    const Header(),
                                  ]
                              ),
                            ),
                            if(!Responsive.isMobile(context))
                              const SizedBox(width: Constants.defaultPadding),
                            if(!Responsive.isMobile(context))
                              SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.all(Constants.defaultPadding),
                                          decoration: const BoxDecoration(
                                            color: Constants.secondaryColor,
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(Constants.defaultPadding),
                                            decoration: const BoxDecoration(
                                              color: Constants.secondaryColor,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: const Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Select a route",
                                                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: Constants.defaultPadding),
                                                SizedBox(
                                                  height:200,
                                                  child: Center(child: CircleAvatar(
                                                    radius: 90,
                                                    backgroundColor: Colors.white38,
                                                    child: CircleAvatar(
                                                        radius: 70,
                                                        backgroundColor: Constants.secondaryColor,
                                                        child: Icon(Icons.touch_app_rounded, color: Colors.white38, size: 50)
                                                    ),
                                                  )),
                                                ),
                                                SizedBox(height: Constants.defaultPadding),
                                              ],
                                            ),
                                          )
                                      ),
                                    ],
                                  )
                              )
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}