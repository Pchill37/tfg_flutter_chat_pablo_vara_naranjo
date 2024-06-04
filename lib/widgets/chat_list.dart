
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/message_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/chat_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/contact_message_widget.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/my_message_widget.dart';

class chatList extends StatefulWidget {
  const chatList({super.key, required this.contactUID, required this.groupID});

  final String contactUID;
  final String groupID;

  @override
  State<chatList> createState() => _chatListState();
}

class _chatListState extends State<chatList> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<List<MessageModel>>(
                stream: context
                    .read<ChatProvider>()
                    .getMessages(userID: uid, contactUID: widget.contactUID, isGroup: widget.groupID),
                builder: (context, snapshot){
                  if (snapshot.hasError) {
                    return const Center(child: Text('Algo ha ido mal'));
                  }
                  
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if(snapshot.data!.isEmpty){
                    return Center(
                      child: Text('Empieza a chatear', textAlign: TextAlign.center, style: GoogleFonts.openSans(
                        fontSize: 18,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      )),
                    );
                  }	
                  
                  if (snapshot.hasData){
                    final messagesList = snapshot.data!;
                    return GroupedListView<MessageModel, DateTime>(
                      reverse: true,
                      elements: messagesList,
                      groupBy: (element){
                        return DateTime(
                          element.timeSent.year,
                          element.timeSent.month,
                          element.timeSent.day,
                        );
                      },
                      groupHeaderBuilder: (dynamic groupedByValue) =>
                      buildDateTime(groupedByValue),
                      itemBuilder: (context, MessageModel element) {
                        //comprobar si mandamos el ultimo mensaje
                        final isMe = element.senderUID == uid;
                        return isMe ? 
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: MyMessageWidget(message: element),
                        ) : 
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: ContactMessageWidget(message: element,),
                        );
                      },
                      groupComparator: (value1, value2) => 
                        value2.compareTo(value1),
                      itemComparator: (item1, item2) {
                        var firstItem = item1.timeSent;

                        var secondItem = item2.timeSent;

                        return secondItem.compareTo(firstItem);
                      },
                      useStickyGroupSeparators: true,
                      floatingHeader: true,
                      order: GroupedListOrder.ASC,
                    );
                  }
                  return const SizedBox.shrink();
                }
              );
  }


}