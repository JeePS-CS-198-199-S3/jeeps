import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import '../MenuController.dart';

import '../components/account_related/account_stream.dart';
import '../components/account_related/route_manager/route_manager_options.dart';
import '../components/account_related/route_manager/route_properties_settings.dart';
import '../components/cooldown_button.dart';
import '../components/header.dart';
import '../components/left_drawer/logo.dart';
import '../components/map_related/map.dart';
import '../components/mobile_dashboard_unselected.dart';
import '../components/left_drawer/route_list.dart';
import '../components/unselected_desktop_route_info.dart';
import '../config/responsive.dart';
import '../config/size_config.dart';
import '../models/account_model.dart';
import '../models/ping_model.dart';
import '../models/route_model.dart';
import '../services/send_ping.dart';
import '../style/constants.dart';

class Dashboard extends StatefulWidget {
  String? apiKey;
  Dashboard({super.key, required this.apiKey});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool drawerOpen = false;

  // Account Detection
  User? currentUserAuth;
  AccountData? currentUserFirestore;
  List<RouteData> _routes = [];
  late StreamSubscription<User?> userAuthStream;                // Firebase Auth
  late StreamSubscription userFirestoreStream;                  // Firebase Firestore Accounts
  late StreamSubscription routesFirestoreStream;                // Firebase Firestore Routes

  // Route Selection
  int routeChoice = -1;

  // Device Location Found
  LatLng? deviceLoc;

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

  @override
  void dispose() {
    userAuthStream.cancel();
    userFirestoreStream.cancel();
    routesFirestoreStream.cancel();
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

              if (_routes.isEmpty)
                const Center(
                    child: CircularProgressIndicator()
                ),

              RouteList(
                apiKey: widget.apiKey,
                routeChoice: routeChoice,
                routes: _routes,
                newRouteChoice: (int choice) {
                  if (routeChoice == choice) {
                    switchRoute(-1);
                  } else {
                    switchRoute(choice);
                  }
                },
                account: currentUserAuth != null
                    ? currentUserFirestore!
                    : null,
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
                  const Spacer(flex: 1),

                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: MapWidget(
                          apiKey: widget.apiKey,
                          isDrawer: drawerOpen,
                          route: routeChoice == -1
                              ? null
                              : _routes[routeChoice],
                          foundDeviceLocation: (LatLng newDeviceLocation) {
                            setState(() {
                              deviceLoc = newDeviceLocation;
                            });
                          },

                        )
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

                            if (_routes.isEmpty)
                              const Center(
                                child: CircularProgressIndicator()
                              ),

                            RouteList(
                              apiKey: widget.apiKey,
                              routeChoice: routeChoice,
                              routes: _routes,
                              newRouteChoice: (int choice) {
                                if (routeChoice == choice) {
                                  switchRoute(-1);
                                } else {
                                  switchRoute(choice);
                                }
                              },
                              account: currentUserAuth != null
                                  ? currentUserFirestore!
                                  : null,
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
                                            child: const MobileDashboardUnselected()
                                        )
                                      ]
                                    ),
                                    const Header()
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
                                      UnselectedDesktopRouteInfo(),

                                      if (currentUserAuth != null && currentUserFirestore!.account_type == 2)
                                      MouseRegion(
                                        onEnter: (_) => hovering(),
                                        onExit: (_) => hovering(),
                                        cursor: SystemMouseCursors.basic,
                                        child: Container(
                                          width: 300,
                                          padding: const EdgeInsets.all(Constants.defaultPadding),
                                          margin: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                                          decoration: const BoxDecoration(
                                            color: Constants.secondaryColor,
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          child: RouteManagerOptions(route: _routes[currentUserFirestore!.route_id], apiKey: widget.apiKey, hoverToggle: hovering,)
                                        ),
                                      )
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
                        ? (routeChoice != -1
                            ? const Icon(Icons.location_on)
                            : const Icon(Icons.touch_app)
                          )
                        : const SizedBox(
                        width: 20,
                        height: 20,
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