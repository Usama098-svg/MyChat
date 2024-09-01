// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:my_chat/api/notification_access_token.dart';
import 'package:my_chat/models/chat_user.dart';
import 'package:my_chat/models/message.dart';

class Apis {
  // to return current user
  static User get user => FirebaseAuth.instance.currentUser!;

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get())
        .exists;
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using My Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Future<bool> addChatUser(String email) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user is logged in');
      return false;
    }

    try {
      // Query Firestore for a user with the provided email
      final data = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Check if any user was found with the provided email
      if (data.docs.isEmpty) {
        print('No user found with this email');
        return false;
      }

      // Get the ID of the found user
      final userIdToAdd = data.docs.first.id;

      // Check if the found user is not the current user
      if (userIdToAdd == user.uid) {
        print('Cannot add yourself as a chat user');
        return false;
      }

      // Add the found user to the current user's my_users sub-collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(userIdToAdd)
          .set({});

      print('User added successfully');
      return true;
    } catch (e) {
      // Handle any errors that occur during the Firestore operation
      print('Error adding user: $e');
      return false;
    }
  }

  static Future<void> deleteUserAndChat(String userId) async {
    try {
      // Delete the user from the current user's 'my_users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(userId)
          .delete();

      // Get the conversation ID using the provided method
      String conversationId = getConversationID(userId);

      // Delete all messages between the current user and the user to be deleted
      final chatCollection = FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages');

      final chatDocs = await chatCollection.get();
      for (var doc in chatDocs.docs) {
        await doc.reference.delete();
      }

      print('User and chat history deleted successfully');
    } catch (e) {
      print('Error deleting user and chat history: $e');
    }
  }

  static String getChatId(String userId, String peerId) {
    return userId.hashCode <= peerId.hashCode
        ? '$userId-$peerId'
        : '$peerId-$userId';
  }

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('push token : $t');
      }
    });
  }

  // for sending push notification (Updated Codes)
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,
          },
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
      const projectID = 'mychat-6293d';

      // get firebase admin token
      final bearerToken = await NotificationAccessToken.getToken;

      log('bearerToken: $bearerToken');

      // handle null token
      if (bearerToken == null) return;

      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // // for getting all users from firestore database
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .where('id', isNotEqualTo: user.uid)
  //       .snapshots();
  // }

  // for getting user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online and last seen
  static Future<void> updateActiveStatus(bool isOnline) async {
    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        await Apis.updateActiveStatus(true);
        print('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return FirebaseFirestore.instance
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfileImage(File file) async {
    final ext = file.path.split('.').last;
    print('Image extension : $ext');
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_picture/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Image uploaded');
    });

    me.image = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return FirebaseFirestore.instance
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg,
    Type type,
  ) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = FirebaseFirestore.instance
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    FirebaseFirestore.instance
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return FirebaseFirestore.instance
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Image uploaded');
    });

    final imagUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imagUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await FirebaseStorage.instance.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
