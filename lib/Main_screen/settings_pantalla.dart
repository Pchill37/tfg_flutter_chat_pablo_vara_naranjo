import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/constants.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/providers/authentication_provider.dart';
import 'package:tfg_flutter_chat_pablo_vara_naranjo/widgets/app_bar_back_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingsScreen> {
  bool isDark = false;

  //pillamos el tema guardado
  void getThemeMode() async {
    //creamos una variable para guardar el tema
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    //comporbamos si el tema guardado es dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      //si es dark cambiamos el estado de isDark a true
      setState(() {
        isDark = true;
      });
    } else {
      //si no es dark cambiamos el estado de isDark a false
      setState(() {
        isDark = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    //pillamos el usuario actual
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },	
        ),
        centerTitle: true,
        title: const Text('Ajustes'),
        actions: [
          currentUser.uid == uid
              ? 
              IconButton(
                  onPressed: () async {
                    showDialog(context: context,
                     builder: (context) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                      actions: [
                        TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                         child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await context
                          .read<AuthenticationProvider>()
                          .logout()
                          .whenComplete(() {
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                            context, 
                            Constants.loginScreen,
                            (route) => false
                            );
                          });
                        },
                        child: const Text('Cerrar sesión')
                      )
                      ],
                     )
                    );
                  },
                  icon: const Icon(Icons.logout),
                )
              : const SizedBox(),
        ],
      ),

      body: Center(
        child: Card(
          child: SwitchListTile(
            title: const Text('Cambiar tema'),
            secondary: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.black : Colors.white,
              ),
              child: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            value: isDark,
            onChanged: (value) {
            //cambiamos el estado de isDark
              setState(() {
                isDark = value;
              });
              //comprobamos si isDark es true o false
              if (value) {
                //si es true cambiamos el tema a dark
                AdaptiveTheme.of(context).setDark();
              } else {
                //si es false cambiamos el tema a light
                AdaptiveTheme.of(context).setLight();
              }
            },
          ),
        ),
      ),
    ); 
  }
}