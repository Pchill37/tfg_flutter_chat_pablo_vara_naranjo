import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Models/user_model.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/global_methods.dart';

class AuthenticationProvider extends ChangeNotifier{
  
  bool _isLoading =  false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //comprobar si el usuario esta logeado
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 3));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;

      //coger usuario de firestore
      await getUserDataFromFireStore();

      //guardar usuario en shared preferences
      await saveUserDataToSharedPreferences();

      notifyListeners();

      isSignedIn = true;

    } else {
      isSignedIn = false;
    }

    return isSignedIn;
  }


  //comprobar si el usuario existe

  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot = 
    await _firestore.collection(Constants.users).doc(_uid).get();
    if(documentSnapshot.exists){
      return true;
    } else {
      return false;
    }
  }

  //obtener la informacion del usuario de firestore

  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot = 
    await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  //save user data to shared preferences

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(Constants.UserModel, jsonEncode(userModel!.toMap()));
  }

  //get data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString = sharedPreferences.getString(Constants.UserModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }
  

  //registrarse con el numero de telefono
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) async{
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        _isSuccessful = false;
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        _isLoading = false;
        notifyListeners();
      // navigate to otp screen
      Navigator.of(context).pushNamed(
        Constants.otpScreen, 
        arguments: {
        Constants.verificationId : verificationId,
        Constants.phoneNumber: phoneNumber,
      },
      );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }


  //verificar el codigo de otp

  Future<void> verifyOTP({
    required String verificationId,
    required String otpcode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpcode,
    );

    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError((e){
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    });
  }

  //subir la informacion a firestore

  void saveUserDataToFirestore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if(fileImage != null){
        String imageUrl = await storeFileToStorage(
          file: fileImage,
          reference : '${Constants.userImages}/${userModel.uid}');

        userModel.image = imageUrl;
      }

      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      await _firestore
      .collection(Constants.users)
      .doc(userModel.uid)
      .set(userModel.toMap());

      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  //subit la foto a el storage y devolver la url

  Future <String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
      UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String fileUrl = await taskSnapshot.ref.getDownloadURL();
      return fileUrl;
  }

  Stream<DocumentSnapshot> userStream({required String userID}){
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

  //pillar el stream de todos los usuarios
  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  //enviar solicitud de amistad
  Future<void> sendFriendRequest({
    required String FriendID,
  }) async {
    try {
      await _firestore.collection(Constants.users).doc(FriendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });

      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequests: FieldValue.arrayUnion([FriendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> cancelFriendRequest({required String FriendID}) async {
    try {
      await _firestore.collection(Constants.users).doc(FriendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });

      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequests: FieldValue.arrayRemove([FriendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future <void> acceptFriendRequest({required String FriendID}) async {
    //añadir nuestro uid a la lista de amigos
    await _firestore.collection(Constants.users).doc(FriendID).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([_uid]),
    });

    //añadir el uid del amigo a nuestra lista de amigos
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([FriendID]),
    });

    //eliminar nuestro uid de la lista de solicitudes de amistad
    await _firestore.collection(Constants.users).doc(FriendID).update({
      Constants.sentFriendRequests: FieldValue.arrayRemove([_uid]),
    });

    //eliminar el uid del amigo de la lista de solicitudes de amistad
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendRequestsUIDs: FieldValue.arrayRemove([FriendID]),
    });
  }

  Future<void> removeFriend({required String FriendID}) async {
    //eliminar nuestro uid de la lista de amigos
    await _firestore.collection(Constants.users).doc(FriendID).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([_uid]),
    });

    //eliminar el uid del amigo de nuestra lista de amigos
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([FriendID]),
    });

  
  }

    //conseguir la lista de amigos
    Future<List<UserModel>> getFriendList(String uid) async {
      List<UserModel> friendList = [];

      DocumentSnapshot documentSnapshot = 
      await _firestore.collection(Constants.users).doc(uid).get();

      List<dynamic> friendsUIDs = documentSnapshot.get(Constants.friendsUIDs);

      for (String friendUID in friendsUIDs) {
        DocumentSnapshot documentSnapshot = 
        await _firestore.collection(Constants.users).doc(friendUID).get();
        UserModel friend = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
        friendList.add(friend);
      }
      return friendList;
    }

    //conseguir la lista de solicitudes de amistad
    Future<List<UserModel>> getFriendRequests(String uid) async {
      List<UserModel> friendRequests = [];

      DocumentSnapshot documentSnapshot = 
      await _firestore.collection(Constants.users).doc(uid).get();

      List<dynamic> friendRequestsUIDs = documentSnapshot.get(Constants.friendRequestsUIDs);

      for (String friendRequestUID in friendRequestsUIDs) {
        DocumentSnapshot documentSnapshot = 
        await _firestore.collection(Constants.users).doc(friendRequestUID).get();
        UserModel friendRequest = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
        friendRequests.add(friendRequest);
      }
      return friendRequests;
    }

    Future logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }




}