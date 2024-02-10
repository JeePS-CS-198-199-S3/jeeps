
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/pages/no_account_dashboard_page.dart';

import 'account_dashboard_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Logged in
          if (snapshot.hasData) {
            return const AccountDashboard();
          }

          // NOT logged in
          else {
            return const NoAccountDashboard();
          }
        },
      )
    );
  }
}
