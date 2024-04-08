import 'package:firebase_auth/firebase_auth.dart';
import 'package:transitrack_web/models/account_model.dart';

bool verificationEvaluator(User? user, AccountData? accountData) {
  if (user != null && accountData != null) {
    if (accountData.account_type == 0) {
      if (user.emailVerified) {
        return true;
      } else {
        return false;
      }
    } else {
      return accountData.is_verified;
    }
  } else {
    return false;
  }
}
