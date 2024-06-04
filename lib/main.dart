import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/Home_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/chat_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/friend_request_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/friends_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/profile_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/Main_screen/settings_pantalla.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/authentication/landing_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/authentication/login_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/authentication/otp_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/authentication/user_information_screen.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/firebase_options.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Firebase inicializado correctamente.');

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
    ], 
    child: MyApp(savedThemeMode: savedThemeMode),),);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.savedThemeMode}) : super(key: key);

  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue[100],
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue[100],
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Chat TFG',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.loginScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPscreen(),
          Constants.userInformationScreen: (context) => 
          const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.settingsScreen: (context) => const SettingsScreen(),
          Constants.friendRequestScreen: (context) => const friendRequestScreen(),
          Constants.friendsScreen: (context) => const friendsScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          },
      ),
    );
  }
}
