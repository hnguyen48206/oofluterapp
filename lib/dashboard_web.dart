import 'dart:async';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class DashboardWebPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardWebPageState();
  }
}

class DashboardWebPageState extends State<DashboardWebPage> {
  final controller = WebViewController()
    ..addJavaScriptChannel("OnlineOfficeChannel", onMessageReceived: (message) {
      print('Channel push');
      print(message);
    })
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {
          print(error);
        },
        onNavigationRequest: (NavigationRequest request) {
          // if (request.url.startsWith('https://www.youtube.com/')) {
          //   return NavigationDecision.prevent;
          // }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://flutter.dev'));
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
            child: WebViewWidget(controller: controller),
          )
        ])));
  }
}
