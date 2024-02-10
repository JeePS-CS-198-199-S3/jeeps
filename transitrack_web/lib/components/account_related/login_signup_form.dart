import 'package:flutter/cupertino.dart';
import 'package:transitrack_web/components/account_related/signup_form.dart';

import 'login_form.dart';

class LoginSignupForm extends StatefulWidget {
  const LoginSignupForm({
    super.key,
  });

  @override
  State<LoginSignupForm> createState() => _LoginSignupFormState();
}

class _LoginSignupFormState extends State<LoginSignupForm> {
  // initially show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginForm(
          onTap: togglePages
      );
    } else {
      return SignupForm(
          onTap: togglePages);
    }
  }
}



