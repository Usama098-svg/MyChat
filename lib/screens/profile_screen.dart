// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:my_chat/helper/date_time_converter.dart';
import 'package:my_chat/models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Joined Us: ',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            MyDateTime.getLastMessageTime(
                context: context, time: widget.user.createdAt, showYear: true),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: mq.width,
                height: mq.height * 0.05,
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(mq.height * .1)),
                child: Image.network(
                  widget.user.image,
                  width: mq.height * .2,
                  height: mq.height * .2,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: mq.height * 0.03,
              ),
              Text(
                widget.user.email,
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              SizedBox(
                height: mq.height * 0.06,
              ),
              TextFormField(
                initialValue: widget.user.name,
                maxLines: null,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  label: Text('Name'),
                ),
              ),
              SizedBox(
                height: mq.height * 0.03,
              ),
              TextFormField(
                initialValue: widget.user.about,
                maxLines: null,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  label: Text('About'),
                ),
              ),
              SizedBox(
                height: mq.height * 0.03,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
