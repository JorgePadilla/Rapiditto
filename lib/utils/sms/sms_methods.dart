import  'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
/// Sends the code to the specified phone number.
TextEditingController _smsCodeController = TextEditingController();
TextEditingController _phoneNumberController = TextEditingController();
String verificationId;

Future<void> _sendCodeToPhoneNumber() async {
  final PhoneVerificationCompleted verificationCompleted = (FirebaseUser user) {
    setState(() {
      print('Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $user');
    });
  };

  final PhoneVerificationFailed verificationFailed = (AuthException authException) {
    setState(() {
      print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');}
    );
  };

  final PhoneCodeSent codeSent =
      (String verificationId, [int forceResendingToken]) async {
    this.verificationId = verificationId;
    print("code sent to " + _phoneNumberController.text);
  };

  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
      (String verificationId) {
    this.verificationId = verificationId;
    print("time out");
  };

  await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
}