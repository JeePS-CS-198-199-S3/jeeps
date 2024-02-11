import 'package:cloud_firestore/cloud_firestore.dart';

class AccountData{
  String account_email;
  String account_name;
  int account_type;
  bool is_operating;
  bool is_verified;

  AccountData({
    required this.account_email,
    required this.account_name,
    required this.account_type,
    required this.is_operating,
    required this.is_verified
  });

  factory AccountData.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String account_email = data['account_email'];
    String account_name = data['account_name'];
    int account_type = data['account_type'];
    bool is_operating = data['is_operating'] as bool;
    bool is_verified = data['is_verified'] as bool;

    return AccountData(
        account_email: account_email,
        account_name: account_name,
        account_type: account_type,
        is_operating: is_operating,
        is_verified: is_verified,
    );
  }

  static Future<AccountData?> getAccountByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('account_email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AccountData.fromSnapshot(querySnapshot.docs.first);
      } else {
        return null; // No document found with the given email
      }
    } catch (e) {
      print('Error fetching account data: $e');
      return null;
    }
  }

  static Map<String, int> accountTypeMap = {
    'Commuter': 0,
    'Driver': 1,
    'Route Manager': 2,
  };

  static List<String> accountType = [
    'Commuter',
    'Driver',
    'Route Manager'
  ];
}