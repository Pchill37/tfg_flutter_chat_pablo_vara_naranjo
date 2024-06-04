import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/user_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';

class ChatAppBar extends StatefulWidget {
  const ChatAppBar({super.key, required this.contactUID});

  final String contactUID;

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: context
            .read<AuthenticationProvider>().userStream(userID: widget.contactUID),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
          if (snapshot.hasError) {
            return const Center(child: Text('Algo ha ido mal'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),) ;
          }

          final userModel = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Row(
              children: [
                UserImageWidget(
                  imageUrl: userModel.image,
                  radius: 20,
                  onTap: () {
                    Navigator.pushNamed(context, Constants.profileScreen, arguments: userModel.uid);
                  },
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userModel.name,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                      ),
                    ),
                    Text (
                      'En linea', 
                    //userModel.isOnline ? 'En linea' : 'Desconectado'
                    //
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }
    }