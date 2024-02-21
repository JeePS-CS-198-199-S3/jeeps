import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../MenuController.dart';

import '../components/account_related/account_stream.dart';
import '../components/cooldown_button.dart';
import '../components/header.dart';
import '../components/logo.dart';
import '../components/map_related/map.dart';
import '../components/drawer_list_tile.dart';
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

  // Route Selection
  int routeChoice = -1;

  @override
  void initState() {
    super.initState();
    currentUserAuth = FirebaseAuth.instance.currentUser;
    listenToUserAuth();
    fetchRoutes();
  }

  void hovering() {
    setState(() {
      isHover = !isHover;
    });
  }

  void switchRoute(int choice) {
    setState(() {
      routeChoice = choice;
    });
  }

  void listenToUserAuth() async {
    userAuthStream = FirebaseAuth.instance
      .authStateChanges()
      .listen((user) {
        setState(() {
          currentUserAuth = user;
        });
        listenToUserFirestore();
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
        shape: const Border(),
        elevation: 0.0,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DrawerHeader(
                child: Logo()
              ),

              const SizedBox(height: Constants.defaultPadding),

              AccountStream(
                hoverToggle: hovering,
                currentUser: currentUserAuth,
                user: currentUserFirestore,
                isDesktop: false
              ),

              const SizedBox(height: Constants.defaultPadding),

              Container(
                  padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                  child: const Divider()
              ),

              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (routeChoice == index) {
                          switchRoute(-1);
                        } else {
                          switchRoute(index);
                        }
                      },
                      child: DrawerListTile(
                        Route: _routes[index],
                        isSelected: routeChoice == index,
                      ),
                    );
                  },
                )
              )
            ],
          ),
        )
      ),
      body:  SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                if (Responsive.isDesktop(context))
                  const Spacer(flex: 1),

                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: MapWidget(isHover: isHover)
                      ),

                      if (Responsive.isMobile(context))
                        const SizedBox(height: 220)
                    ],
                  )
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(Responsive.isDesktop(context))
                  Expanded(
                    flex: 1,
                    child: Drawer(
                      shape: const Border(),
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
                              isDesktop: true
                            ),

                            const SizedBox(height: Constants.defaultPadding),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                              child: const Divider()
                            ),

                            SizedBox(
                                height: 500,
                                child: ListView.builder(
                                  itemCount: _routes.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (routeChoice == index) {
                                          switchRoute(-1);
                                        } else {
                                          switchRoute(index);
                                        }
                                      },
                                      child: DrawerListTile(
                                          Route: _routes[index],
                                          isSelected: routeChoice == index,
                                      ),
                                    );
                                  },
                                )
                            ),

                            Text("Selected route: $routeChoice")
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
            
            if (Responsive.isMobile(context) && currentUserAuth != null && currentUserFirestore != null)
              Positioned(
                bottom: Constants.defaultPadding/2,
                right: Constants.defaultPadding/2,
                child: CooldownButton(onPressed: () {print("pressed");}, verified: currentUserFirestore!.is_verified, child: const Icon(Icons.location_on))
              )
          ],
        ),
      ),
    );
  }
}