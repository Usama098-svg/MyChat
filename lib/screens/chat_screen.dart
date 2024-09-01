// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/api/apis.dart';
import 'package:my_chat/helper/date_time_converter.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user.dart';
import 'package:my_chat/models/message.dart';
import 'package:my_chat/screens/profile_screen.dart';
import 'package:my_chat/widgets/message_card.dart';
import 'package:my_chat/widgets/profile_image.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();

  bool showEmoji = false, isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = !showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            //  backgroundColor: Color.fromARGB(255, 234, 248, 255),

            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/Baground.jpg', // Replace with your image URL
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: Apis.getAllMessages(widget.user),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return Center(
                                child: SizedBox(),
                              );

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) => Message.fromJson(e.data()))
                                      .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    itemCount: _list.length,
                                    physics: BouncingScrollPhysics(),
                                    reverse: true,
                                    padding: EdgeInsets.only(
                                        top: mq.height * 0.01,
                                        bottom: mq.height * 0.01),
                                    itemBuilder: (context, index) {
                                      // return ChatUserCard(
                                      //   user: isSearching
                                      //       ? _searchList[index]
                                      //       : _list[index],
                                      // );
                                      return MessageCard(
                                        message: _list[index],
                                      );
                                    });
                              } else {
                                return Center(
                                    child: Text(
                                  'Say Hello! 👋',
                                  style: TextStyle(fontSize: 18),
                                ));
                              }
                          }
                        },
                      ),
                    ),
                    if (isUploading)
                      Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CircularProgressIndicator(),
                          )),
                    _chatInput(),
                    if (showEmoji)
                      SizedBox(
                        height: mq.height * 0.30,
                        child: EmojiPicker(
                          textEditingController: _textController,
                          config: Config(
                            columns: 8,
                            bgColor: Color.fromARGB(255, 234, 248, 255),
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return SafeArea(
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: Apis.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];

                return Row(
                  children: [
                    //back button
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black54)),

                    //user profile picture
                    ProfileImage(
                      size: mq.height * .05,
                      url: list.isNotEmpty ? list[0].image : widget.user.image,
                    ),

                    //for adding some space
                    const SizedBox(width: 10),

                    //user name & last seen time
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //user name
                        Text(list.isNotEmpty ? list[0].name : widget.user.name,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500)),

                        //for adding some space
                        const SizedBox(height: 2),

                        //last seen time of user
                        Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'Online'
                                    : MyDateTime.getLastActiveTime(
                                        context: context,
                                        lastActive: list[0].lastActive)
                                : MyDateTime.getLastActiveTime(
                                    context: context,
                                    lastActive: widget.user.lastActive),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                      ],
                    )
                  ],
                );
              })),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.02),
      child: Row(children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        showEmoji = !showEmoji;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                    )),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (showEmoji) {
                        setState(() {
                          showEmoji = !showEmoji;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        hintText: 'Type something...',
                        hintStyle: TextStyle(color: Colors.blue),
                        border: InputBorder.none),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        print('Image path : ${i.path}');
                        setState(() {
                          isUploading = true;
                        });
                        await Apis.sendChatImage(widget.user, File(i.path));
                        setState(() {
                          isUploading = false;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        print('Image path : ${image.path}');
                        setState(() {
                          isUploading = true;
                        });
                        await Apis.sendChatImage(widget.user, File(image.path));
                        setState(() {
                          isUploading = false;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_sharp,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        MaterialButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              Apis.sendFirstMessage(
                  widget.user, _textController.text, Type.text);
            } else {
              Apis.sendMessage(widget.user, _textController.text, Type.text);
            }
            _textController.text = '';
          },
          shape: CircleBorder(),
          color: Colors.green,
          minWidth: 0,
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 10),
          child: Icon(
            Icons.send,
            color: Colors.white,
            size: 28,
          ),
        )
      ]),
    );
  }
}
