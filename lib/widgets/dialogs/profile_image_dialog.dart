// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user.dart';
import 'package:my_chat/screens/profile_screen.dart';

class ProfileImageDialog extends StatefulWidget {
  final ChatUser user;
  const ProfileImageDialog({super.key, required this.user});

  @override
  State<ProfileImageDialog> createState() => _ProfileImageDialogState();
}

class _ProfileImageDialogState extends State<ProfileImageDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: mq.height * 0.35,
        width: mq.width * 0.6,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(mq.height * .25)),
                child: Image.network(
                  widget.user.image,
                  width: mq.width * .5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: mq.width * 0.04,
              top: mq.height * 0.02,
              width: mq.width * 0.55,
              child: Text(
                widget.user.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Positioned(
              right: 6,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: widget.user,
                                )));
                  },
                  icon: Icon(
                    Icons.info,
                    color: Colors.blue,
                    size: 30,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
