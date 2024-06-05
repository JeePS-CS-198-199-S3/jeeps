import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/account_model.dart';
import '../../style/constants.dart';
import '../../style/style.dart';
import '../button.dart';
import '../text_field.dart';

// This widget displays the account settings page

class AccountSettings extends StatelessWidget {
  final User user;
  final AccountData account;
  const AccountSettings({super.key, required this.user, required this.account});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    nameController.text = account.account_name;
    emailController.text = user.email!;

    void errorMessage(String message) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                backgroundColor: Constants.bgColor,
                title: Center(
                    child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                )));
          });
    }

    void update() async {
      // show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          });

      try {
        // check if password is confirmed
        if (nameController.text != account.account_name) {
          Map<String, dynamic> newAccountSettings = {
            'account_name': nameController.text,
          };
          AccountData.updateAccountFirestore(user.email!, newAccountSettings);
        }

        if (emailController.text != user.email! ||
            (passwordController.text != "" &&
                passwordController.text == confirmPasswordController.text)) {
          Map<String, dynamic> newAccountSettings = {
            'account_email': emailController.text,
          };

          AccountData.updateAccountFirestore(user.email!, newAccountSettings);

          AccountData.updateEmailAndPassword(
                  emailController.text, passwordController.text)
              .then((value) => FirebaseAuth.instance.signOut());
        }

        // pop loading circle
        Navigator.pop(context);
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop loading circle
        Navigator.pop(context);
        errorMessage(e.code);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
          left: Constants.defaultPadding,
          right: Constants.defaultPadding,
          bottom: Constants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              PrimaryText(
                text: "Settings",
                color: Colors.white,
                size: 40,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
            controller: emailController,
            hintText: "Email",
            obscureText: false,
            enabled: false,
          ),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: nameController, hintText: "Name", obscureText: false),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: true),
          const SizedBox(height: Constants.defaultPadding),
          const SizedBox(height: Constants.defaultPadding / 2),
          const PrimaryText(
              text: "Email and password changes will log you out.",
              color: Colors.white),
          const SizedBox(height: Constants.defaultPadding * 2),
          Button(
            onTap: update,
            text: "Save",
          ),
        ],
      ),
    );
  }
}
