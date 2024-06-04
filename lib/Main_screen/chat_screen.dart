import 'package:flutter/material.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/botton_chat_field.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/chat_app_bar.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/chat_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    //pillar los argumentos
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    //pillar el uid del contacto con el que se va a chatear
    final contactUID = arguments[Constants.contactUID];

    //pillar el nombre del contacto con el que se va a chatear
    final contactName = arguments[Constants.contactName];

    //pillar la imagen del contacto con el que se va a chatear
    final contactImage = arguments[Constants.contactImage];

    //pillar el id del grupo si se va a chatear en un grupo
    final groupID = arguments[Constants.groupID];

    //mirar si se va a chatear con un contacto o en un grupo
    final isGroupChat = groupID.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: chatList(contactUID: contactUID, groupID: groupID),
            ),
            BottonChatField(
              contactUID: contactUID,
              contactImage: contactImage,
              groupID: groupID,
              contactName: contactName,
            ),
          ],
        ),
      ),
    );
  }
}
