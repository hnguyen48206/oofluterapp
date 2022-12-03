import 'dart:core';
import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    hide ImageSource;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/report_daily/report_daily_list.dart';
import 'package:onlineoffice_flutter/models/report_daily_model.dart';

class ReportDailyCreateStep1State extends State<ReportDailyCreatePage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _tieuDeController, _noiDungController;
  bool isSubmitting = false;

  void onNextClick() {
    final form = formKey.currentState;
    if (form.validate() == true) {
      form.save();
      AppCache.currentReportDaily.title = this._tieuDeController.text.trim();
      AppCache.currentReportDaily.content = this._noiDungController.text.trim();

      setState(() {
        this.isSubmitting = true;
      });
      FetchService.reportDailySave().then((recordId) async {
        if (recordId.isNotEmpty) {
          List<String> filesOld = <String>[];
          for (int i = 0; i < AppCache.currentReportDaily.files.length; i++) {
            if (AppCache.currentReportDaily.files[i].url.isEmpty) {
              await FetchService.fileUpload(
                  "BaoCao",
                  recordId,
                  AppCache.currentReportDaily.files[i].fileName,
                  File(AppCache.currentReportDaily.files[i].localPath));
            } else {
              filesOld.add(AppCache.currentReportDaily.files[i].fileName);
            }
          }
          if (filesOld.length > 0 &&
              AppCache.currentReportDaily.fileDinhKems != null &&
              AppCache.currentReportDaily.fileDinhKems.length > 0) {
            var filesRemove = <String>[];
            String fileName = '';
            for (int i = 0;
                i < AppCache.currentReportDaily.fileDinhKems.length;
                i++) {
              fileName =
                  AppCache.currentReportDaily.fileDinhKems[i].split('?')[0];
              if (filesOld.contains(fileName) == false) {
                filesRemove.add(fileName);
              }
            }
            if (filesRemove.length > 0) {
              FetchService.fileDelete("BaoCao", recordId, filesRemove);
            }
          }

          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text(AppCache.currentReportDaily.getTitleAction()),
                  content: Text("THÀNH CÔNG !!!"),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AppCache.currentReportDaily =
                              ReportDaily(null, '', '');
                          // Navigator.of(context).pop();
                          Navigator.pushReplacement(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => ReportDailyPage()));
                        },
                        child: Text("OK", style: TextStyle(color: Colors.white)))
                  ],
                );
              });
        } else {
          AppHelpers.alertDialogClose(
              context,
              AppCache.currentReportDaily.getTitleAction(),
              'KHÔNG THÀNH CÔNG, vui lòng thử lại !',
              false);
          setState(() {
            this.isSubmitting = false;
          });
        }
      });
    }
  }

  Widget getSubmitButton() {
    return this.isSubmitting
        ? CircularProgressIndicator()
        : FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: onNextClick,
            child: Icon(Icons.send, color: Colors.white),
          );
  }

  @override
  initState() {
    this._tieuDeController =
        TextEditingController(text: AppCache.currentReportDaily.title);
    this._noiDungController =
        TextEditingController(text: AppCache.currentReportDaily.content);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            title: Text(
              AppCache.currentReportDaily.getTitleAction(),
              style: new TextStyle(fontSize: 18.0, color: Colors.white),
            )),
        floatingActionButton: getSubmitButton(),
        body: Form(
            key: this.formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: new Text(
                    AppCache.getGroupReportName(
                        AppCache.currentReportDaily.parentId,
                        AppCache.currentReportDaily.childrenId),
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
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
                    maxLines: 2,
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
                AppCache.currentReportDaily.content.contains('</')
                    ? Container(
                        constraints: BoxConstraints(maxHeight: 400.0),
                        padding: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: SingleChildScrollView(
                            child: HtmlWidget(
                                AppCache.currentReportDaily.content,
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
                          "File đính kèm (${AppCache.currentReportDaily.files.length})",
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
        AppCache.currentReportDaily.files.add(file);
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
            AppCache.currentReportDaily.files.add(file);
          }
        });
      } else {
        return;
      }
    });
  }

  Widget getWidgetAttachment() {
    List<Widget> widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentReportDaily.files) {
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
                                                  "ThongBao",
                                                  AppCache
                                                      .currentReportDaily.id)
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
                                                      child: Text("Không", style: TextStyle(color: Colors.white, fontSize: 14.0))),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          AppCache
                                                              .currentReportDaily
                                                              .files
                                                              .remove(item);
                                                        });
                                                      },
                                                      child: Text("Có", style: TextStyle(color: Colors.white, fontSize: 14.0)))
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

class ReportDailyCreatePage extends StatefulWidget {
  @override
  ReportDailyCreateStep1State createState() => ReportDailyCreateStep1State();
}
