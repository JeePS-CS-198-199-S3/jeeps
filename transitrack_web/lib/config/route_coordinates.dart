

import 'dart:js_interop';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/style/constants.dart';

import '../models/heatmap_ride_model.dart';

class Routes {

  static List<LatLng> ikot = [
    LatLng(14.657675, 121.062360),
    LatLng(14.654756, 121.062316),
    LatLng(14.647361, 121.062336),
    LatLng(14.647706, 121.063844),
    LatLng(14.647659, 121.064632),
    LatLng(14.647939, 121.065780),
    LatLng(14.647960, 121.066328),
    LatLng(14.647254, 121.067808),
    LatLng(14.647173, 121.068955),
    LatLng(14.649071, 121.068951),
    LatLng(14.649904, 121.068611),
    LatLng(14.650504, 121.068453),
    LatLng(14.650908, 121.068430),
    LatLng(14.651842, 121.068584),
    LatLng(14.652487, 121.068667),
    LatLng(14.652550, 121.072847),
    LatLng(14.653974, 121.072828),
    LatLng(14.654645, 121.073132),
    LatLng(14.655566, 121.073090),
    LatLng(14.656308, 121.072771),
    LatLng(14.659379, 121.072722),
    LatLng(14.659390, 121.068572),
    LatLng(14.657539, 121.068584),
    LatLng(14.657568, 121.064787),
    LatLng(14.657675, 121.062360),
  ];

  static List<LatLng> toki = [
    LatLng(14.652960309655244, 121.06229032368765),
    LatLng(14.657700291994187, 121.06234135892598),
    LatLng(14.65758302807958, 121.06477191187733),
    LatLng(14.657564512713318, 121.06856765705194),
    LatLng(14.659422213350918, 121.06854213952413),
    LatLng(14.659403698143263, 121.07271426978609),
    LatLng(14.657539825575478, 121.0727270285947),
    LatLng(14.65752131020559, 121.07274616680566),
    LatLng(14.657595371675777, 121.07432187950842),
    LatLng(14.652598620788039, 121.07429579367411),
    LatLng(14.652572671022089, 121.07283667206927),
    LatLng(14.651996585405042, 121.0727508413746),
    LatLng(14.650932639544383, 121.07128635535467),
    LatLng(14.650392879635199, 121.07124343999037),
    LatLng(14.650377309619284, 121.07206419589308),
    LatLng(14.650574529739076, 121.07369497886316),
    LatLng(14.648290917483044, 121.07380226721646),
    LatLng(14.648181926282877, 121.07242361182773),
    LatLng(14.647315184971722, 121.07080355769295),
    LatLng(14.647201003219504, 121.06894746912985),
    LatLng(14.648908533117885, 121.06897965563581),
    LatLng(14.650159329261273, 121.06849149352905),
    LatLng(14.651197328974687, 121.06843784933488),
    LatLng(14.652505201561508, 121.06866851929449),
    LatLng(14.652276829185512, 121.06776727189317),
    LatLng(14.651788972355082, 121.06703771109078),
    LatLng(14.651290734450155, 121.06679631228383),
    LatLng(14.650444765448706, 121.06683386320748),
    LatLng(14.650169695053597, 121.06679094785812),
    LatLng(14.649640313353062, 121.06610430239702),
    LatLng(14.648161151810301, 121.06599701403938),
    LatLng(14.649640313353062, 121.06610430239702),
    LatLng(14.650169695053597, 121.06679094785812),
    LatLng(14.650444765448706, 121.06683386320748),
    LatLng(14.650496665475096, 121.06676412577127),
    LatLng(14.651897961713848, 121.06505287653621),
    LatLng(14.652993042573604, 121.06524063112236),
    LatLng(14.65309679530806, 121.06510112416251),
    LatLng(14.652935908229038, 121.06234378834203),
    LatLng(14.652960309655244, 121.06229032368765),
  ];

  static List<LatLng> katip = [
    LatLng(14.6323447623831,121.074405213629),
    LatLng(14.6326825733295,121.074422244595),
    LatLng(14.6329482901109,121.074437146691),
    LatLng(14.6333767320084,121.074426502336),
    LatLng(14.6365860234475,121.074533239344),
    LatLng(14.6385678787093,121.074616690075),
    LatLng(14.6420837926593,121.07476083228),
    LatLng(14.6432251680955,121.074817730516),
    LatLng(14.643632538575,121.074806350867),
    LatLng(14.6439665084156,121.074798764428),
    LatLng(14.6444362673135,121.074707727235),
    LatLng(14.6451652588312,121.074602570179),
    LatLng(14.646083950015,121.074495311361),
    LatLng(14.6465758942317,121.074474715092),
    LatLng(14.647220718189,121.074477998259),
    LatLng(14.6486183596855,121.074517396277),
    LatLng(14.6494381400028,121.074518387762),
    LatLng(14.651088562606,121.074513023344),
    LatLng(14.6523808660169,121.074480836878),
    LatLng(14.6534188551666,121.074513023384),
    LatLng(14.6543893706103,121.074620311773),
    LatLng(14.6549395004294,121.074582760849),
    LatLng(14.657534433826,121.074577396454),
    LatLng(14.6575673394275,121.07272185565),
    LatLng(14.6593848545115,121.072739919679),
    LatLng(14.6594198065771,121.068561099031),
    LatLng(14.6575323870741,121.068555077629),
    LatLng(14.6577043643201,121.062401754888),
    LatLng(14.6529648884757,121.062302514649),
    LatLng(14.6530434441401,121.065144393935),
    LatLng(14.6517778213417,121.067011914714),
    LatLng(14.6522142438102,121.067670508964),
    LatLng(14.6524235482375,121.068239092347),
    LatLng(14.6524767210812,121.068671605683),
    LatLng(14.6525801531953,121.074303311717),
    LatLng(14.6471529029232,121.074279423725),
    LatLng(14.644376652189,121.074527072591),
    LatLng(14.6434379992996,121.074608318195),
    LatLng(14.6405988966819,121.074488839371),
    LatLng(14.6317717235596,121.073976135937),
    LatLng(14.6323447623831,121.074405213629),
  ];

  static List<LatLng> philcoa = [
    LatLng(14.6542219,121.0543598),
    LatLng(14.6547305,121.0569347),
    LatLng(14.6547536,121.0587669),
    LatLng(14.6547951,121.0623267),
    LatLng(14.6529527,121.0622999),
    LatLng(14.6530461,121.0651109),
    LatLng(14.6517797,121.0670528),
    LatLng(14.6521933,121.0675808),
    LatLng(14.6524113,121.0682192),
    LatLng(14.6524684,121.0686645),
    LatLng(14.6525354,121.0716758),
    LatLng(14.6539211,121.071662),
    LatLng(14.6539471,121.0727724),
    LatLng(14.6545751,121.0731157),
    LatLng(14.6555672,121.0731061),
    LatLng(14.6561848,121.0727735),
    LatLng(14.6593973,121.0727198),
    LatLng(14.6594025,121.0685467),
    LatLng(14.6575445,121.0685736),
    LatLng(14.6575757,121.0647927),
    LatLng(14.6576276,121.0641865),
    LatLng(14.6576847,121.0623465),
    LatLng(14.6549673,121.0623251),
    LatLng(14.6548585,121.0566478),
    LatLng(14.6549401,121.0558828),
    LatLng(14.6550491,121.0556897),
    LatLng(14.6552463,121.0555502),
    LatLng(14.65681,121.0579307),
    LatLng(14.6569319,121.0580728),
    LatLng(14.657098,121.0580353),
    LatLng(14.6572381,121.0578824),
    LatLng(14.6571188,121.0576759),
    LatLng(14.6529661,121.0514811),
    LatLng(14.6527122840003,121.051647277721),
    LatLng(14.6535123096324,121.052838347635),
    LatLng(14.6541398506173,121.054000968372),
    LatLng(14.653976543341,121.054507362723),
    LatLng(14.6539485819635,121.054565542674),
    LatLng(14.6542926197439,121.054867173343),
    LatLng(14.6543246603649,121.054874333982),
    LatLng(14.6537751825091,121.054658476469),
    LatLng(14.6535691920764,121.054169766489),
  ];

  static List<LatLng> sm = [
    LatLng(14.6542219,121.0543598),
    LatLng(14.6547305,121.0569347),
    LatLng(14.6547536,121.0587669),
    LatLng(14.6547951,121.0623267),
    LatLng(14.6529527,121.0622999),
    LatLng(14.6530461,121.0651109),
    LatLng(14.6517797,121.0670528),
    LatLng(14.6521933,121.0675808),
    LatLng(14.6524113,121.0682192),
    LatLng(14.6524684,121.0686645),
    LatLng(14.6525354,121.0716758),
    LatLng(14.6539211,121.071662),
    LatLng(14.6539471,121.0727724),
    LatLng(14.6545751,121.0731157),
    LatLng(14.6555672,121.0731061),
    LatLng(14.6561848,121.0727735),
    LatLng(14.6593973,121.0727198),
    LatLng(14.6594025,121.0685467),
    LatLng(14.6575445,121.0685736),
    LatLng(14.6575757,121.0647927),
    LatLng(14.6576276,121.0641865),
    LatLng(14.6576847,121.0623465),
    LatLng(14.6549673,121.0623251),
    LatLng(14.6548585,121.0566478),
    LatLng(14.6549401,121.0558828),
    LatLng(14.6550491,121.0556897),
    LatLng(14.6552463,121.0555502),
    LatLng(14.65681,121.0579307),
    LatLng(14.6569319,121.0580728),
    LatLng(14.657098,121.0580353),
    LatLng(14.6572381,121.0578824),
    LatLng(14.6571188,121.0576759),
    LatLng(14.6529661,121.0514811),
    LatLng(14.6531132,121.0512071),
    LatLng(14.6535388,121.0508691),
    LatLng(14.6540422,121.0501878),
    LatLng(14.6544522,121.0491847),
    LatLng(14.6544765,121.0484651),
    LatLng(14.6541859,121.0476336),
    LatLng(14.653589,121.0469523),
    LatLng(14.6527291,121.0466258),
    LatLng(14.652262,121.0459713),
    LatLng(14.6553994,121.0316384),
    LatLng(14.6556734,121.031743),
    LatLng(14.6557175,121.0316948),
    LatLng(14.655445,121.0315741),
    LatLng(14.6556007,121.0307479),
    LatLng(14.6555203,121.0306567),
    LatLng(14.6554632,121.0306889),
    LatLng(14.6537326,121.0384553),
    LatLng(14.6492329,121.0392278),
    LatLng(14.6461204,121.0407885),
    LatLng(14.6435908,121.0430332),
    LatLng(14.6412033,121.0468741),
    LatLng(14.6482756,121.0486665),
    LatLng(14.6485454,121.0492835),
    LatLng(14.6485091,121.0499862),
    LatLng(14.6487219,121.0507587),
    LatLng(14.649272,121.0514346),
    LatLng(14.6503337,121.0519819),
    LatLng(14.6501546,121.0536207),
    LatLng(14.6516597,121.0535027),
    LatLng(14.65276,121.0531165),
    LatLng(14.6533413,121.0525693),
    LatLng(14.6542185,121.0541626),
    LatLng(14.6542219,121.0543598),
  ];

  static List<LineOptions> RouteLines = [
    LineOptions(
      geometry: ikot,
      lineColor: '#${JeepRoutes[0].color.value.toRadixString(16).padLeft(8,'0').substring(2)}',
      lineOpacity: 0.9,
      lineWidth: 5,
    ),
    LineOptions(
      geometry: toki,
      lineColor: '#${JeepRoutes[1].color.value.toRadixString(16).padLeft(8,'0').substring(2)}',
      lineOpacity: 0.9,
      lineWidth: 5,
    ),
    LineOptions(
      geometry: katip,
      lineColor: '#${JeepRoutes[2].color.value.toRadixString(16).padLeft(8,'0').substring(2)}',
      lineOpacity: 0.9,
      lineWidth: 5,
    ),
    LineOptions(
      geometry: philcoa,
      lineColor: '#${JeepRoutes[3].color.value.toRadixString(16).padLeft(8,'0').substring(2)}',
      lineOpacity: 0.9,
      lineWidth: 5,
    ),
    LineOptions(
      geometry: sm,
      lineColor: '#${JeepRoutes[4].color.value.toRadixString(16).padLeft(8,'0').substring(2)}',
      lineOpacity: 0.9,
      lineWidth: 5,
    )
  ];
}


List<HeatMapRideData> syntheticHeatMap = [
  HeatMapRideData(
      heatmap_id: 'GupdajnT8GACIloAMTer', 
      timestamp: Timestamp(234534543534, 43543534),
      passenger_count: 5,
      location: GeoPoint(14.657700291994187,121.06234135892598),
      route_id: 0
  ),
  HeatMapRideData(
      heatmap_id: 'XMOgrRsgC8TbgVlmHgMT',
      timestamp: Timestamp(234534543534, 43543534),
      passenger_count: 2,
      location: GeoPoint(14.652960309655244,121.06229032368765),
      route_id: 0
  ),
  HeatMapRideData(
      heatmap_id: 'ykrZsYBIu6WFuaMxV8s1',
      timestamp: Timestamp(234534543534, 43543534),
      passenger_count: 8,
      location: GeoPoint(14.657595371675777,121.07432187950842),
      route_id: 0
  ),
];

class JeepRoute {
  String name;
  Color color;
  String image;
  List<int> OpHours;

  JeepRoute({
    required this.name,
    required this.color,
    required this.image,
    required this.OpHours
  });
}

List<JeepRoute> JeepRoutes = [
  JeepRoute(name: 'Ikot', color: Constants.ikotColor, image: 'assets/jeep_icons_top/ikot.png', OpHours: [8, 17]),
  JeepRoute(name: 'Toki', color: Constants.tokiColor, image: 'assets/jeep_icons_top/toki.png', OpHours: [17, 21]),
  JeepRoute(name: 'Katipunan', color: Constants.katipColor, image: 'assets/jeep_icons_top/katip.png', OpHours: [8, 17]),
  JeepRoute(name: 'Philcoa', color: Constants.philcoaColor, image: 'assets/jeep_icons_top/philcoa.png', OpHours: [8, 17]),
  JeepRoute(name: 'SM North Edsa', color: Constants.smColor, image: 'assets/jeep_icons_top/sm.png', OpHours: [8, 17]),
];

List<String> JeepFront = [
  'assets/jeep_icons_front/ikot.png',
  'assets/jeep_icons_front/toki.png',
  'assets/jeep_icons_front/katip.png',
  'assets/jeep_icons_front/philcoa.png',
  'assets/jeep_icons_front/sm.png',
];

List<String> JeepSide = [
  'assets/jeep_icons_side/ikot.png',
  'assets/jeep_icons_side/toki.png',
  'assets/jeep_icons_side/katip.png',
  'assets/jeep_icons_side/philcoa.png',
  'assets/jeep_icons_side/sm.png',
];