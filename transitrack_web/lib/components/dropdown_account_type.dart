import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDownAccountType extends StatefulWidget {
  final Function()? updateType;
  const DropDownAccountType({super.key, required this.updateType});

  @override
  State<DropDownAccountType> createState() => _DropDownAccountTypeState();
}

class _DropDownAccountTypeState extends State<DropDownAccountType> {
  String accountType = "Commuter";

  Map<String, int> accountTypeMap = {
    'Commuter': 0,
    'Driver': 1,
    'Route Manager': 2,
  };


  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: accountType, // Initial value
      onChanged: (String? newValue) {
        // Handle dropdown value change
        if (newValue != null) {
          setState(() {
            accountType = newValue;
          });
        }
      },
      items: accountTypeMap.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
