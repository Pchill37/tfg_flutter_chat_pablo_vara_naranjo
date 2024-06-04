import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/last_message_moderl.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/chat_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
        body: Padding( 
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {
                print(value);
              },
            ),
        
             Expanded(
              child: StreamBuilder<List<LastMessageModel>>(
                stream: context.read<ChatProvider>().getChatList(uid),
                builder: (context, snapshot){
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Algo ha ido mal')
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData){
                    final chatList = snapshot.data!;
                    return ListView.builder(
                      itemCount: chatList.length,
                      itemBuilder: (context, index){
                        final chat = chatList[index];
                        final dateTime = formatDate(chat.timeSent, [hh , ':', nn, ' ']);

                        final isMe = chat.senderUID == uid;

                        final lastMessage = isMe ? 'Tu: ${chat.message}' : chat.message;
                        return ListTile(
                          leading: UserImageWidget(imageUrl: chat.contactImage, radius: 40, onTap: (){}),
                          contentPadding: EdgeInsets.zero,
                          title: Text(chat.contactName,),
                          subtitle: Text(lastMessage, maxLines: 2, overflow: TextOverflow.ellipsis,),
                          trailing: Text(dateTime),
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              Constants.chatScreen,
                              arguments: {
                              Constants.contactUID: chat.contactUID,
                              Constants.contactName: chat.contactName,
                              Constants.contactImage: chat.contactImage,
                              Constants.groupID: '',
                            }
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('No tienes chats'),
                  );
              } 
              )
            ),
          ],
        ),
      ),
    );
  }
}