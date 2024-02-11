import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/account_related/account_settings.dart';
import 'package:transitrack_web/style/style.dart';

import '../../models/account_model.dart';
import '../../style/constants.dart';
import 'login_signup_form.dart';

class AccountStream extends StatefulWidget {
  const AccountStream({super.key});

  @override
  State<AccountStream> createState() => _AccountStreamState();
}

class _AccountStreamState extends State<AccountStream> {
  late User? currentUser;
  late StreamSubscription<User?> userStream;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    listenToUser();
  }

  void listenToUser() {
    userStream = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        currentUser = user;
      });
    }, onError: (e) {
      print('Error listening to authentication state changes: $e');
    });
  }

  @override
  void dispose() {
    userStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LOGGED IN
    if (currentUser != null) {
      return Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(Constants.defaultPadding),
        margin:  const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: Colors.white
          ),
          borderRadius: const BorderRadius.all(Radius.circular(Constants.defaultPadding)),
        ),
        child:  FutureBuilder<AccountData?>(
          future: AccountData.getAccountByEmail(currentUser!.email!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              AccountData accountData = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          PrimaryText(text: accountData.account_name, color: Colors.white, fontWeight: FontWeight.w700),
                          const SizedBox(width: Constants.defaultPadding/2),

                          if (accountData.is_verified)
                            const Icon(Icons.verified_user, color: Colors.blue, size: 15,)
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.noHeader,
                            body: AccountSettings(user: currentUser!, account: accountData)
                          ).show();
                        },
                        child: const Icon(Icons.settings, color: Colors.white)
                      )
                    ],
                  ),
                  Text(AccountData.accountType[accountData.account_type]),

                  if (accountData.account_type == 1)
                    Text(accountData.is_operating?'Operating':'Not Operating'),

                  const SizedBox(height: Constants.defaultPadding),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                FirebaseAuth.instance.signOut();
                              });
                            },
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.logout, color: Colors.white),
                                  SizedBox(width: Constants.defaultPadding),
                                  Text('Logout', style: TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis,)
                                ]
                            ),
                          )
                      )
                    ],
                  ),
                ],
              );
            } else {
              // If no data is available, display a message indicating that no account was found
              return Text('No account found with email: ${currentUser?.email}');
            }
          },
        ),
      );
    }

    // NOT logged in
    else {
      return Row(
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
      );
    }
  }
}
