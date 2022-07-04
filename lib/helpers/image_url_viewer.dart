import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:photo_view/photo_view.dart';

class ImageUrlViewerPageState extends State<ImageUrlViewerPage> {
  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.fileName),
            actions: this.isLoading
                ? null
                : <Widget>[
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        setState(() {
                          this.isLoading = true;
                        });
                        FileAttachment file = FileAttachment.empty();
                        file.fileName = widget.fileName;
                        if (widget.bytes == null) {
                          http.readBytes(widget.urlImage).then((bytes) {
                            if (this.mounted) {
                              file.bytes = bytes;
                              AppHelpers.shareFile(file);
                              setState(() {
                                this.isLoading = false;
                              });
                            }
                          });
                        } else {
                          file.bytes = widget.bytes;
                          AppHelpers.shareFile(file);
                          setState(() {
                            this.isLoading = false;
                          });
                        }
                      },
                    )
                  ]),
        body: Container(
            child: PhotoView(
                imageProvider: widget.bytes == null
                    ? NetworkImage(widget.urlImage)
                    : MemoryImage(widget.bytes))));
  }
}

class ImageUrlViewerPage extends StatefulWidget {
  final String fileName;
  final String urlImage;
  final List<int> bytes;

  ImageUrlViewerPage({this.fileName, this.urlImage, this.bytes});

  @override
  State<StatefulWidget> createState() {
    return ImageUrlViewerPageState();
  }
}
