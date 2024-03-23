import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:transitrack_web/MenuController.dart';
import 'package:transitrack_web/style/constants.dart';
import 'package:transitrack_web/pages/dashboard_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JeePS',
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Constants.secondaryColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: Constants.secondaryColor),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuControllers(),
          ),
        ],
        child: const Dashboard(),
      ),
    );
  }
}
