import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/user_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';

class FriendList extends StatelessWidget {
  const FriendList({super.key, required this.viewType,});

  final FriendViewType viewType;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    final Future = viewType == FriendViewType.friends
        ? context.read<AuthenticationProvider>().getFriendList(uid)
        : viewType == FriendViewType.friendRequests
            ? context.read<AuthenticationProvider>().getFriendRequests(uid)
            : context.read<AuthenticationProvider>().getFriendList(uid);
    return FutureBuilder<List<UserModel>>(
    future: Future,
    
    builder: 
        (context, snapshot) {

          if (snapshot.hasError) {
            return const Center(child: Text("algo ha ido mal"));

          } 

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("no tienes amigos"));
        }

          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final data = snapshot.data![index];
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: -10),
                  leading: UserImageWidget(
                  imageUrl: data.image,
                  radius: 40,
                  onTap: (){

                    Navigator.pushNamed(context, Constants.userInformationScreen, arguments: data.uid);

                  }),
                  title: Text(data.name),
                  subtitle: Text(
                    data.aboutMe,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {

                      if (viewType == FriendViewType.friends) {
                        //Navegar a la pantalla de chat con
                        //1.el uid del usuario actual 2. el grupo 3. el nombre del amigo 4. la imagen del amigo
                      Navigator.pushNamed(context, Constants.chatScreen, 
                        arguments: {
                          Constants.contactUID: data.uid,
                          Constants.contactName: data.name,
                          Constants.contactImage: data.image,
                          Constants.groupID: '',
                        });
                      } else if (viewType == FriendViewType.friendRequests) {
                        await context
                        .read<AuthenticationProvider>()
                        .acceptFriendRequest(FriendID: data.uid)
                        .whenComplete(() {
                          showSnackBar(context, 'ahora tu y ${data.name} sois amigos');
                        });
                      } else {
                        //Navigator.pushNamed(context, Constants.chatScreen, arguments: data.uid);
                      }

                    },
                    child: viewType == FriendViewType.friends 
                    ? const Text('Chat') 
                    : const Text('Aceptar'),
                  ),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
    
    );
  }
}