import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/authentication/auth_service.dart';
import 'package:onlineoffice_flutter/authentication/launcher.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:onlineoffice_flutter/notification_plugin.dart';

AuthService appAuth = new AuthService();
NotificationPlugin notificationPlugin = new NotificationPlugin();

void main() => runApp(MyApp());

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
