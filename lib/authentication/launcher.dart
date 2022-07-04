import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:onlineoffice_flutter/authentication/login.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/main.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'dart:io' show Platform;

class LauncherPage extends StatefulWidget {
  LauncherPage();

  @override
  State<StatefulWidget> createState() {
    return LauncherPageState();
  }
}

class LauncherPageState extends State<LauncherPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static Future<void> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    // if (message.containsKey('data')) {
    //   // Handle data message
    //   final dynamic data = message['data'];
    // }

    // if (message.containsKey('notification')) {
    //   // Handle notification message
    //   final dynamic notification = message['notification'];
    // }

    // Or do other work.
  }

  @override
  initState() {
    super.initState();
    setTokenLogin();
    if (Platform.isIOS) {
      this._firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: true));
    }
    this._firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if (message['notification'] != null &&
              (Platform.isAndroid
                      ? message['data']['module']
                      : message['module']) !=
                  null) {
            notificationPlugin.showNotification(
                message['notification']['title'],
                message['notification']['body'],
                json.encode(message));
          }
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onResume: (Map<String, dynamic> message) async {
          checkNotify(message);
        },
        onLaunch: (Map<String, dynamic> message) async {
          checkNotify(message);
        });
    // notificationPlugin
    //     .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);

    AppHelpers.loadBadgeNumber();
  }

  // onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
  //   print('Notification Received ${receivedNotification.id}');
  // }

  onNotificationClick(String payload) {
    print(payload);
    checkNotify(json.decode(payload));
  }

  Future<void> checkNotify(Map<String, dynamic> message) async {
    if ((Platform.isAndroid ? message['data']['module'] : message['module']) !=
        null) {
      AppCache.messageNotify = message;
      AppHelpers.openNextForm(context);
    } else {
      AppCache.messageNotify = null;
    }
  }

  void setTokenLogin() {
    this._firebaseMessaging.getToken().then((token) {
      if (token == null) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text("Lỗi kết nối"),
                content: Text("Không có kết nối."),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setTokenLogin();
                      },
                      child: Text("Thử lại",
                          style: TextStyle(color: Colors.black)))
                ],
              );
            });
      } else {
        AppCache.tokenFCM = token;
        SharedPreferences.getInstance().then((prefs) {
          if (prefs != null) {
            String username = prefs.getString('username') ?? "";
            String password = prefs.getString('password') ?? "";
            if (username.isNotEmpty && password.isNotEmpty) {
              String url = prefs.getString('url') ?? "";
              if (url.isNotEmpty) {
                if (url.contains('://') == false) {
                  url = (prefs.getInt('https') == 1 ? "https://" : "http://") +
                      url +
                      "/api/api/";
                }
              }
              FetchService.linkService = url;
              String accountOO = prefs.getString('accountOO');
              if (accountOO != null && accountOO.isNotEmpty) {
                FlutterUdid.udid.then((imei) {
                  appAuth
                      .login(imei, Platform.isAndroid ? "A" : "I", username,
                          password)
                      .then((result) {
                    if (result) {
                      AppCache.imei = imei;
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    }
                  });
                });
                AppCache.currentUser = Account.fromJson(json.decode(accountOO));
                AppHelpers.openNextForm(context);
                return;
              }
              login(username, password);
            } else {
              Navigator.push(
                this.context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _getDetailLayout() {
      List<Widget> result = [];
      result.add(SizedBox(
        height: 150.0,
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Image(
                image: new AssetImage("images/logo_150.jpg"),
                fit: BoxFit.fitHeight)),
      ));
      result.add(SizedBox(height: 20.0));
      result.add(Text("ONLINE OFFICE",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 30.0)));

      return result;
    }

    return WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _getDetailLayout()))));
  }

  // openNextForm() async {
  //   if (AppCache.currentUser.isOldVersion) {
  //     if (AppCache.messageNotify == null) {
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => OldVersionPage()));
  //     } else {
  //       String module;
  //       String id;
  //       if (Platform.isAndroid == true) {
  //         module = AppCache.messageNotify['data']['module'];
  //         id = AppCache.messageNotify['data']['id'];
  //       } else {
  //         module = AppCache.messageNotify['module'];
  //         id = AppCache.messageNotify['id'];
  //       }
  //       AppCache.messageNotify = null;
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => OldVersionPage(module: module, id: id)));
  //     }
  //   } else {
  //     if (AppCache.messageNotify == null) {
  //       AppHelpers.navigatorToHome(context, IndexTabHome.Dashboard);
  //     } else {
  //       bool isOpenDetailFromNotify =
  //           await openDetailNewVersionFromNotify(AppCache.messageNotify);
  //       if (isOpenDetailFromNotify == false) {
  //         String module;
  //         String id;
  //         if (Platform.isAndroid == true) {
  //           module = AppCache.messageNotify['data']['module'];
  //           id = AppCache.messageNotify['data']['id'];
  //         } else {
  //           module = AppCache.messageNotify['module'];
  //           id = AppCache.messageNotify['id'];
  //         }
  //         String linkWeb =
  //             FetchService.getLinkMobileLogin() + "&L=" + module + "&I=" + id;
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => WebLinkViewerPage(
  //                     title: "Online Office", link: linkWeb)));
  //       }
  //     }
  //   }
  // }

  login(String username, String password) {
    FlutterUdid.udid.then((imei) {
      appAuth
          .login(imei, Platform.isAndroid ? "A" : "I", username, password)
          .then((result) {
        if (result) {
          AppCache.imei = imei;
          AppHelpers.openNextForm(context);
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      });
    });
  }
}
