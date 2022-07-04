import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerPageState extends State<ImageViewerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.file.fileName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                AppHelpers.shareFile(widget.file);
              },
            )
          ],
        ),
        body: Container(
            child: PhotoView(
          imageProvider: (widget.file.bytes != null
                  ? Image.memory(widget.file.bytes)
                  : Image.file(File(widget.file.localPath)))
              .image,
        )));
  }
}

class ImageViewerPage extends StatefulWidget {
  final FileAttachment file;

  ImageViewerPage({this.file});

  @override
  State<StatefulWidget> createState() {
    return ImageViewerPageState();
  }
}
