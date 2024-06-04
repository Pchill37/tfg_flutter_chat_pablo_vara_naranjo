import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/user_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/app_bar_back_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },	
        ),
        centerTitle: true,
        title: const Text('Perfil'),
        actions: [
          currentUser.uid == uid
              ? 
              IconButton(
                  onPressed: () async {
                    //navigar a la pantalla de ajustes
                    await Navigator.pushNamed(
                      context, 
                      Constants.settingsScreen,
                      arguments: uid,);
                  },
                  icon: const Icon(Icons.settings),
                )
              : const SizedBox(),
        ],
      ),




      body: StreamBuilder(
        stream: context
            .read<AuthenticationProvider>().userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
          if (snapshot.hasError) {
            return const Center(child: Text('Algo ha ido mal'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),) ;
          }

          final userModel = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: [
                Center(
                  child: UserImageWidget(
                  imageUrl: userModel.image, 
                  radius: 60, 
                  onTap: (){
                    //navegar a la pantalla de edicion de imagen
                  }
                ),
                ),
                const SizedBox(height: 20),
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  userModel.phoneNumber,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                buildFriendRequestButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 20),

                buildFriendsButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Acerca de mi',
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    userModel.aboutMe,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel userModel,
  }){
    if (currentUser.uid == userModel.uid && userModel.friendRequestsUIDs.isNotEmpty) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: ElevatedButton(
            onPressed: () {
              //navegar a la pantalla de solicitudes de amistad
              Navigator.pushNamed(context, Constants.friendRequestScreen);
            },
            child: Text(
              'ver las solicitudes de amistad'.toUpperCase(),
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildFriendsButton({
    required UserModel currentUser,
    required UserModel userModel,
  }){
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
        return buildElevatedButton(
          onPressed: () {
            //navegar a la pantalla de amigos
            Navigator.pushNamed(context, Constants.friendsScreen);
          },
          label: 'ver amigos',
          width: MediaQuery.of(context).size.width * 0.75,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor,
        );
    } else {
      if (currentUser.uid != userModel.uid) {

        if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
        //enseñar el boton de solicitud de amistad
                //enseñar el boton de solicitud de amistad
        return buildElevatedButton(
          onPressed: () async { await context
                .read<AuthenticationProvider>()
                .cancelFriendRequest(FriendID: userModel.uid)
                .whenComplete(() {
                  showSnackBar(context, 'Solicitud de amistad cancelada');
                });
          },
          label: 'cancelar solicitud de amistad',
          width: MediaQuery.of(context).size.width * 0.75,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor,
        );
        } else if (userModel.sentFriendRequests.contains(currentUser.uid)) {
          return buildElevatedButton(
          onPressed: () async { 
            await context
                .read<AuthenticationProvider>()
                .acceptFriendRequest(FriendID: userModel.uid)
                .whenComplete(() {
                  showSnackBar(context, 'ahora tu y ${userModel.name} sois amigos');
                });
          },
          label: 'aceptar solicitud de amistad',
          width: MediaQuery.of(context).size.width * 0.75,
          backgroundColor: Theme.of(context).buttonTheme.colorScheme!.primary,
          textColor: Colors.white,
        );
        } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildElevatedButton(
              onPressed: () async { 
                //confirmacion de eliminacion de amigo

                    showDialog(context: context,
                     builder: (context) => AlertDialog(
                      title: const Text('dejar de ser amigo', textAlign: TextAlign.center,),
                      content: Text('¿Estás seguro de que quieres dejar de ser amigo de ${userModel.name}?', textAlign: TextAlign.center,),
                      actions: [
                        TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                         child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await context
                          .read<AuthenticationProvider>()
                          .removeFriend(FriendID: userModel.uid)
                          .whenComplete(() {
                            Navigator.pop(context);
                            showSnackBar(context, 'Ahora no sois amigos');
                          });
                        },
                        child: const Text('si')
                      )
                      ],
                     )
                    );



              },
              label: 'eliminar amigo',
              width: MediaQuery.of(context).size.width * 0.44,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).primaryColor,
              ),

              buildElevatedButton(
              onPressed: () async { 
                //navegar a la pantalla de chat
                                        //Navegar a la pantalla de chat con
                        //1.el uid del usuario actual 2. el grupo 3. el nombre del amigo 4. la imagen del amigo
                      Navigator.pushNamed(context, Constants.chatScreen, 
                        arguments: {
                          Constants.contactUID: userModel.uid,
                          Constants.contactName: userModel.name,
                          Constants.contactImage: userModel.image,
                          Constants.groupID: '',
                        });
              },
              label: 'chat',
              width: MediaQuery.of(context).size.width * 0.44,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).primaryColor,
              ),
            ],
          );
        } else {
        return buildElevatedButton(
          onPressed: () async { 
            await context
                .read<AuthenticationProvider>()
                .sendFriendRequest(FriendID: userModel.uid)
                .whenComplete(() {
                  showSnackBar(context, 'Solicitud de amistad enviada');
                });
          },
          label: 'enviar solicitud de amistad',
          width: MediaQuery.of(context).size.width * 0.75,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor,
        );
        }
      } else {
      return const SizedBox.shrink();
    }
  }
}

  //boton de solicitud de amistad
  Widget buildElevatedButton({
    required VoidCallback onPressed,
    required String label,
    required double width,
    required Color backgroundColor,
    required Color textColor,
  }){
      return SizedBox(
        width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }
  }
