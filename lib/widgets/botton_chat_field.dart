import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/chat_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';

class BottonChatField extends StatefulWidget {
  const BottonChatField({
    super.key,
    required this.contactUID,
    required this.contactImage,
    required this.groupID,
    required this.contactName,
  });

  final String contactUID;
  final String contactImage;
  final String groupID;
  final String contactName;

  @override
  State<BottonChatField> createState() => _BottonChatFieldState();
}

class _BottonChatFieldState extends State<BottonChatField> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  //mandar el mensaje a firebase
  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendTextMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      message: _textEditingController.text,
      messageType: MessageEnum.text,
      groupID: widget.groupID,
      onSucess: () {
        _textEditingController.clear();
        _focusNode.requestFocus();
      },
      onError: (error) {
        showSnackBar(context, error);
      }
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
        ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attachment),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    height: 200,
                    color: Colors.white,
                    child: const Center(
                      child: Text('Adjuntar archivo'),
                    ),
                  );
                });
            },
          ),
          Expanded(
            child: TextFormField(

              controller: _textEditingController,
              focusNode: _focusNode,
              decoration: const InputDecoration.collapsed(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Escribe un mensaje',
              ),
            ),
          ),
          GestureDetector(
            onTap: sendTextMessage,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor,
              ),
              margin: const EdgeInsets.all(5),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}