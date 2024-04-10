import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import '../MenuController.dart';

import '../components/account_related/account_stream.dart';
import '../components/header.dart';
import '../components/left_drawer/logo.dart';
import '../components/map_related/map.dart';
import '../components/left_drawer/route_list.dart';
import '../config/responsive.dart';
import '../models/account_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool drawerOpen = false;

  // Account Detection
  User? currentUserAuth;
  AccountData? currentUserFirestore;
  List<RouteData> _routes = [];
  List<JeepsAndDrivers> jeeps = [];
  List<AccountData?> drivers = [];
  late StreamSubscription<User?> userAuthStream; // Firebase Auth
  late StreamSubscription userFirestoreStream; // Firebase Firestore Accounts
  late StreamSubscription routesFirestoreStream; // Firebase Firestore Routes
  late StreamSubscription jeepsFirestoreStream;
  late StreamSubscription driversFirestoreStream;

  // Route Selection
  int routeChoice = -1;

  // Device Location Found
  LatLng? deviceLoc;

  // Ensure map is loaded
  bool mapLoaded = false;

  bool gpsPermission = false;

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
      driversFirestoreStream.cancel();
    }

    setState(() {
      routeChoice = choice;
    });

    if (routeChoice != -1) {
      drivers.clear();
      jeeps.clear();
      listenToDriversFirestore();
      listenToJeepsFirestore();
    } else {
      jeepsFirestoreStream.cancel();
      driversFirestoreStream.cancel();
    }
  }

  void listenToDriversFirestore() {
    driversFirestoreStream = FirebaseFirestore.instance
        .collection('accounts')
        .where('account_type', isEqualTo: 1)
        .orderBy('account_email')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          drivers = snapshot.docs
              .map((doc) => AccountData.fromSnapshot(doc))
              .toList();
        });

        List<JeepsAndDrivers> collected = [];

        for (JeepsAndDrivers jeep in jeeps) {
          bool found = drivers
              .any((driver) => driver!.jeep_driving == jeep.jeep.device_id);
          collected.add(JeepsAndDrivers(
              driver: found
                  ? drivers.firstWhere(
                      (driver) => driver!.jeep_driving == jeep.jeep.device_id)
                  : null,
              jeep: jeep.jeep));
        }
        setState(() {
          jeeps = collected;
        });
      }
    });
  }

  void listenToUserAuth() async {
    userAuthStream = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
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
          currentUserFirestore = AccountData.fromSnapshot(snapshot.docs.first,
              isCommuterVerified: currentUserAuth!.emailVerified);
        });
      }
    });
  }

  void listenToRoutesFirestore() {
    routesFirestoreStream = FirebaseFirestore.instance
        .collection('routes')
        .orderBy('route_id')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _routes =
              snapshot.docs.map((doc) => RouteData.fromFirestore(doc)).toList();
        });
      }
    });
  }

  void listenToJeepsFirestore() {
    jeepsFirestoreStream = FirebaseFirestore.instance
        .collection('jeeps_realtime')
        .where('route_id', isEqualTo: routeChoice)
        .orderBy('device_id')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<JeepsAndDrivers> collected = [];
        List<JeepData> _jeeps = [];
        setState(() {
          _jeeps =
              snapshot.docs.map((doc) => JeepData.fromSnapshot(doc)).toList();
        });
        for (JeepData _jeep in _jeeps) {
          bool found =
              drivers.any((driver) => driver!.jeep_driving == _jeep.device_id);
          collected.add(JeepsAndDrivers(
              driver: found
                  ? drivers.firstWhere(
                      (driver) => driver!.jeep_driving == _jeep.device_id)
                  : null,
              jeep: _jeep));
        }
        setState(() {
          jeeps = collected;
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
    driversFirestoreStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (isOpened) {
        setState(() {
          drawerOpen = isOpened;
        });
      },
      key: context.read<MenuControllers>().scaffoldKey,
      drawer: PointerInterceptor(
        child: Drawer(
            shape: const Border(),
            elevation: 0.0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const DrawerHeader(child: Logo()),
                  if (!mapLoaded || _routes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: Constants.defaultPadding),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (mapLoaded && _routes.isNotEmpty)
                    RouteList(
                        routeChoice: routeChoice,
                        routes: _routes,
                        user: currentUserFirestore,
                        newRouteChoice: (int choice) {
                          if (routeChoice == choice) {
                            switchRoute(-1);
                          } else {
                            switchRoute(choice);
                          }
                        },
                        hoverToggle: hovering),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Constants.defaultPadding),
                      child: const Divider()),
                  const SizedBox(height: Constants.defaultPadding),
                  AccountStream(
                    currentUser: currentUserAuth,
                    user: currentUserFirestore,
                    deviceLoc: deviceLoc,
                    admin: currentUserFirestore != null &&
                            currentUserFirestore!.is_verified &&
                            currentUserFirestore!.route_id >= 0
                        ? "${_routes[currentUserFirestore!.route_id].routeName} "
                        : "",
                    route: routeChoice,
                  ),
                  const SizedBox(height: Constants.defaultPadding)
                ],
              ),
            )),
      ),
      body: SafeArea(
        child: Row(
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
                            padding: EdgeInsets.symmetric(
                                vertical: Constants.defaultPadding),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (mapLoaded && _routes.isNotEmpty)
                          RouteList(
                              routeChoice: routeChoice,
                              routes: _routes,
                              user: currentUserFirestore,
                              newRouteChoice: (int choice) {
                                if (routeChoice == choice) {
                                  switchRoute(-1);
                                } else {
                                  switchRoute(choice);
                                }
                              },
                              hoverToggle: hovering),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Constants.defaultPadding),
                            child: const Divider()),
                        const SizedBox(height: Constants.defaultPadding),
                        AccountStream(
                          currentUser: currentUserAuth,
                          user: currentUserFirestore,
                          deviceLoc: deviceLoc,
                          admin: currentUserFirestore != null &&
                                  currentUserFirestore!.is_verified &&
                                  currentUserFirestore!.route_id >= 0
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
              child: Stack(children: [
                MapWidget(
                  route: routeChoice == -1 ? null : _routes[routeChoice],
                  jeeps: routeChoice == -1 ? null : jeeps,
                  foundDeviceLocation: (LatLng newDeviceLocation) {
                    setState(() {
                      deviceLoc = newDeviceLocation;
                    });
                  },
                  currentUserFirestore: currentUserFirestore,
                  mapLoaded: (bool isLoaded) => setState(() {
                    mapLoaded = isLoaded;
                  }),
                ),
                if (!Responsive.isDesktop(context)) const Header(),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
