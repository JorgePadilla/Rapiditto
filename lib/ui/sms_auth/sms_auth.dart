import 'package:flutter/material.dart';
//import 'package:boilerplate/utils/sms/sms_methods.dart';
import 'package:flutter/services.dart';
import  'package:firebase_auth/firebase_auth.dart';
//import 'dart:async';
import 'package:boilerplate/routes.dart';

class SmsAuth extends StatefulWidget {
  @override
  _SmsAuthState createState() => _SmsAuthState();
}

class _SmsAuthState extends State<SmsAuth> {

//  TextEditingController _smsCodeController = TextEditingController();
//  TextEditingController _phoneNumberController = TextEditingController();
//  String verificationId;
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;



//  Future<void> _sendCodeToPhoneNumber() async {
//    final PhoneVerificationCompleted verificationCompleted = (
//        AuthCredential phoneAuthCredential) {
//      setState(() {
//        print(
//            'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $phoneAuthCredential');
//      });
//    };

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
          smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(Routes.home);
                    } else {
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final FirebaseUser user = await _auth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } catch (e) {
      handleError(e);
    }
  }
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  void _signInWithPhoneNumber(String smsCode) async {
//    await FirebaseAuth.instance
//        .signInWithPhoneNumber(
//        verificationId: verificationId,
//        smsCode: smsCode)
//        .then((FirebaseUser user) async {
//      final FirebaseUser currentUser = user;
//      assert(user.uid == currentUser.uid);
//      print('signed in with phone number successful: user -> $user');
//    });

  }

//  Future<String> _signInWithPhoneNumber(String smsCode) async {
//    final AuthCredential credential = PhoneAuthProvider.getCredential(
//      verificationId: verificationId,
//      smsCode: smsCode,
//    );
//    final FirebaseUser user = await _auth.signInWithCredential(credential);
//    final FirebaseUser currentUser = await _auth.currentUser();
//    assert(user.uid == currentUser.uid);
//
//    _smsCodeController.text = '';
//    return 'signInWithPhoneNumber succeeded: $user';
//  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        title: Text(widget.title),
      title: Text("test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Enter Phone Number Eg. +910000000000'),
                onChanged: (value) {
                  this.phoneNo = value;
                },
              ),
            ),
            (errorMessage != ''
                ? Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            )
                : Container()),
            SizedBox(
              height: 10,
            ),
            RaisedButton(
              onPressed: () {
                verifyPhone();
              },
              child: Text('Verify'),
              textColor: Colors.white,
              elevation: 7,
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }
  }
