import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/account_model.dart';
import '../../services/auth_service.dart';
import '../../style/constants.dart';
import '../../style/style.dart';
import '../button.dart';
import '../text_field.dart';

class SignupForm extends StatefulWidget {
  final Function()? onTap;
  const SignupForm({
    super.key,
    required this.onTap
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  // text editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String accountType = "Commuter";


  // sign user in method
  void signUserUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator()
          );
        }
    );

    // try sign up
    try {
      // check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );

        AccountData newAccount = AccountData(
          account_email: emailController.text,
          account_name: "${firstNameController.text} ${lastNameController.text}",
          account_type: AccountData.accountTypeMap[accountType]!,
          is_operating: false,
          is_verified: false,
        );

        AuthService().createUserDocument(userCredential.user, newAccount);
        // pop loading circle
        Navigator.pop(context);
        Navigator.pop(context);

      } else {
        // pop loading circle
        Navigator.pop(context);

        // password dont match
        errorMessage("Passwords don't match!");
      }
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
    return  Padding(
      padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           const Row(
            children: [
              PrimaryText(text: "Sign Up", color: Colors.white, size: 40, fontWeight: FontWeight.w700,)
            ],
          ),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: emailController, hintText: "Email", obscureText: false),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: firstNameController, hintText: "First Name", obscureText: false),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: lastNameController, hintText: "Last Name", obscureText: false),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: passwordController, hintText: "Password", obscureText: true),

          const SizedBox(height: Constants.defaultPadding),

          InputTextField(controller: confirmPasswordController, hintText: "Confirm Password", obscureText: true),

          const SizedBox(height: Constants.defaultPadding),

          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding/2, vertical: 4),
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.white, // Set border color here
                width: 1, // Set border width here
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: accountType, // Initial value
                onChanged: (String? newValue) {
                  // Handle dropdown value change
                  if (newValue != null) {
                    setState(() {
                      accountType = newValue;
                    });
                  }
                },
                items: AccountData.accountTypeMap.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: Constants.defaultPadding/2),

          const SizedBox(height: Constants.defaultPadding*2),

          Button(onTap: signUserUp, text: "Sign Up",),

          const SizedBox(height: Constants.defaultPadding*2.5),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(
                  'Login now',
                  style: TextStyle(color: Constants.primaryColor, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}