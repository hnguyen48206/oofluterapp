import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:onlineoffice_flutter/authentication/login.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/helpers/pdf_viewer.dart';
import 'package:onlineoffice_flutter/main.dart';
import 'package:date_format/date_format.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:path_provider/path_provider.dart';

class OldVersionPageState extends State<OldVersionPage> {
  final filesPreview = ["pdf", "xls", "xlsx", "doc", "docx", "ppt", "pptx"];
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  bool showShare = false;
  String currentUrl = '';
  FileAttachment file = FileAttachment.empty();
  bool flagRedirect = true;

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
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => PdfViewerPage(
                      file: file,
                      titleWebView: 'Online Office',
                      linkWebView: this.currentUrl,
                      isWebOldVersion: true)));
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
          flutterWebviewPlugin.reloadUrl(FetchService.getLinkMobileLogin());
        }));
    result.add(IconButton(
        icon: Icon(Icons.exit_to_app, color: Colors.black45),
        onPressed: () {
          appAuth.logout().then((prefs) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        }));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return new Future(() => flutterWebviewPlugin.goBack());
        },
        child: WebviewScaffold(
            withJavascript: true,
            clearCache: true,
            clearCookies: true,
            enableAppScheme: true,
            withZoom: true,
            withLocalStorage: true,
            // withLocalUrl: true, ERROR on iOS
            withOverviewMode: true,
            useWideViewPort: true,
            supportMultipleWindows: true,
            hidden: true,
            allowFileURLs: true,
            resizeToAvoidBottomInset: true,
            geolocationEnabled: true,
            appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: new Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => flutterWebviewPlugin.goBack(),
                ),
                actions: getActionButtons(),
                centerTitle: true,
                title: this.file.isDownloading == false
                    ? Text('Online Office')
                    : Text(this.file.progressing,
                        style: TextStyle(fontSize: 12.0))),
            url: _getLink()));
  }

  _getLink() {
    String result = FetchService.getLinkMobileLogin();
    if (widget.module != null && widget.module.isNotEmpty) {
      result += "&L=" + widget.module;
      if (widget.id != null && widget.id.isNotEmpty) {
        result += "&I=" + widget.id;
      }
    }
    return result;
  }
}

class OldVersionPage extends StatefulWidget {
  OldVersionPage({this.module, this.id, this.linkRedirect = ''});

  final String module;
  final String id;
  final String linkRedirect;

  @override
  State<StatefulWidget> createState() {
    return OldVersionPageState();
  }
}
