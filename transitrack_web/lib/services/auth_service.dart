import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/account_model.dart';

class AuthService {
  void createUserDocument(User? user, AccountData account) async {
    if (user != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('accounts').doc(user.uid);

      // Check if the document already exists
      if (!(await userDocRef.get()).exists) {
        // If the document doesn't exist, create it
        await userDocRef.set({
          'account_name': account.account_name,
          'account_email': user.email,
          'is_verified': account.is_verified,
          'account_type': account
              .account_type, // 0 - commuter acc, 1 - driver acc, 2 - operator acc
          'route_id': account.route_id
        });
      }
    }
  }
}
