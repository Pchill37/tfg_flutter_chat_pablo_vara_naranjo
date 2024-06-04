import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/app_bar_back_button.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/friend_list.dart';

class friendRequestScreen extends StatefulWidget {
  const friendRequestScreen({super.key});

  @override
  State<friendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<friendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },	
        ),
        centerTitle: true,
        title: const Text('Solicitudes de amistad'),
      ),
      body: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {
                print(value);
              },
            ),
        
            const Expanded(child: FriendList(viewType: FriendViewType.friendRequests,)),
          ],
        ),
    );
  }
}