import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:transitrack_web/style/style.dart';
import '../MenuController.dart';

import '../components/account_related/login_signup_form.dart';
import '../components/header.dart';
import '../components/logo.dart';
import '../config/keys.dart';
import '../config/responsive.dart';
import '../config/size_config.dart';
import '../style/constants.dart';

class NoAccountDashboard extends StatefulWidget {
  const NoAccountDashboard({Key? key}) : super(key: key);

  @override
  State<NoAccountDashboard> createState() => _NoAccountDashboardState();
}

class _NoAccountDashboardState extends State<NoAccountDashboard> {
  late MapboxMapController _mapController;

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                child: const Divider()
              ),
              const SizedBox(height: Constants.defaultPadding),
            ],
          ),
        )
      ),
      body:  SafeArea(
        child: Stack(
          children: [
            if(!Responsive.isMobile(context))
              MapboxMap(
                accessToken: Keys.MapBoxKey,
                styleString: Keys.MapBoxNight,
                doubleClickZoomEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(14, 19),
                tiltGesturesEnabled: false,
                compassEnabled: false,
                onMapCreated: (controller) {
                  _onMapCreated(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: Keys.MapCenter,
                  zoom: 15,
                ),
              ),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                              child: const Divider()
                            ),
                            const SizedBox(height: Constants.defaultPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.noHeader,
                                          body: const LoginSignupForm()
                                        ).show();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(Constants.defaultPadding),
                                      margin:  const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: Colors.white
                                        ),
                                        borderRadius: const BorderRadius.all(Radius.circular(Constants.defaultPadding)),
                                      ),
                                      child: const Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.account_box, color: Colors.white),
                                                      SizedBox(width: Constants.defaultPadding),
                                                      Text('Login/Sign Up', style: TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                    ]
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  )
                                )
                              ],
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
                                          children: [
                                            Expanded(child: MapboxMap(
                                              accessToken: Keys.MapBoxKey,
                                              styleString: Keys.MapBoxNight,
                                              zoomGesturesEnabled: true,
                                              scrollGesturesEnabled: true,
                                              doubleClickZoomEnabled: false,
                                              dragEnabled: true,
                                              minMaxZoomPreference: const MinMaxZoomPreference(12, 19),
                                              rotateGesturesEnabled: false,
                                              tiltGesturesEnabled: false,
                                              compassEnabled: false,
                                              onMapCreated: (controller) {
                                                _onMapCreated(controller);
                                              },
                                              initialCameraPosition: CameraPosition(
                                                target: Keys.MapCenter,
                                                zoom: 15.0,
                                              ),
                                            )),
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
                                                                padding: EdgeInsets.all(Constants.defaultPadding),
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
                                          ]),
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

























