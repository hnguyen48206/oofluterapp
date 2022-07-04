import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/helpers/weblink_viewer.dart';

class WebTabViewerPageState extends State<WebTabViewerPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          this.context,
          MaterialPageRoute(
              builder: (context) =>
                  WebLinkViewerPage(title: widget.title, link: widget.link)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null, body: Center(child: CircularProgressIndicator()));
  }
}

class WebTabViewerPage extends StatefulWidget {
  final String title;
  final String link;

  WebTabViewerPage({this.title, this.link});

  @override
  State<StatefulWidget> createState() {
    return WebTabViewerPageState();
  }
}
