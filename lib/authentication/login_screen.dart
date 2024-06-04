import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/utilities/assets_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: '34',
    countryCode: 'ES',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Spain',
    example: 'Spain',
    displayName: 'Spain',
    displayNameNoCountryCode: 'ES',
    e164Key: '',);

    @override
    void dispose(){
      _phoneController.dispose();
      super.dispose();
    }
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
            body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0,),
            child: Column(
              children: [
                const SizedBox(height: 50),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(AssetsMenager.chatBubble),
                ),
            
                Text(
                  'Flutter chat', 
                  style: 
                      GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.w500,),
                ),
            
                const SizedBox(height: 20),
            
                Text(
                  'Añade tu numero de telefono para que podamos verificar tu identidad', 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    setState(() {
                      _phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Numero de telefono',
                    hintStyle: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0,),
                      child: InkWell(
                        onTap: (){
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = country;
                              });
                            }
                          );
                        },
                        child: Text(
                          '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: _phoneController.text.length > 8 
                      ? authProvider.isLoading
                        ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                        : InkWell(
                        onTap: (){
                          //registrarse con numero de telefono
                          authProvider.signInWithPhoneNumber(
                            phoneNumber: '+${selectedCountry.phoneCode}${_phoneController.text}',
                            context: context,
                          );
                        },
                        child: Container(
                            height: 35,
                            width: 35,
                            margin: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.done_sharp,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ) 
                    : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}