import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/helpers/pdf_viewer.dart';
import 'package:date_format/date_format.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:path_provider/path_provider.dart';
import 'package:need_resume/need_resume.dart';
import 'package:onlineoffice_flutter/globals.dart';

class WebLinkViewerPageState extends ResumableState<WebLinkViewerPage> {
  @override
  int currentIndex = 0;

  bool _isShowing = true;
  final filesPreview = ["pdf", "xls", "xlsx", "doc", "docx", "ppt", "pptx"];
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  bool showShare = false;
  String currentUrl = '';
  FileAttachment file = FileAttachment.empty();
  bool flagRedirect = true;

  @override
  void onResume() {
    // Implement your code inside here
    setState(() {
      // currentIndex = 1;
      print(AppCache.webviewLastURL);
      _isShowing = true;
    });
  }

  @override
  void onReady() {
    // Implement your code inside here
    // setState(() => _isShowing = true);
  }

  @override
  void onPause() {
    // Implement your code inside here
    print('HomeScreen is paused!');
  }

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.onStateChanged.listen((state) async {
      if (state.type == WebViewState.finishLoad) {
        this.currentUrl = state.url;
        if (flagRedirect == true) {
          flagRedirect = false;
          if (widget.linkRedirect.isNotEmpty &&
              widget.linkRedirect != this.currentUrl) {
            flutterWebviewPlugin
                .evalJavascript("location.href='${widget.linkRedirect}';");
            return;
          }
        }
        if (state.url.contains('Index_Mobile')) {
          if (this.showShare == true) {
            setState(() {
              this.showShare = false;
            });
          }
        } else {
          flutterWebviewPlugin.evalJavascript(
              "jQuery('#_message_id').children(0).first().css('display', 'none'); jQuery('<h4>Nhấp vào <strong style=\"color:red\">biểu tượng Download màu đen</strong> phía trên để xem hoặc tải file này về.</h4>').insertAfter(jQuery('#_message_id').children(0));");
          if (this.showShare == false) {
            setState(() {
              this.showShare = true;
            });
          }
        }
      }
    });
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    try {
      String today = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]);
      Directory dir = await getApplicationDocumentsDirectory();
      file.localPath = "${dir.path}/$today";
      await AppHelpers.createFolder(file.localPath);
      file.localPath +=
          "/${new DateTime.now().millisecondsSinceEpoch.toString()}.${file.extension}";
      dio.download(file.url, file.localPath, onReceiveProgress: (rec, total) {
        setState(() {
          file.isDownloading = true;
          String mbRec = (rec / 1048576).toStringAsFixed(1);
          String mbTotal = (total / 1048576).toStringAsFixed(1);
          file.progressing =
              "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
        });
      }).then((val) {
        setState(() {
          file.isDownloading = false;
          file.progressing = '';
        });
        if (file.extension == 'pdf') {
          setState(() {
            // currentIndex = 0;
            _isShowing = false;
          });
          // new Timer(
          //     Duration(seconds: 2), () => setState(() => _isShowing = true));
          push(
              context,
              MaterialPageRoute(
                  builder: (context) => PdfViewerPage(
                      file: file,
                      titleWebView: widget.title,
                      linkWebView: this.currentUrl)));
        } else {
          AppHelpers.openFile(file, context);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  List<Widget> getActionButtons() {
    List<Widget> result = <Widget>[];
    if (this.showShare == true && this.file.isDownloading == false) {
      result.add(IconButton(
          icon: Icon(Icons.file_download, color: Colors.black),
          onPressed: () {
            String fileName = this.currentUrl.split("/").last;
            String ext = fileName.split(".").last.toLowerCase();
            if (this.filesPreview.contains(ext)) {
              file = FileAttachment.empty();
              if (this
                  .currentUrl
                  .toLowerCase()
                  .contains("//docs.google.com/gview"))
                file.url = this.currentUrl.toLowerCase().split("url=").last;
              else
                file.url = this.currentUrl;
              file.fileName = fileName;
              file.extension = ext;
              downloadFile();
            } else {
              flutterWebviewPlugin
                  .evalJavascript("jQuery('#_myModal4').hasClass('in')")
                  .then((value) {
                if (value.toLowerCase() == 'true' || value == '1') {
                  flutterWebviewPlugin
                      .evalJavascript(
                          "document.getElementById('download').getAttribute('onclick')")
                      .then((value) {
                    String url = value
                        .replaceAll('\"', '')
                        .replaceAll('window.location.href=', '')
                        .replaceAll('\'', '');
                    file = FileAttachment.empty();
                    file.url = url;
                    file.fileName = url.split("/").last;
                    file.extension =
                        file.fileName.split(".").last.toLowerCase();
                    downloadFile();
                  });
                } else {
                  flutterWebviewPlugin
                      .evalJavascript("alert('Chọn file cần tải về')");
                }
              });
            }
          }));
    }
    result.add(IconButton(
        icon: Icon(Icons.home),
        onPressed: () {
          AppHelpers.navigatorToHome(context, IndexTabHome.More);
        }));
    return result;
  }

  Future<bool> onBackClick() async {
    bool value = await flutterWebviewPlugin.canGoBack();
    if (value == true)
      flutterWebviewPlugin.goBack();
    else {
      AppHelpers.navigatorToHome(context, IndexTabHome.More);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
      flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print(url);
      AppCache.webviewLastURL = url;
      if (url.contains('MobileTrinhKy')) {
        try {
          flutterWebviewPlugin.evalJavascript(
              "document.getElementsByTagName('canvas')[0].style.cssText='width:100%;height:auto'");
        } catch (error) {
          print(error);
        }
      }
    });
    final widgetList = [
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   color: Colors.white,
      // ),
      Visibility(
          visible: _isShowing,
          // maintainState: true,
          child: SizedBox(
              child: WebviewScaffold(
                  withJavascript: true,
                  clearCache: false,
                  clearCookies: false,
                  enableAppScheme: true,
                  withZoom: true,
                  withLocalStorage: true,
                  // withLocalUrl: true, ERROR on iOS
                  withOverviewMode: true,
                  useWideViewPort: true,
                  supportMultipleWindows: true,
                  hidden: true,
                  allowFileURLs: true,
                  appBar: AppBar(
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        icon: new Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => onBackClick(),
                      ),
                      actions: getActionButtons(),
                      centerTitle: true,
                      title: this.file.isDownloading == false
                          ? Text(widget.title)
                          : Text(this.file.progressing,
                              style: TextStyle(fontSize: 12.0))),
                  url: AppCache.webviewLastURL))),
    ];

    return WillPopScope(
        onWillPop: () => onBackClick(),
        child: IndexedStack(
          index: currentIndex,
          children: widgetList,
        ));
  }
}

class WebLinkViewerPage extends StatefulWidget {
  final String title;
  final String link;
  final String linkRedirect;

  WebLinkViewerPage({this.title, this.link, this.linkRedirect = ''});

  @override
  State<StatefulWidget> createState() {
    return WebLinkViewerPageState();
  }
}
