import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

import 'package:rxdart/subjects.dart';

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
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title, body: body, payload: payload);
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );

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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

  Future<void> showNotification(String title, String body, String data) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME', "CHANNEL_DESCRIPTION",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        styleInformation: DefaultStyleInformation(true, true),
        visibility: NotificationVisibility.public);
    var iosChannelSpecifics = IOSNotificationDetails();
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

  // Future<void> showDailyAtTime() async {
  //   var time = Time(21, 3, 0);
  //   var androidChannelSpecifics = AndroidNotificationDetails(
  //     'CHANNEL_ID 4',
  //     'CHANNEL_NAME 4',
  //     "CHANNEL_DESCRIPTION 4",
  //     importance: Importance.Max,
  //     priority: Priority.High,
  //   );
  //   var iosChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics =
  //       NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.showDailyAtTime(
  //     0,
  //     'Test Title at ${time.hour}:${time.minute}.${time.second}',
  //     'Test Body', //null
  //     time,
  //     platformChannelSpecifics,
  //     payload: 'Test Payload',
  //   );
  // }

  // Future<int> getPendingNotificationCount() async {
  //   List<PendingNotificationRequest> p =
  //       await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  //   return p.length;
  // }

  // Future<void> cancelNotification() async {
  //   await flutterLocalNotificationsPlugin.cancel(0);
  // }

  // Future<void> cancelAllNotification() async {
  //   await flutterLocalNotificationsPlugin.cancelAll();
  // }
}

// NotificationPlugin notificationPlugin = NotificationPlugin._();

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
