import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:rxdart/subjects.dart';

import '../webapp.dart';

NotificationPlugin notificationPlugin = new NotificationPlugin();

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class LauncherPage extends StatefulWidget {
  LauncherPage();

  @override
  State<StatefulWidget> createState() {
    return LauncherPageState();
  }
}

class LauncherPageState extends State<LauncherPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void registerNotification() async {
    // 1. Initialize the Firebase app

    // 2. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
    setTokenLogin();

    //Set click action for local noti
    notificationPlugin.setOnNotificationClick(onNotificationClick);

    //Set handler when recieving message in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received and send local notification
      print('Nhận Firebase từ foreground');
      try {
        if (message.notification != null) {
          SharedPreferences.getInstance().then((prefs) {
            if (prefs != null) {
              String username = prefs.getString('username') ?? "";
              String password = prefs.getString('password') ?? "";
              bool isWebAPPv2 = prefs.getBool('isWebAPPv2') ?? false;

              if (username.isNotEmpty && password.isNotEmpty) {
                if (isWebAPPv2) {
                  //Truong hop moi danh cho v2
                  String url = prefs.getString('url') ?? "";
                  if (url.isNotEmpty) {
                    if (message.data['module'] != null) {
                      url = url.replaceAll("/api/api/", "");
                      url = url.replaceAll("/appmobile/api/", "");
                      url = url + message.data['module'];
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                            builder: (context) => WebAppPage(url)),
                      );
                    }
                  }
                } else {
                  notificationPlugin.showNotification(
                      message.notification.title,
                      message.notification.body,
                      json.encode(message.data));
                }
              }
            }
          });
        }
      } catch (error) {
        print(error);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Parse the message received and send local notification
      print('Nhận Firebase từ wakeup');
      try {
        if (message.notification != null) {
          SharedPreferences.getInstance().then((prefs) {
            if (prefs != null) {
              String username = prefs.getString('username') ?? "";
              String password = prefs.getString('password') ?? "";
              bool isWebAPPv2 = prefs.getBool('isWebAPPv2') ?? false;

              if (username.isNotEmpty && password.isNotEmpty) {
                if (isWebAPPv2) {
                  //Truong hop moi danh cho v2
                  String url = prefs.getString('url') ?? "";
                  if (url.isNotEmpty) {
                    if (message.data['module'] != null) {
                      url = url.replaceAll("/api/api/", "");
                      url = url.replaceAll("/appmobile/api/", "");
                      url = url + message.data['module'];
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                            builder: (context) => WebAppPage(url)),
                      );
                    }
                  }
                } else {
                  onNotificationClick(json.encode(message.data));
                }
              }
            }
          });
        }
      } catch (error) {
        print(error);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _firebaseMessaging.subscribeToTopic('hoang').then((message) {
      print("subscribe ok");
    });
  }

  @override
  initState() {
    super.initState();
    registerNotification();

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
    if (message['module'] != null) {
      AppCache.messageNotify = message;
      AppHelpers.openNextForm(context);
    } else {
      AppCache.messageNotify = null;
    }
  }

  void setTokenLogin() {
    this._firebaseMessaging.getToken().then((token) {
      print('token: ' + token);

      if (token == null) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text("Lỗi kết nối"),
                content: Text("Không có kết nối."),
                actions: <Widget>[
                  ElevatedButton(
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
            bool isWebAPPv2 = prefs.getBool('isWebAPPv2') ?? false;
            String url = prefs.getString('url') ?? "";

            String webAPPv2LoginToken =
                prefs.getString('webAPPv2LoginToken') ?? "";

            if (username.isNotEmpty && password.isNotEmpty) {
              //Co thong tin dang nhap, kiem tra xem co phai push hay ko

              _firebaseMessaging.getInitialMessage().then((message) {
                print('Nhận Firebase từ terminated');

                //open from push

                if (message != null) {
                  if (isWebAPPv2) {
                    AppCache.currentUser = Account();
                    AppCache.currentUser.isWebAPPv2 = isWebAPPv2;
                    AppCache.currentUser.webAPPv2LoginToken =
                        webAPPv2LoginToken;

                    //Truong hop moi danh cho v2
                    if (url.isNotEmpty) {
                      url = url.replaceAll("/api/api/", "");
                      url = url.replaceAll("/appmobile/api/", "");
                      url = url + message.data['module'];
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                            builder: (context) => WebAppPage(url)),
                      );
                    }
                  } else {
                    //xu ly nhu cu
                    onNotificationClick(json.encode(message.data));
                  }
                } else {
                  //open normally
                  String url = prefs.getString('url') ?? "";
                  if (url.isNotEmpty) {
                    if (isWebAPPv2) {
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                            builder: (context) => WebAppPage(url)),
                      );
                    } else {
                      if (url.contains('://') == false) {
                        url = (prefs.getInt('https') == 1
                                ? "https://"
                                : "http://") +
                            url +
                            "/api/api/";
                      }

                      FetchService.linkService = url;
                      String accountOO = prefs.getString('accountOO');
                      if (accountOO != null && accountOO.isNotEmpty) {
                        FlutterUdid.udid.then((imei) {
                          appAuth
                              .login(imei, Platform.isAndroid ? "A" : "I",
                                  username, password)
                              .then((result) {
                            if (result) {
                              AppCache.imei = imei;
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            }
                          });
                        });
                        AppCache.currentUser =
                            Account.fromJson(json.decode(accountOO));
                        AppHelpers.openNextForm(context);
                        return;
                      }
                      login(username, password);
                    }
                  }
                }
              });
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

void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  // print('notification(${notificationResponse.id}) action tapped: '
  //     '${notificationResponse.actionId} with'
  //     ' payload: ${notificationResponse.payload}');
  // if (notificationResponse.input?.isNotEmpty ?? false) {
  //   // ignore: avoid_print
  //   print(
  //       'notification action tapped with input: ${notificationResponse.input}');
  // }
  dynamic payload;
  payload = json.decode(notificationResponse.payload);
  if (payload['module'] != null) {
    AppCache.messageNotify = payload;
    AppHelpers.openNextForm(AppCache.navigatorKey.currentContext);
  } else
    AppCache.messageNotify = null;
}

class NotificationPlugin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  var initializationSettings;

  NotificationPlugin() {
    init();
  }

  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() async {
    //var initializationSettingsAndroid =
    //    AndroidInitializationSettings('app_notf_icon');
    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          ReceivedNotification receivedNotification = ReceivedNotification(
              id: id, title: title, body: body, payload: payload);
          didReceivedLocalNotificationSubject.add(receivedNotification);
        });

    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: null);
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        dynamic payload;
        payload = json.decode(notificationResponse.payload);
        if (payload['module'] != null) {
          AppCache.messageNotify = payload;
          AppHelpers.openNextForm(AppCache.navigatorKey.currentContext);
        } else
          AppCache.messageNotify = null;
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> showNotification(String title, String body, String data) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME',
        channelDescription: "CHANNEL_DESCRIPTION",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        styleInformation: DefaultStyleInformation(true, true),
        visibility: NotificationVisibility.public);
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics,
        iOS: iosChannelSpecifics,
        macOS: null);
    await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body, //null
        platformChannelSpecifics,
        payload: data);
  }
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
