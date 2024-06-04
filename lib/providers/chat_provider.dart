import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/last_message_moderl.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/message_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/message_reply_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/user_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isloading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isloading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setLoading(bool value) {
    _isloading = value;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  //iniciamos firebase 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //mandamos el mensaje a firebase
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupID,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    try {
      var messageID = const Uuid().v4();


    String repliedMessage = _messageReplyModel?.message ?? '';
    String repliedTo = _messageReplyModel == null ? '' : _messageReplyModel!.isMe ? 'Tu' : _messageReplyModel!.senderName;
    MessageEnum repliedMessageType = _messageReplyModel?.messageType ?? MessageEnum.text;


    final messageModel = MessageModel(
      senderUID: sender.uid,
      senderName: sender.name,
      senderImage: sender.image,
      contactUID: contactUID,
      message: message,
      messageType: messageType,
      timeSent: DateTime.now(),
      messageId: messageID,
      isSeen: false,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
    );


    if (groupID.isNotEmpty){
      //mensajes de grupo
    } else {
      //mensaje de contacto

      await handleContactMessage(
        messageModel: messageModel,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        onSucess: onSucess,
        onError: onError,
      );


      setMessageReplyModel(null);
    }

  } catch (e) {
    onError(e.toString());
  }
}

  Future<void> handleContactMessage(
    {required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSucess,
    required Function(String p1) onError}) async {

      try {

        final contactMessageModel = messageModel.copyWith(
          userID: messageModel.senderUID,
        );

        final senderLastMessage = LastMessageModel(
          senderUID: messageModel.senderUID,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          message: messageModel.message,
          messageType: messageModel.messageType,
          timeSent: messageModel.timeSent,
          isSeen: false,
        );

        final contactLastMessage = senderLastMessage.copyWith(
          contactUID: messageModel.senderUID,
          contactName: messageModel.senderName,
          contactImage: messageModel.senderImage,
          );



        await _firestore.runTransaction((transaction) async {

          transaction.set(
            _firestore
            .collection(Constants.users)
            .doc(messageModel.senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageModel.messageId),
          messageModel.toMap(),
          );

          transaction.set(
            _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(messageModel.senderUID)
            .collection(Constants.messages)
            .doc(messageModel.messageId),
          contactMessageModel.toMap(),
          );

          transaction.set(
            _firestore
            .collection(Constants.users)
            .doc(messageModel.senderUID)
            .collection(Constants.chats)
            .doc(contactUID),
            senderLastMessage.toMap(),
          );

          transaction.set(
            _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(messageModel.senderUID),
            contactLastMessage.toMap(),
          );
        });


        onSucess();
      } on FirebaseException catch (e) {
        onError(e.message ?? e.toString());
      } catch (e) {
        onError(e.toString());
      }
    }

    //get chatList stream
    Stream<List<LastMessageModel>> getChatList(String userID) {
      return _firestore
        .collection(Constants.users)
        .doc(userID)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot){
          return snapshot.docs.map((doc) {
            return LastMessageModel.fromMap(doc.data());
          }).toList();
        });
    } 

    Stream<List<MessageModel>> getMessages({
      required String userID, 
      required String contactUID,
      required String isGroup,
      }) {
        if (isGroup.isNotEmpty) {
          return _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .snapshots()
            .map((snapshot){
              return snapshot.docs.map((doc) {
                return MessageModel.fromMap(doc.data());
              }).toList();
            });
        } else {
      return _firestore
        .collection(Constants.users)
        .doc(userID)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        .snapshots()
        .map((snapshot){
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
    }
  }
}