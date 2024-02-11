import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/style/style.dart';

import '../../services/auth_service.dart';
import '../../style/constants.dart';
import '../button.dart';
import '../square_tile.dart';
import '../text_field.dart';

class LoginForm extends StatefulWidget {
  final Function()? onTap;
  const LoginForm({
    super.key,
    required this.onTap
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {

    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator()
          );
        }
    );

    // try sign in
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );

      // pop loading circle
      Navigator.pop(context);
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      // pop loading circle
      Navigator.pop(context);
      errorMessage(e.code);
    }
  }

  void errorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Constants.bgColor,
              title: Center(
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  )
              )
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
      child: Column(
        children: [
          const Row(
            children: [
              PrimaryText(text: "Login", color: Colors.white, size: 40, fontWeight: FontWeight.w700,)
            ],
          ),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: emailController, hintText: "Email", obscureText: false),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: passwordController, hintText: "Password", obscureText: true),

          const SizedBox(height: Constants.defaultPadding/2),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: Constants.defaultPadding*2),

          Button(onTap: signUserIn, text: "Login",),

          const SizedBox(height: Constants.defaultPadding*2.5),

          const Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Or continue with",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: Constants.defaultPadding*2.5),

          SquareTile(imagePath: 'assets/google.png', onTap: () async {
            UserCredential? userCredential = await AuthService().signInWithGoogle();
            AuthService().createUserDocument(userCredential?.user);
            }
          ),

          const SizedBox(height: Constants.defaultPadding*2),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Not a member?',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(
                  'Register now',
                  style: TextStyle(color: Constants.primaryColor, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )
        ],
      )
    );
  }
}