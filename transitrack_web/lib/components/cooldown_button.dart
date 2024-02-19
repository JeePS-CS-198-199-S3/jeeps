import 'dart:async';
import 'package:flutter/material.dart';

class CooldownButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const CooldownButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CooldownButtonState createState() => _CooldownButtonState();
}

class _CooldownButtonState extends State<CooldownButton> {
  bool _isCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_cooldownSeconds > 0) {
          _cooldownSeconds--;
        } else {
          _isCooldown = false;
          timer.cancel();
        }
      });
    });
  }

  void _handleTap() {
    if (!_isCooldown) {
      widget.onPressed();
      setState(() {
        _isCooldown = true;
        _cooldownSeconds = 60; // Reset cooldown time to 60 seconds
      });
      _startCooldownTimer();
    }
  }

  Widget get _buttonText {
    if (_isCooldown) {
      return Text('$_cooldownSeconds s');
    } else {
      return const Icon(Icons.location_on, color: Colors.white, size: 25);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _isCooldown ? Colors.grey : Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: _buttonText
        ),
      ),
    );
  }
}