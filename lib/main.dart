// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_chat/screens/splash_screen.dart';
import 'firebase_options.dart';

late Size mq;

Future main() async {
  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // var result = await FlutterNotificationChannel.registerNotificationChannel(
  //   description: 'Your channel description',
  //   id: 'mychat',
  //   importance: NotificationImportance.IMPORTANCE_HIGH,
  //   name: 'MyChat',
  // );
  // print('Channal created : ${result}');
  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Chat',
        theme: ThemeData(
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                centerTitle: true,
                elevation: 5,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))),
        home: SplashScreen());
  }
}
