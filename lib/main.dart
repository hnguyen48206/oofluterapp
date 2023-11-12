import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/authentication/auth_service.dart';
import 'package:onlineoffice_flutter/authentication/launcher.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

AuthService appAuth = new AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final storage_permission = Permission.storage;
  final camera_permission = Permission.camera;
  if (await storage_permission.isDenied) {
    await storage_permission.request();
  }
  if (await camera_permission.isDenied) {
    await camera_permission.request();
  }
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
                  return MaterialPageRoute(builder: (context) => HomePage());
                // case '/TraoDoiCV':
                //   return MaterialPageRoute(
                //       builder: (_) =>
                //           HomePage(startTabIndex: IndexTabHome.DiscussWork));
                default:
                  return MaterialPageRoute(builder: (context) => HomePage());
              }
            },
            home: LauncherPage()));
  }
}
