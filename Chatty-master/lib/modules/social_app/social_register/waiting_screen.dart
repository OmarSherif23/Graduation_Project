import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../interests/interests_screen.dart';
import 'dart:async';

class WaitingVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  const WaitingVerificationScreen({super.key, required this.email, required this.password});
  @override
  _WaitingVerificationScreenState createState() => _WaitingVerificationScreenState();
}


class _WaitingVerificationScreenState extends State<WaitingVerificationScreen> {
  late Timer refreshTimer;

  @override
  void initState() {
    super.initState();
    checkEmailVerificationStatus();
    startRefreshTimer();
  }

  void checkEmailVerificationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user?.emailVerified == true) {
      setState(() {
        navigateToInterestsScreen();
      });
    }
  }

  void startRefreshTimer() {
    const refreshInterval = Duration(seconds: 5); // Set the refresh interval as desired
    refreshTimer = Timer.periodic(refreshInterval, (_) {
      checkEmailVerificationStatus();
    });
  }

  void stopRefreshTimer() {
    refreshTimer.cancel();
  }

  void navigateToInterestsScreen() {
    stopRefreshTimer(); // Stop the refresh timer before navigating
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChooseInterestsScreen(email: widget.email,password: widget.password,)),
          (route) => false,
    );
  }

  @override
  void dispose() {
    stopRefreshTimer(); // Stop the refresh timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Account Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'We sent you a verification email.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
