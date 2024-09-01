// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/api/apis.dart';
import 'package:my_chat/helper/date_time_converter.dart';
import 'package:my_chat/helper/dialogs.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user.dart';
import 'package:my_chat/models/message.dart';
import 'package:my_chat/screens/chat_screen.dart';
import 'package:my_chat/widgets/dialogs/profile_image_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onLongPress: () {
            _showDeleteConfirmationDialog();
          },
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: Apis.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final _list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (_list.isNotEmpty) {
                  _message = _list[0];
                }

                return ListTile(
                  // leading: CircleAvatar(
                  //   child: Icon(CupertinoIcons.person),
                  // ),
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileImageDialog(
                                user: widget.user,
                              ));
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: mq.height *
                          0.0275, // Adjust the radius to your preferred size
                      child: ClipOval(
                        // Clip the image to a circular shape
                        child: Image.network(
                          widget.user.image,
                          fit: BoxFit.cover,
                          width: mq.height *
                              0.055, // Set the size of the image to match the avatar
                          height: mq.height * 0.055,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            CupertinoIcons.person,
                            size: mq.height * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),

                  title: Text(widget.user.name),
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? "image"
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                  ),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != Apis.user.uid
                          ? Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(
                              MyDateTime.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: TextStyle(color: Colors.black54),
                            ),
                );
              })),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                await _deleteUser(); // Perform deletion
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    try {
      // Delete the user from Firestore
      await Apis.deleteUserAndChat(widget.user.id).then((value) {
        Dialogs.showSnackbar(context, 'User deleted successfully');
      });

      // Refresh the UI
      setState(() {});
    } catch (e) {
      // Handle any errors here
      print('Error deleting user: $e');
      Dialogs.showSnackbar(context, 'Failed to delete user');
    }
  }
}
