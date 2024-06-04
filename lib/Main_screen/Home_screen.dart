import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/my_chats_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/groups_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/people_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/assets_manager.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    MyChatsScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat TFG'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: UserImageWidget(imageUrl: authProvider.userModel!.image, 
            radius: 20, 
            onTap: (){
              Navigator.pushNamed(context, 
              Constants.profileScreen, 
              arguments: authProvider.userModel!.uid,
              
              );
            },
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index){
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group), label: 'grupos',),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe), label: 'comunidad',),
        ],
        currentIndex: currentIndex,
        onTap: (index){
          //animacion de la pagina
          pageController.animateToPage(index, 
              duration: const Duration(milliseconds: 300), 
              curve: Curves.easeIn);
          setState(() {
            currentIndex = index;
          });
        },
      )); 
  }
}