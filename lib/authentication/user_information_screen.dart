import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/user_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/assets_manager.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/app_bar_back_button.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/display_user_image.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
    final RoundedLoadingButtonController _btnController = 
      RoundedLoadingButtonController();
    final TextEditingController _nameController = TextEditingController();
    File? finalFileImage;
    String userImage = '';

    @override
  void dispose() {
    _btnController.stop();
    _nameController.dispose();
    super.dispose();
  }


  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    // crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  } 

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
        );


        if (croppedFile != null) {
          setState(() {
            finalFileImage = File(croppedFile.path);
          });
        } else {
          //popTheDialog();
        }
    }
  }



  void showBottonSheet() {
    showModalBottomSheet(context: context, 
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height/5,
      child: Column(
        children: [
          ListTile(
            onTap: () {
              selectImage(true);
            },
            leading: const Icon(Icons.camera_alt),
            title: const Text('camara'),
          ),
          ListTile(
            onTap: () {
              selectImage(false);
              Navigator.of(context).pop();
            },
            leading: const Icon(Icons.image),
            title: const Text('galeria'),
          ),
        ],
      ),
    ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text('Informacion de usuario'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0,
          ),
          child: Column(
            children:[
              DisplayUserImage(finalFileImage: finalFileImage, radius: 60, onPressed: (){
                showBottonSheet();
              
              },),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'introduce tu Nombre',
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: () {
                    if (_nameController.text.isEmpty || _nameController.text.length < 3) {
                      showSnackBar(context, 'Por favor, introduce tu nombre');
                      _btnController.reset();
                      return;
                      
                    }
                    //save user information
                    saveUserDataToFirestore();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).primaryColor,
                  child: const Text(
                    'continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveUserDataToFirestore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      tokens: '',
      aboutMe: 'Hola, estoy usando Chatter la mejor app de mensajeria del mundo',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequests: [],
    );

    authProvider.saveUserDataToFirestore(
      userModel: userModel,
      fileImage: finalFileImage,
      onSuccess: () async {
        _btnController.success();
        await authProvider.saveUserDataToSharedPreferences();

        navigateToHomeScreen();
      },
      onFail: () async {
        _btnController.error();
        showSnackBar(context, 'Error al guardar la informacion del usuario');
        await Future.delayed(const Duration(seconds: 1));
        _btnController.reset();
      },
    );
  }  

void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}