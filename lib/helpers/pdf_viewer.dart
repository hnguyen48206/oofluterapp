import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/helpers/weblink_viewer.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
// import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
// import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
// import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:onlineoffice_flutter/old_version.dart';
import 'dart:io' show Platform;
import 'package:need_resume/need_resume.dart';

class PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  // PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    // document = await PDFDocument.fromFile(File(widget.file.localPath));
    try {
      setState(() => _isLoading = false);
    } catch (e) {}
  }

  Future<bool> onBackClick() async {
    if (widget.isWebOldVersion) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OldVersionPage(linkRedirect: widget.linkWebView)));
    } else {
      Navigator.pop(context);
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => WebLinkViewerPage(
      //             title: widget.titleWebView,
      //             link: FetchService.getLinkMobileLogin(),
      //             linkRedirect: widget.linkWebView)));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // if (Platform.isIOS == true) {
    //   return PDFViewerScaffold(
    //       appBar: AppBar(title: Text(widget.file.fileName), actions: <Widget>[
    //         IconButton(
    //             icon: Icon(Icons.share),
    //             onPressed: () {
    //               if (widget.file.fileName.toLowerCase().endsWith('.pdf') ==
    //                   false) widget.file.fileName += '.pdf';
    //               AppHelpers.shareFile(widget.file);
    //             })
    //       ]),
    //       path: widget.file.localPath);
    // }
    if (widget.linkWebView.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.file.fileName), actions: <Widget>[
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  if (widget.file.fileName.toLowerCase().endsWith('.pdf') ==
                      false) widget.file.fileName += '.pdf';
                  AppHelpers.shareFile(widget.file);
                })
          ]),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Text('thay tạm cho viewer'));
      // : PDFViewer(document: document, showPicker: document.count > 1));
    } else {
      return WillPopScope(
          onWillPop: () => onBackClick(),
          child: Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: new Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => onBackClick(),
                  ),
                  title: Text(widget.file.fileName),
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          if (widget.file.fileName
                                  .toLowerCase()
                                  .endsWith('.pdf') ==
                              false) widget.file.fileName += '.pdf';
                          AppHelpers.shareFile(widget.file);
                        })
                  ]),
              body: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Text('thay tạm cho viewer')));
      // : PDFViewer(document: document, showPicker: document.count > 1)));
    }
  }
}

class PdfViewerPage extends StatefulWidget {
  PdfViewerPage(
      {this.file,
      this.titleWebView = '',
      this.linkWebView = '',
      this.isWebOldVersion = false});

  final FileAttachment file;
  final String titleWebView;
  final String linkWebView;
  final bool isWebOldVersion;

  @override
  State<StatefulWidget> createState() {
    return PdfViewerPageState();
  }
}
