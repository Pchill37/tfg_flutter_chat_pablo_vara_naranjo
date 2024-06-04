import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';

class OTPscreen extends StatefulWidget {
  const OTPscreen({super.key});

  @override
  State<OTPscreen> createState() => _OTPscreenState();
}

class _OTPscreenState extends State<OTPscreen> {
  
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpcode;

  @override
  void dispose(){
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blueGrey,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0,),
          child: Column(
            children: [
              const SizedBox(height: 50),
            Text(
              'Verificacion de numero de telefono',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Introduce el codigo de verificacion que hemos enviado a tu numero de telefono',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              phoneNumber,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 45),
            SizedBox(
              height: 68,
              child: Pinput(
                length: 6,
                controller: controller,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin){
                  setState(() {
                    otpcode = pin;
                  });
                  //veriicar el codigo otp
                  verifyOTPCode(
                    verificationId: verificationId,
                    otpcode: otpcode!,
                  );

                },
                focusedPinTheme: defaultPinTheme.copyWith(
                  height: 60,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blue,
                    ),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                  height: 60,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            authProvider.isLoading
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),

            authProvider.isSuccessful ? Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Icon(
                Icons.done,
                color: Colors.white,
                size: 30,
              ),
            ) : const SizedBox.shrink(),


            authProvider.isLoading ? const SizedBox.shrink() :
            Text(
              '¿No has recibido el codigo?',
              style: GoogleFonts.openSans(
                fontSize: 16,
              ),
            ),
              const SizedBox(height: 10),
              authProvider.isLoading ? const SizedBox.shrink() :
              TextButton(onPressed: () {
                //todo reenviar codigo
              }, child: Text('Reenviar codigo',
              style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500,),)),
            ],
          ),
        )
      ),
    );
  }

  void verifyOTPCode ({
    required String verificationId,
    required String otpcode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTP(
      verificationId: verificationId,
      otpcode: otpcode,
      context: context,
      onSuccess: () async{
        // mirar si el usuario ya existe

        bool userExists = await authProvider.checkUserExists();

        if (userExists){

        //si existe

        //obtener la informacion del usuario
        await authProvider.getUserDataFromFireStore();

        //guardar la informacion del usuario
        await authProvider.saveUserDataToSharedPreferences();

        //navegar a la pantalla de inicio
        navigate(userExists: true);

        } else {
          //si no existe, navegar a la pantalla de informacion de usuario
        navigate(userExists: false);
        }
      },
    );
  }

  void navigate ({required bool userExists}) {
    if (userExists){

      Navigator.pushNamedAndRemoveUntil(
        context, 
        Constants.homeScreen,
        (route) => false,
        );
    } else {
      Navigator.pushNamed(
        context, 
        Constants.userInformationScreen,
      );
    }
  }
}