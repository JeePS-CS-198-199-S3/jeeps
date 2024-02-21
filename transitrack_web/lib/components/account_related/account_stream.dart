import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/account_related/account_settings.dart';
import 'package:transitrack_web/components/cooldown_button.dart';
import 'package:transitrack_web/style/style.dart';

import '../../models/account_model.dart';
import '../../style/constants.dart';
import 'login_signup_form.dart';

class AccountStream extends StatefulWidget {
  final Function() hoverToggle;
  User? currentUser;
  AccountData? user;
  bool isDesktop;
  AccountStream({super.key, required this.hoverToggle, required this.currentUser, required this.user, required this.isDesktop});

  @override
  State<AccountStream> createState() => _AccountStreamState();
}

class _AccountStreamState extends State<AccountStream> {
  @override
  Widget build(BuildContext context) {
    // LOGGED IN
    if (widget.currentUser != null) {
      if (widget.user != null) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PrimaryText(text: widget.user!.account_name,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                        const SizedBox(width: Constants.defaultPadding / 2),

                        if (widget.user!.is_verified)
                          const Icon(Icons.verified_user, color: Colors.blue,
                            size: 15,)
                      ],
                    ),
                    GestureDetector(
                        onTap: () async {
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.noHeader,
                              body: MouseRegion(
                                onEnter: (_) => widget.hoverToggle(),
                                onExit: (_) => widget.hoverToggle(),
                                child: AccountSettings(
                                    user: widget.currentUser!, account: widget.user!
                                ),
                              )
                          ).show();
                        },
                        child: const Icon(Icons.settings, color: Colors.white)
                    )
                  ],
                ),
                Text(AccountData.accountType[widget.user!.account_type]),

                if (widget.user!.account_type == 1)
                  Text(widget.user!.is_operating
                      ? 'Operating'
                      : 'Not Operating'),

                const SizedBox(height: Constants.defaultPadding),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
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
                            Text('Logout',
                              style: TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,)
                          ]
                      ),
                    ),

                    if (widget.isDesktop)
                      CooldownButton(onPressed: () {print("pressed");}, verified: widget.user!.is_verified, child: const Icon(Icons.location_on),)
                  ],
                ),
              ],
            )
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
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
                      body: MouseRegion(
                        onEnter: (_) => widget.hoverToggle(),
                        onExit: (_) => widget.hoverToggle(),
                        child: const LoginSignupForm()
                      )
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
