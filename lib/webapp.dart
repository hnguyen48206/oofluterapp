import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:need_resume/need_resume.dart';
import 'package:flutter/services.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:internet_file/internet_file.dart';
import 'package:internet_file/storage_io.dart';

import 'globals.dart';

class WebAppPageState extends ResumableState<WebAppPage> {
  @override
  final storageIO = InternetFileStorageIO();
  bool _isShowing = true;
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  final webviewController = WebViewController();

  String currentUrl = '';

  @override
  void onResume() {
    setState(() {
      _isShowing = true;
    });
  }

  @override
  void onReady() {}

  @override
  void onPause() {
    print('HomeScreen is paused!');
  }

  @override
  void initState() {
    super.initState();
    webviewController
      ..addJavaScriptChannel("OnlineOfficeChannel",
          onMessageReceived: (message) {
        print('Channel push');
        print(message.message);
        AppCache.getFileFromURL(message.message);
        // InternetFile.get(
        //   message.message,
        //   storage: storageIO,
        //   storageAdditional: storageIO.additional(
        //     filename: 'abc.pdf',
        //     location: '',
        //   ),
        //   progress: (receivedLength, contentLength) {
        //     final percentage = receivedLength / contentLength * 100;
        //     print(
        //         'download progress: $receivedLength of $contentLength ($percentage%)');
        //   },
        // );
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
            print('''
            Page resource error:
            code: ${error.errorCode}
            description: ${error.description}
            errorType: ${error.errorType}
            isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
    // flutterWebviewPlugin.onStateChanged.listen((state) async {
    //   if (state.type == WebViewState.finishLoad) {
    //     this.currentUrl = state.url;
    //     flutterWebviewPlugin.resize(Rect.fromLTRB(
    //       MediaQuery.of(context).padding.left,

    //       /// for safe area
    //       MediaQuery.of(context).padding.top,

    //       /// for safe area
    //       MediaQuery.of(context).size.width + 1,

    //       /// add one to make it fullscreen
    //       MediaQuery.of(context).size.height,
    //     ));
    //   }
    // });
  }

  @override
  void dispose() {
    // flutterWebviewPlugin.dispose();

    super.dispose();
    MoveToBackground.moveTaskToBack();
  }

  Future<bool> onBackClick() async {
    bool value = await webviewController.canGoBack();
    if (value == true)
      webviewController.goBack();
    else {
      MoveToBackground.moveTaskToBack();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // flutterWebviewPlugin.onUrlChanged.listen((String url) {
    //   print(url);
    // });

    return WillPopScope(
        onWillPop: () => onBackClick(),
        child: Visibility(
            visible: _isShowing,
            // maintainState: true,
            child: SafeArea(
              child: WebViewWidget(controller: webviewController),

              //  WebviewScaffold(
              //     javascriptChannels: Set.from([
              //       JavascriptChannel(
              //           name: 'OnlineOfficeChannel',
              //           onMessageReceived: (JavascriptMessage message) {
              //             print('Channel push');
              //             print(message);
              //           })
              //     ]),
              //     withJavascript: true,
              //     clearCache: false,
              //     clearCookies: false,
              //     enableAppScheme: true,
              //     withZoom: true,
              //     withLocalStorage: true,
              //     withOverviewMode: true,
              //     useWideViewPort: true,
              //     supportMultipleWindows: true,
              //     hidden: true,
              //     allowFileURLs: true,
              //     url: widget.link)
            )));
  }
}

class WebAppPage extends StatefulWidget {
  final String link;

  WebAppPage(this.link);

  @override
  State<StatefulWidget> createState() {
    return WebAppPageState();
  }
}
