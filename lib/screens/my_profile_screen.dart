// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/api/apis.dart';
import 'package:my_chat/helper/dialogs.dart';
import 'package:my_chat/models/chat_user.dart';
import 'package:my_chat/screens/auth/login_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final ChatUser user;
  const MyProfileScreen({super.key, required this.user});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _form = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile Screen"),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              // Show progress bar
              Dialogs.showLoading(context);
              Apis.updateActiveStatus(false);

              try {
                //sign out from app
                await FirebaseAuth.instance.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for hiding progress dialog
                    Navigator.pop(context);

                    //for moving to home screen
                    Navigator.pop(context);

                    // APIs.auth = FirebaseAuth.instance;

                    //replacing home screen with login screen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                });
              } catch (e) {
                // Handle sign-out error (optional)
                print('Error during sign out: $e');

                // Close the progress dialog even if an error occurs
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.logout),
            label: Text('Logout'),
          ),
        ),
        body: Form(
          key: _form,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  Stack(
                    children: [
                      //profile picture
                      _image != null
                          ?

                          //local image
                          ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(mq.height * .1)),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :

                          //image from server
                          ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(mq.height * .1)),
                              child: Image.network(
                                widget.user.image,
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            ),

                      //edit image button
                      Positioned(
                        bottom: 0,
                        right: -20,
                        //  left: 10,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottonSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: mq.height * 0.06,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => Apis.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      hintText: 'e.g. Usama Ahmed',
                      label: Text('Name'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => Apis.me.about = val ?? '',
                    maxLines: null,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      hintText: 'e.g. I am from Gujranwala',
                      label: Text('About'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        minimumSize: Size(mq.width * 0.4, mq.height * 0.055)),
                    onPressed: () {
                      if (_form.currentState!.validate()) {
                        _form.currentState!.save();
                        Apis.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile updated successfully...');
                        });
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottonSheet() {
    var mq = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: mq.height * 0.03, bottom: mq.height * 0.05),
          children: [
            Text(
              'Pick profile image',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: mq.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        fixedSize: Size(mq.width * 0.3, mq.height * 0.10)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        await Apis.updateProfileImage(File(_image!));
                      }
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/gallery.png')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        fixedSize: Size(mq.width * 0.3, mq.height * 0.10)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        await Apis.updateProfileImage(File(_image!));
                      }
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/camera.png')),
              ],
            ),
          ],
        );
      },
    );
  }
}
