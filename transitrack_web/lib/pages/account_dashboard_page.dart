import 'package:flutter/cupertino.dart';

import '../style/style.dart';

class AccountDashboard extends StatelessWidget {
  const AccountDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: PrimaryText(
        text: 'Account Dashboard',
      ),
    );
  }
}
