// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_nullable_for_final_variable_declarations, avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chat/api/apis.dart';
import 'package:my_chat/helper/dialogs.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/screens/all_chat_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool inAnimte = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        inAnimte = true;
      });
    });
  }

  // Future<UserCredential?> _signInWithGoogle() async {
  //   try {
  //     // Check for internet connectivity
  //     //   await InternetAddress.lookup('www.google.com');

  //     if (kIsWeb) {
  //       // Web-specific code
  //       GoogleAuthProvider googleProvider = GoogleAuthProvider();
  //       return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  //     } else {
  //       // Mobile-specific code
  //       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //       if (googleUser == null) {
  //         // If the user cancels the sign-in process
  //         throw FirebaseAuthException(
  //             code: 'ERROR_ABORTED_BY_USER',
  //             message: 'Sign in aborted by user');
  //       }

  //       final GoogleSignInAuthentication? googleAuth =
  //           await googleUser.authentication;

  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken,
  //         idToken: googleAuth?.idToken,
  //       );

  //       return await FirebaseAuth.instance.signInWithCredential(credential);
  //     }
  //   } catch (e) {
  //     print('_signInWithGoogle $e');
  //     // Ensure Dialogs.showSnackBar is properly defined
  //     Dialogs.showSnackbar(context,
  //         'Something went wrong. Please check your internet connection.');
  //     return null;
  //   }
  // }

  // handles google login button click
  _handleGoogleButton() {
    //for showing progress bar
    Dialogs.showLoading(context);

    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await Apis.userExists() && mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AllChatUser()));
        } else {
          await Apis.createUser().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AllChatUser()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('\n_signInWithGoogle: $e');

      if (mounted) {
        Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      }

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome to My Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .20,
              right: inAnimte ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: Duration(seconds: 1),
              child: Image.asset("assets/chat.png")),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: StadiumBorder()),
                  onPressed: _handleGoogleButton,
                  icon: Image.asset(
                    "assets/google.png",
                    height: mq.height * .04,
                  ),
                  label: Text(
                    "Login with Google",
                    style: TextStyle(fontSize: 18),
                  )))
        ],
      ),
    );
  }
}
