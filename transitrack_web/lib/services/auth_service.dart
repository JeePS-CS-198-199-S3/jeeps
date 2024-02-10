import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      print(error);
      return null;
    }
  }

  void createUserDocument(User? user) async {
    if (user != null) {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('drivers').doc(
          user.uid);

      // Check if the document already exists
      if (!(await userDocRef.get()).exists) {
        // If the document doesn't exist, create it
        await userDocRef.set({
          'name': user.displayName,
          'email': user.email,
          'isOperating': false,
          'jeepDriving': "",
          'isVerified': false
        });
      }
    }
  }
}