import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/authentication/auth_service.dart';
import 'package:onlineoffice_flutter/authentication/launcher.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onlineoffice_flutter/webapp.dart';

AuthService appAuth = new AuthService();
String webURL='https://oodemo.web.app/';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppHelpers.getBadgeNumberRepeater();
    return GestureDetector(
        onTapDown: (detail) {
          AppHelpers.loadBadgeNumber();
        },
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          AppHelpers.loadBadgeNumber();
        },
        child: MaterialApp(
            navigatorKey: AppCache.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: "Online Office",
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/HomePage':
                  return MaterialPageRoute(builder: (context) => WebAppPage(webURL));     
                default:
                  return MaterialPageRoute(builder: (context) => WebAppPage(webURL));
              }
            },
            home: WebAppPage(webURL)));
  }
}
