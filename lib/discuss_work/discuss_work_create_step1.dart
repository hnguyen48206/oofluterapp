import 'dart:core';
import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    hide ImageSource;
import 'package:image_picker/image_picker.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_create_step2.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class DiscussWorkCreateStep1State extends State<DiscussWorkCreateStep1Page> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _tieuDeController, _noiDungController;
  ImagePicker _imagePicker = ImagePicker();

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Phân công"),
    AppHelpers.getHeaderStep(Colors.white, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    final form = formKey.currentState;
    if (form.validate() == true) {
      form.save();
      AppCache.currentDiscussWork.title = this._tieuDeController.text.trim();
      AppCache.currentDiscussWork.content = this._noiDungController.text.trim();
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => DiscussWorkCreateStep2Page()));
    }
  }

  @override
  initState() {
    this._tieuDeController = TextEditingController();
    this._noiDungController = TextEditingController();

    super.initState();
    if (AppCache.currentDiscussWork.id != null) {
      this._loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    FetchService.getDiscussWorkById(AppCache.currentDiscussWork.id)
        .then((record) {
      setState(() {
        AppCache.currentDiscussWork = record;
        this._tieuDeController.text = record.title;
        this._noiDungController.text = ObjectHelper.removeHTML(record.content);
        AppCache.currentDiscussWork.users =
            AppCache.getUsersByIds(record.nguoiThamGias);
        if (AppCache.currentDiscussWork.fileDinhKems != null &&
            AppCache.currentDiscussWork.fileDinhKems.length > 0) {
          AppCache.currentDiscussWork.files = AppCache
              .currentDiscussWork.fileDinhKems
              .map((p) => FileAttachment(p))
              .toList();
        }
      });
    });
  }

  void goBack() {
    AppHelpers.navigatorToHome(context, IndexTabHome.DiscussWork);
    DiscussWorkPage.globalKey.currentState.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            actions: [
              IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.black),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text(AppCache.currentDiscussWork.title),
                            content: Text("Bạn có chắc chắn muốn xoá ?"),
                            actions: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Không")),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    FetchService.deleteDiscussWork(
                                            AppCache.currentDiscussWork.id)
                                        .then((bool value) {
                                      if (value) {
                                        goBack();
                                      } else {
                                        AppHelpers.alertDialogClose(
                                            context,
                                            "Xoá trao đổi công việc",
                                            'KHÔNG THÀNH CÔNG, vui lòng thử lại !',
                                            false);
                                      }
                                    });
                                  },
                                  child: Text("Có"))
                            ],
                          );
                        });
                  })
            ],
            title: Text(
              'TRAO ĐỔI CÔNG VIỆC',
              style: new TextStyle(fontSize: 18.0, color: Colors.white),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: Form(
            key: this.formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              children: <Widget>[
                this._headerWidget,
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: new Text(
                    "Tiêu đề: ",
                    style: new TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                    autocorrect: true,
                    // maxLines: 2,
                    controller: this._tieuDeController,
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blue))),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập tiêu đề';
                      }
                      return null;
                    },
                    onSaved: (val) => this._tieuDeController.text = val),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: new Text(
                    "Nội dung: ",
                    style: new TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                AppCache.currentDiscussWork.content.contains('</')
                    ? Container(
                        constraints: BoxConstraints(maxHeight: 400.0),
                        padding: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: SingleChildScrollView(
                            child: HtmlWidget(
                                AppCache.currentDiscussWork.content,
                                webView: true,
                                webViewJs: false)))
                    : TextFormField(
                        autocorrect: true,
                        maxLines: 6,
                        controller: this._noiDungController,
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            contentPadding: new EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.blue))),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          return null;
                        },
                        onSaved: (val) => this._noiDungController.text = val),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          "File đính kèm (${AppCache.currentDiscussWork.files.length})",
                          style: new TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            onPressed: () {
                              attachFileOptions();
                            },
                            icon: Icon(Icons.add_circle,
                                size: 30.0, color: Colors.green))
                      ],
                    )),
                getWidgetAttachment(),
                SizedBox(height: 80.0)
              ],
            )));
  }

  attachFileOptions() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text("Upload hình ảnh, video, files",
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
                    attachImageVideo(false, ImageSource.gallery);
                  },
                  child: Text("Chọn ảnh từ Gallery")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageVideo(true, ImageSource.gallery);
                  },
                  child: Text("Chọn video từ Gallery")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageVideo(false, ImageSource.camera);
                  },
                  child: Text("Chụp ảnh từ Camera")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageVideo(true, ImageSource.camera);
                  },
                  child: Text("Quay video từ Camera")),
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

  attachImageVideo(bool isVideo, ImageSource fromSource) async {
    PickedFile pickedFile;
    if (isVideo) {
      pickedFile = await this._imagePicker.getVideo(source: fromSource);
    } else {
      pickedFile = await this._imagePicker.getImage(source: fromSource);
    }
    if (pickedFile == null) return;
    setState(() {
      FileAttachment file = FileAttachment.empty();
      file.fileName = pickedFile.path.split("/").last;
      file.mimeType = '';
      file.url = '';
      file.localPath = pickedFile.path;
      file.isDownloading = false;
      file.extension = file.fileName.split(".").last;
      file.progressing = '';
      AppCache.currentDiscussWork.files.add(file);
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
            AppCache.currentDiscussWork.files.add(file);
          }
        });
      } else {
        return;
      }
    });
  }

  Widget getWidgetAttachment() {
    List<Widget> widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentDiscussWork.files) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
          child: new ListTile(
              leading: item.isDownloading ? CircularProgressIndicator() : null,
              title: new Text(
                item.fileName,
                style: new TextStyle(color: Colors.black),
              ),
              subtitle:
                  item.progressing.isEmpty ? null : Text(item.progressing),
              trailing: item.isDownloading
                  ? null
                  : IconButton(
                      icon: Icon(Icons.send, color: Colors.green),
                      onPressed: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return CupertinoActionSheet(
                                title: Text(item.fileName,
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
                                        if (item.localPath.isEmpty) {
                                          this
                                              .downloadFile(
                                                  item,
                                                  "TraoDoiCV",
                                                  AppCache
                                                      .currentDiscussWork.id)
                                              .then((val) {
                                            if (val == true) {
                                              AppHelpers.openFile(
                                                  item, this.context);
                                            }
                                          });
                                        } else {
                                          AppHelpers.openFile(
                                              item, this.context);
                                        }
                                      },
                                      child: Text("Xem")),
                                  CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (context) {
                                              return CupertinoAlertDialog(
                                                title: Text(item.fileName),
                                                content: Text(
                                                    "Bạn có chắc chắn muốn xoá file này ?"),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("Không")),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          AppCache
                                                              .currentDiscussWork
                                                              .files
                                                              .remove(item);
                                                        });
                                                      },
                                                      child: Text("Có"))
                                                ],
                                              );
                                            });
                                      },
                                      child: Text("Xoá",
                                          style: TextStyle(color: Colors.red)))
                                ],
                              );
                            });
                      }))));
    }
    return Column(children: widgets);
  }

  Future<bool> downloadFile(
      FileAttachment file, String module, String id) async {
    Dio dio = Dio();
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      file.localPath = "${dir.path}/$module/$id";
      await AppHelpers.createFolder(file.localPath);
      file.localPath += "/${file.fileName}";
      await dio.download(file.url, file.localPath,
          onReceiveProgress: (rec, total) {
        setState(() {
          file.isDownloading = true;
          String mbRec = (rec / 1048576).toStringAsFixed(1);
          String mbTotal = (total / 1048576).toStringAsFixed(1);
          file.progressing =
              "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
        });
      });
      file.isDownloading = false;
      file.progressing = '';
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

class DiscussWorkCreateStep1Page extends StatefulWidget {
  @override
  DiscussWorkCreateStep1State createState() => DiscussWorkCreateStep1State();
}
