import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class DiscussWorkCreateStep3PageState
    extends State<DiscussWorkCreateStep3Page> {
  bool isSubmitting = false;

  @override
  initState() {
    super.initState();
    if (AppCache.currentDiscussWork.id != null &&
        AppCache.currentDiscussWork.isEdited == 0) {
      this._loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    FetchService.getDiscussWorkById(AppCache.currentDiscussWork.id)
        .then((record) {
      setState(() {
        AppCache.currentDiscussWork = record;
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

  void onNextClick() {
    setState(() {
      this.isSubmitting = true;
    });
    FetchService.discussWorkSave().then((discussWorkId) async {
      String titleAlert = AppCache.currentDiscussWork.id == null
          ? "Tạo trao đổi công việc"
          : "Sửa trao đổi công việc";
      if (discussWorkId.isNotEmpty) {
        List<String> filesOld = <String>[];
        for (int i = 0; i < AppCache.currentDiscussWork.files.length; i++) {
          if (AppCache.currentDiscussWork.files[i].url.isEmpty) {
            await FetchService.fileUpload(
                "TraoDoiCV",
                discussWorkId,
                AppCache.currentDiscussWork.files[i].fileName,
                File(AppCache.currentDiscussWork.files[i].localPath));
          } else {
            filesOld.add(AppCache.currentDiscussWork.files[i].fileName);
          }
        }
        if (filesOld.length > 0 &&
            AppCache.currentDiscussWork.fileDinhKems != null &&
            AppCache.currentDiscussWork.fileDinhKems.length > 0) {
          List<String> filesRemove = <String>[];
          String fileName = '';
          for (int i = 0;
              i < AppCache.currentDiscussWork.fileDinhKems.length;
              i++) {
            fileName =
                AppCache.currentDiscussWork.fileDinhKems[i].split('?')[0];
            if (filesOld.contains(fileName) == false) {
              filesRemove.add(fileName);
            }
          }
          if (filesRemove.length > 0) {
            FetchService.fileDelete("TraoDoiCV", discussWorkId, filesRemove);
          }
        }

        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(titleAlert),
                content: Text("THÀNH CÔNG !!!"),
                actions: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          this.isSubmitting = false;
                        });
                        AppHelpers.navigatorToHome(
                            context, IndexTabHome.DiscussWork);
                        DiscussWorkPage.globalKey.currentState.loadData();
                      },
                      child: Text("OK", style: TextStyle(color: Colors.blue)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(
            context, titleAlert, 'KHÔNG THÀNH CÔNG, vui lòng thử lại !', false);
        setState(() {
          this.isSubmitting = false;
        });
      }
    });
  }

  void goBack() {
    setState(() {
      this.isSubmitting = false;
    });
    AppHelpers.navigatorToHome(context, IndexTabHome.DiscussWork);
    DiscussWorkPage.globalKey.currentState.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            actions: (AppCache.currentDiscussWork.id != null &&
                    AppCache.currentDiscussWork.isEdited == 0)
                ? null
                : [
                    IconButton(
                        icon: Icon(Icons.delete_forever, color: Colors.black),
                        onPressed: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title:
                                      Text(AppCache.currentDiscussWork.title),
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
                                                  AppCache
                                                      .currentDiscussWork.id)
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
            title: new Center(
              child: new Text(
                'TRAO ĐỔI CÔNG VIỆC',
                style: new TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: getSubmitButton(),
        body: ListView(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            children: <Widget>[
              (AppCache.currentDiscussWork.isEdited == 1)
                  ? this._headerWidget
                  : SizedBox(height: 5),
              Text(
                "Tiêu đề:",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              Text(AppCache.currentDiscussWork.title,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
              SizedBox(height: 10.0),
              Text(
                "Nội dung: ",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Container(
                  constraints: BoxConstraints(maxHeight: 400.0),
                  padding: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: SingleChildScrollView(
                      child: HtmlWidget(AppCache.currentDiscussWork.content,
                          webView: true, webViewJs: false))),
              Container(
                  child: new Column(
                children: <Widget>[
                  new Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 10.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Text(
                            "File đính kèm (${AppCache.currentDiscussWork.files.length})",
                            style: new TextStyle(
                                color: Colors.blue,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                  getWidgetAttachment()
                ],
              )),
              // AppCache.currentDiscussWork.nguoiThamGias.isEmpty ? null :
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 50.0),
                  child: Column(
                      children: AppHelpers.getLayoutCorrelativeUsers(
                          AppCache.getUsersByIds(
                              AppCache.currentDiscussWork.nguoiThamGias),
                          "Danh sách tham gia")))
            ]));
  }

  Widget getSubmitButton() {
    if (AppCache.currentDiscussWork.id != null &&
        AppCache.currentDiscussWork.isEdited == 0) {
      return null;
    }
    return this.isSubmitting
        ? CircularProgressIndicator()
        : FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: onNextClick,
            child: Icon(Icons.send, color: Colors.white),
          );
  }

  Widget getWidgetAttachment() {
    List<Widget> widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentDiscussWork.files) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
          child: AppCache.currentDiscussWork.id == null
              ? ListTile(
                  leading: Icon(
                    Icons.attach_file,
                    color: Colors.blue,
                  ),
                  title: Text(
                    item.fileName,
                    style: TextStyle(color: Colors.black),
                  ))
              : ListTile(
                  leading:
                      item.isDownloading ? CircularProgressIndicator() : null,
                  title: Text(
                    item.fileName,
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle:
                      item.progressing.isEmpty ? null : Text(item.progressing),
                  trailing: item.isDownloading
                      ? null
                      : IconButton(
                          icon: Icon(Icons.remove_red_eye, color: Colors.green),
                          onPressed: () {
                            if (item.localPath.isEmpty) {
                              this.downloadFile(
                                  item,
                                  "TraoDoiCV",
                                  AppCache.currentDiscussWork.id +
                                      '/' +
                                      'files');
                            } else {
                              AppHelpers.openFile(item, this.context);
                            }
                          }))));
    }
    return Column(children: widgets);
  }

  Future<void> downloadFile(
      FileAttachment file, String module, String id) async {
    Dio dio = Dio();
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      file.localPath = "${dir.path}/$module/$id";
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

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Phân công"),
    AppHelpers.getHeaderStep(Colors.blue, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));
}

class DiscussWorkCreateStep3Page extends StatefulWidget {
  @override
  DiscussWorkCreateStep3PageState createState() =>
      DiscussWorkCreateStep3PageState();
}
