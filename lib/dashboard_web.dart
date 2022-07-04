import 'dart:async';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DashboardWebPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardWebPageState();
  }
}

class DashboardWebPageState extends State<DashboardWebPage> {
  final _key = UniqueKey();
  String _url = FetchService.linkService.replaceAll('api/api/', '') +
      'Dashboard.aspx?token=' +
      AppCache.tokenFCM +
      '&v=' +
      DateTime.now().millisecond.toString();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
            // appBar: AppBar(),
            body: Column(children: [
          Expanded(
              child: WebView(
                  key: _key,
                  javascriptMode: JavascriptMode.unrestricted,
                  // ignore: sdk_version_set_literal
                  javascriptChannels: <JavascriptChannel>{
                    JavascriptChannel(
                        name: 'MessageInvoker',
                        onMessageReceived: (s) {
                          if (s.message.startsWith('VB')) {
                            AppCache.tabIndexDocumentList = s.message;
                            HomePage.globalKey.currentState
                                .setFromDashboard(IndexTabHome.Document);
                          } else {
                            AppCache.tabIndexWorkList = int.parse(s.message);
                            HomePage.globalKey.currentState
                                .setFromDashboard(IndexTabHome.WorkProject);
                          }
                        })
                  },
                  initialUrl: this._url))
        ])));
  }
}
