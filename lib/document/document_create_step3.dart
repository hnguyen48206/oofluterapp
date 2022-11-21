import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlineoffice_flutter/document/document_create_step4.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class DocumentCreateStep3PageState extends State<DocumentCreateStep3Page> {
  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.white, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Thời gian"),
    AppHelpers.getHeaderStep(Colors.blue, "File VB"),
    AppHelpers.getHeaderStep(Colors.white, "Người xem"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => DocumentCreateStep4Page()));
  }

  attachImageSource(ImageSource imageSource) async {
    ImagePicker().getImage(source: imageSource).then((item) async {
      if (item == null) return;
      setState(() {
        FileAttachment file = FileAttachment.empty();
        file.fileName = item.path.split("/").last;
        file.mimeType = '';
        file.url = '';
        file.localPath = item.path;
        file.isDownloading = false;
        file.extension = file.fileName.split(".").last;
        file.progressing = '';
        AppCache.currentDocument.files.add(file);
      });
    });
  }

  attachFiles() async {
    FilePicker.platform.pickFiles(allowMultiple: true).then((result) {
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path)).toList();
        setState(() {
          for (var item in files) {
            FileAttachment file = FileAttachment.empty();
            file.fileName = item.path.split("/").last;
            file.mimeType = '';
            file.url = '';
            file.localPath = item.path;
            file.isDownloading = false;
            file.extension = file.fileName.split(".").last;
            file.progressing = '';
            AppCache.currentDocument.files.add(file);
          }
        });
      } else {
        return;
      }
    });
  }

  attachFileOptions() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text("Upload hình ảnh, files",
                style: TextStyle(color: Colors.black)),
            message: Text("Chọn hành động"),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Đóng")),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageSource(ImageSource.gallery);
                  },
                  child: Text("Chọn từ thư viện ảnh")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageSource(ImageSource.camera);
                  },
                  child: Text("Chụp ảnh từ camera")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachFiles();
                  },
                  child: Text("Chọn từ trình quản lý files",
                      style: TextStyle(color: Colors.red)))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            actions: [
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    AppHelpers.navigatorToHome(context, IndexTabHome.Document);
                  })
            ],
            title: new Center(
              child: new Text(
                'TẠO VĂN BẢN ĐẾN',
                style: new TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: new ListView(
            padding: new EdgeInsets.fromLTRB(10, 0, 10, 0),
            children: getWidgetsLayout()));
  }

  Widget getWidgetTitle() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Danh sách file văn bản (${AppCache.currentDocument.files.length})",
                style: new TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    attachFileOptions();
                  },
                  icon: Icon(Icons.add_circle, size: 30.0, color: Colors.green))
            ]));
  }

  List<Widget> getWidgetsLayout() {
    List<Widget> result = [];
    result.add(this._headerWidget);
    result.add(getWidgetTitle());
    if (AppCache.currentDocument.files.length > 0) result.add(getLayoutFiles());
    return result;
  }

  Widget getLayoutFiles() {
    return Expanded(
        child: ListView.separated(
            itemCount: AppCache.currentDocument.files.length,
            separatorBuilder: (BuildContext context, int index) =>
                Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              FileAttachment item = AppCache.currentDocument.files[index];
              return Container(
                  margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: ListTile(
                      leading: item.isDownloading
                          ? CircularProgressIndicator()
                          : null,
                      title: Text(
                        item.fileName,
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: item.progressing.isEmpty
                          ? null
                          : Text(item.progressing),
                      trailing: item.isDownloading
                          ? null
                          : IconButton(
                              icon: Icon(Icons.remove_red_eye,
                                  color: Colors.green),
                              onPressed: () {
                                if (item.localPath.isEmpty) {
                                  this.downloadFile(item, "VanBan",
                                      AppCache.currentDocument.id);
                                } else {
                                  AppHelpers.openFile(item, this.context);
                                }
                              })));
            }));
  }

  Future<void> downloadFile(
      FileAttachment file, String module, String id) async {
    Dio dio = Dio();
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      file.localPath = "${dir.path}/$module";
      await AppHelpers.createFolder(file.localPath);
      file.localPath += "/$id";
      await AppHelpers.createFolder(file.localPath);
      file.localPath += "/${file.fileName}";
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
        AppHelpers.openFile(file, this.context);
      });
    } catch (e) {
      print(e);
    }
  }
}

class DocumentCreateStep3Page extends StatefulWidget {
  @override
  DocumentCreateStep3PageState createState() => DocumentCreateStep3PageState();
}
