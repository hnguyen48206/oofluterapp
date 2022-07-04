import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';

class SignatureEditPageState extends State<SignatureEditPage> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  int indexPage = 0;
  int totalPage = 0;
  String currentPage = '';

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.onStateChanged.listen((state) async {
      if (state.type == WebViewState.finishLoad) {
        flutterWebviewPlugin.evalJavascript("getCountPage();").then((value) {
          if (value != null && value.isNotEmpty) {
            value = value.replaceAll('"', '');
            setState(() {
              this.currentPage = value;
              var arr = value.split("/");
              this.indexPage = int.parse(arr[0]) - 1;
              this.totalPage = int.parse(arr[1]);
            });
          }
        });
      }
    });
  }

  String getLink(String pageIndex) {
    String link = FetchService.getDomainLink() +
        '/TrinhKyDienTu/MobileTrinhKy.aspx?UserId=' +
        AppCache.currentUser.userId +
        '&RecordId=' +
        AppCache.currentSignature.id +
        '&FilePDF=' +
        widget.filePDF;
    if (pageIndex.isNotEmpty) {
      link += "&Page=" + pageIndex;
    }
    return link + "&t=" + DateTime.now().microsecond.toString();
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        withJavascript: true,
        clearCache: true,
        clearCookies: true,
        enableAppScheme: true,
        withZoom: true,
        withLocalStorage: false,
        // withLocalUrl: true, ERROR on iOS
        withOverviewMode: true,
        useWideViewPort: true,
        supportMultipleWindows: false,
        hidden: true,
        allowFileURLs: true,
        bottomNavigationBar: BottomAppBar(
            color: Colors.greenAccent,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getBottomIcons())),
        appBar: AppBar(actions: [
          IconButton(
              icon: Icon(Icons.edit_rounded, color: Colors.black),
              onPressed: () {
                flutterWebviewPlugin.evalJavascript("signOnClick();");
              })
        ], centerTitle: true, title: Text(widget.filePDF)),
        url: getLink(''));
  }

  List<Widget> getBottomIcons() {
    List<Widget> result = [];

    result.add(Text('Trang ',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
    if (this.indexPage > 0) {
      result.add(IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: () => flutterWebviewPlugin
              .reloadUrl(getLink((this.indexPage - 1).toString()))));
    }
    result.add(Text(this.currentPage,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));

    if (this.indexPage < this.totalPage - 1) {
      result.add(IconButton(
          icon: Icon(Icons.navigate_next),
          onPressed: () => flutterWebviewPlugin
              .reloadUrl(getLink((this.indexPage + 1).toString()))));
    }
    result.add(Spacer());
    result.add(IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () =>
            flutterWebviewPlugin.evalJavascript("signMoveLeft();")));
    result.add(IconButton(
        icon: Icon(Icons.arrow_forward),
        onPressed: () =>
            flutterWebviewPlugin.evalJavascript("signMoveRight();")));
    result.add(IconButton(
        icon: Icon(Icons.arrow_upward),
        onPressed: () => flutterWebviewPlugin.evalJavascript("signMoveUp();")));
    result.add(IconButton(
        icon: Icon(Icons.arrow_downward),
        onPressed: () =>
            flutterWebviewPlugin.evalJavascript("signMoveDown();")));
    return result;
  }
}

class SignatureEditPage extends StatefulWidget {
  SignatureEditPage({this.filePDF});
  final String filePDF;

  @override
  State<StatefulWidget> createState() {
    return SignatureEditPageState();
  }
}
