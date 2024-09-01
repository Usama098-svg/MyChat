// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/screens/auth/login_screen.dart';
import 'package:my_chat/screens/all_chat_user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AllChatUser()));
        print(FirebaseAuth.instance.currentUser);
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      //  appBar: AppBar(title: Text("Welcome to My Chat"),),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .25,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset("assets/chat.png")),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Text(
                'Made by UA Tech from Pakistan 💖',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ))
        ],
      ),
    );
  }
}
