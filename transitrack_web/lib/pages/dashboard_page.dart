import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import '../MenuController.dart';

import '../components/account_related/account_stream.dart';
import '../components/cooldown_button.dart';
import '../components/header.dart';
import '../components/left_drawer/logo.dart';
import '../components/map_related/map.dart';
import '../components/right_panel/mobile_dashboard_unselected.dart';
import '../components/right_panel/mobile_route_info.dart';
import '../components/left_drawer/route_list.dart';
import '../config/responsive.dart';
import '../config/size_config.dart';
import '../models/account_model.dart';
import '../models/jeep_model.dart';
import '../models/ping_model.dart';
import '../models/route_model.dart';
import '../services/send_ping.dart';
import '../style/constants.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool drawerOpen = false;

  // Account Detection
  User? currentUserAuth;
  AccountData? currentUserFirestore;
  List<RouteData> _routes = [];
  List<JeepData> jeeps = [];
  late StreamSubscription<User?> userAuthStream;                // Firebase Auth
  late StreamSubscription userFirestoreStream;                  // Firebase Firestore Accounts
  late StreamSubscription routesFirestoreStream;                // Firebase Firestore Routes
  late StreamSubscription jeepsFirestoreStream;

  // Route Selection
  int routeChoice = -1;

  // Device Location Found
  LatLng? deviceLoc;

  // Ensure map is loaded
  bool mapLoaded = false;

  JeepData? selectedJeepMobile = null;

  @override
  void initState() {
    super.initState();
    currentUserAuth = FirebaseAuth.instance.currentUser;
    listenToUserAuth();
    listenToRoutesFirestore();
  }

  void hovering() {
    setState(() {
      drawerOpen = !drawerOpen;
    });
  }

  void switchRoute(int choice) {
    if (routeChoice != -1) {
      jeepsFirestoreStream.cancel();
    }

    setState((){
      routeChoice = choice;
    });

    if (routeChoice != -1) {
      listenToJeepsFirestore();
    } else {
      jeepsFirestoreStream.cancel();
    }
  }

  void listenToUserAuth() async {
    userAuthStream = FirebaseAuth.instance
      .authStateChanges()
      .listen((user) {
        setState(() {
          currentUserAuth = user;
        });

        if (currentUserAuth != null) {
          listenToUserFirestore();
        } else {
          setState(() {
            currentUserFirestore = null;
          });
        }

        if (routeChoice != -1) {
          switchRoute(-1);
        }

      },
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
     }
    );
  }

  void listenToRoutesFirestore() {
    routesFirestoreStream = FirebaseFirestore.instance
      .collection('routes')
      .orderBy('route_id')
      .snapshots()
      .listen((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _routes = snapshot.docs
              .map((doc) => RouteData.fromFirestore(doc))
              .toList();
          });
        }
      }
    );
  }
  
  void listenToJeepsFirestore() {
    jeepsFirestoreStream = FirebaseFirestore.instance
      .collection('jeeps_realtime')
      .where('route_id', isEqualTo: routeChoice)
      .snapshots()
      .listen((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            jeeps = snapshot.docs
              .map((doc) => JeepData.fromSnapshot(doc))
              .toList();
          });
        }
    });
  }

  @override
  void dispose() {
    userAuthStream.cancel();
    userFirestoreStream.cancel();
    routesFirestoreStream.cancel();
    jeepsFirestoreStream.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (isOpened) {
        setState((){
          drawerOpen = isOpened;
        });
      },
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

              if (!mapLoaded || _routes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Constants.defaultPadding),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (mapLoaded && _routes.isNotEmpty)
              RouteList(
                routeChoice: routeChoice,
                routes: _routes,
                newRouteChoice: (int choice) {
                  if (routeChoice == choice) {
                    switchRoute(-1);
                  } else {
                    switchRoute(choice);
                  }
                },
                hoverToggle: hovering
              ),



              Container(
                  padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                  child: const Divider()
              ),

              const SizedBox(height: Constants.defaultPadding),

              AccountStream(
                hoverToggle: hovering,
                currentUser: currentUserAuth,
                user: currentUserFirestore,
                deviceLoc: deviceLoc,
                admin: currentUserFirestore != null
                    && currentUserFirestore!.is_verified
                    && currentUserFirestore!.route_id >= 0
                      ? "${_routes[currentUserFirestore!.route_id].routeName} "
                      : "",
                route: routeChoice,
              ),

              const SizedBox(height: Constants.defaultPadding)
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

                            if (!mapLoaded || _routes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: Constants.defaultPadding),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),

                            if (mapLoaded && _routes.isNotEmpty)
                              RouteList(
                                  routeChoice: routeChoice,
                                  routes: _routes,
                                  newRouteChoice: (int choice) {
                                    if (routeChoice == choice) {
                                      switchRoute(-1);
                                    } else {
                                      switchRoute(choice);
                                    }
                                  },
                                  hoverToggle: hovering
                              ),

                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                                child: const Divider()
                            ),

                            const SizedBox(height: Constants.defaultPadding),

                            AccountStream(
                              hoverToggle: hovering,
                              currentUser: currentUserAuth,
                              user: currentUserFirestore,
                              deviceLoc: deviceLoc,
                              admin: currentUserFirestore != null
                                  && currentUserFirestore!.is_verified
                                  && currentUserFirestore!.route_id >= 0
                                  ? "${_routes[currentUserFirestore!.route_id].routeName} "
                                  : "",
                              route: routeChoice,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  flex: 5,
                  child: Stack(
                      children: [
                        MapWidget(
                          isDrawer: drawerOpen,
                          route: routeChoice == -1
                              ? null
                              : _routes[routeChoice],
                          jeeps: routeChoice == -1
                              ? null
                              : jeeps,
                          foundDeviceLocation: (LatLng newDeviceLocation) {
                            setState(() {
                              deviceLoc = newDeviceLocation;
                            });
                          },
                          currentUserFirestore: currentUserFirestore, mapLoaded: (bool isLoaded) => setState(() {
                          mapLoaded = isLoaded;
                        }),
                        ),

                        if (!Responsive.isDesktop(context))
                          const Header(),
                      ]
                  ),
                )
              ],
            ),

            if (Responsive.isMobile(context) && currentUserAuth != null && currentUserFirestore != null)
              Positioned(
                bottom: Constants.defaultPadding/2,
                right: Constants.defaultPadding/2,
                child: CooldownButton(
                    onPressed: () {
                      sendPing(
                        PingData(
                            ping_email: currentUserAuth!.email!,
                            ping_location: deviceLoc!,
                            ping_route: routeChoice
                        )
                      );
                    },
                    alert: "We have broadcasted your location.",
                    verified: currentUserFirestore!.is_verified && deviceLoc != null && routeChoice != -1,
                    child: deviceLoc != null
                      ? const Icon(Icons.location_on)
                      : const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Constants.bgColor,
                        )
                      )
                    )

              )
          ],
        ),
      ),
    );
  }
}