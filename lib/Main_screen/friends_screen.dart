import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/app_bar_back_button.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/friend_list.dart';

class friendsScreen extends StatefulWidget {
  const friendsScreen({super.key});

  @override
  State<friendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<friendsScreen> {
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
        title: const Text('Amigos'),
      ),
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
        
            const Expanded(child: FriendList(viewType: FriendViewType.friends,)),
          ],
        ),
      )
    );
  }
}