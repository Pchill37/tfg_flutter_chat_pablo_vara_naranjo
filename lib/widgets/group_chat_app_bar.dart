// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
// import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
// import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';

// class GroupChatAppBar extends StatefulWidget {
//   const GroupChatAppBar({super.key, required this.groupID});

//   final String groupID;

//   @override
//   State<GroupChatAppBar> createState() => _GroupChatAppBarState();
// }

// class _GroupChatAppBarState extends State<GroupChatAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: context
//             .read<AuthenticationProvider>().userStream(userID: widget.groupID),
//         builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
//           if (snapshot.hasError) {
//             return const Center(child: Text('Algo ha ido mal'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(),) ;
//           }

//           final groupModel = GroupModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

//           return Row(
//               children: [
//                 UserImageWidget(
//                   imageUrl: groupModel.image,
//                   radius: 20,
//                   onTap: () {
//                     //navegar a la pantalla de grupo
//                   },
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(groupModel.name),
//                     const Text (
//                       'En linea', 
//                     //userModel.isOnline ? 'En linea' : 'Desconectado'
//                     //
//                     style: TextStyle(fontSize: 12,),
//                     ),
//                   ],
//                 ),
//               ],
//             );           
//           },
//         );
//       }
//     }