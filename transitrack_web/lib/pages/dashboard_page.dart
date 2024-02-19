import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import '../MenuController.dart';

import '../components/account_related/account_stream.dart';
import '../components/header.dart';
import '../components/logo.dart';
import '../config/keys.dart';
import '../config/responsive.dart';
import '../config/size_config.dart';
import '../style/constants.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late MapboxMapController _mapController;
  bool isHover = false;

  void hovering() {
    setState(() {
      isHover = !isHover;
    });
  }

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
              AccountStream(
                  hoverToggle: hovering
              )
            ],
          ),
        )
      ),
      body:  SafeArea(
        child: Stack(
          children: [
            MapboxMap(
              accessToken: Keys.MapBoxKey,
              styleString: Keys.MapBoxNight,
              doubleClickZoomEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(14, 19),
              scrollGesturesEnabled: !isHover,
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
                            AccountStream(
                                hoverToggle: hovering
                            )
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