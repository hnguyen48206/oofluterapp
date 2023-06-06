import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:onlineoffice_flutter/work_project/work_project_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class WorkProjectCreateStep4PageState
    extends State<WorkProjectCreateStep4Page> {
  bool isSubmitting = false;
  Account mainPeople;

  @override
  initState() {
    this.mainPeople =
        AppCache.getUserById(AppCache.currentWorkProject.nguoiChinh);
    super.initState();
  }

  void onNextClick() {
    setState(() {
      this.isSubmitting = true;
    });
    FetchService.workProjectInsertUpdate().then((saveOK) async {
      if (saveOK) {
        List<String> filesOld = <String>[];
        for (int i = 0; i < AppCache.currentWorkProject.files.length; i++) {
          if (AppCache.currentWorkProject.files[i].url.isEmpty) {
            await FetchService.fileUpload(
                "CongViec",
                AppCache.currentWorkProject.id,
                AppCache.currentWorkProject.files[i].fileName,
                File(AppCache.currentWorkProject.files[i].localPath));
          } else {
            filesOld.add(AppCache.currentWorkProject.files[i].fileName);
          }
        }
        if (filesOld.length > 0 &&
            AppCache.currentWorkProject.fileDinhKems != null &&
            AppCache.currentWorkProject.fileDinhKems.length > 0) {
          List<String> filesRemove = <String>[];
          String fileName = '';
          for (int i = 0;
              i < AppCache.currentWorkProject.fileDinhKems.length;
              i++) {
            fileName =
                AppCache.currentWorkProject.fileDinhKems[i].split('?')[0];
            if (filesOld.contains(fileName) == false) {
              filesRemove.add(fileName);
            }
          }
          if (filesRemove.length > 0) {
            FetchService.fileDelete(
                "CongViec", AppCache.currentWorkProject.id, filesRemove);
          }
        }

        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text("Tạo công việc"),
                content: Text("THÀNH CÔNG !!!"),
                actions: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          this.isSubmitting = false;
                        });
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName("/HomePage"));
                        HomePage.globalKey.currentState
                            .setFromDashboard(IndexTabHome.WorkProject);
                        AppCache.tabIndexWorkList = 2;
                        WorkProjectPage.globalKey.currentState.loadData();
                      },
                      child: Text("OK", style: TextStyle(color: Colors.white)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(context, 'Tạo công việc',
            'KHÔNG THÀNH CÔNG, vui lòng thử lại !', false);
        setState(() {
          this.isSubmitting = false;
        });
      }
    });
  }

  Widget getSubmitButton() {
    if (AppCache.currentWorkProject.id != null &&
        AppCache.currentWorkProject.isEdited == 0) {
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

  // void onBack() {
  //   Navigator.of(context).popUntil(ModalRoute.withName("/HomePage"));
  //   HomePage.globalKey.currentState.setFromDashboard(IndexTabHome.WorkProject);
  //   AppCache.tabIndexWorkList = 2;
  //   WorkProjectPage.globalKey.currentState.loadData();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            title: new Center(
              child: new Text(
                AppCache.currentWorkProject.isEdited == 0
                    ? 'Chi tiết công việc'
                    : (AppCache.currentWorkProject.id == null
                        ? 'Tạo công việc'
                        : 'Chỉnh sửa công việc'),
                style: new TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: getSubmitButton(),
        body: ListView(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            children: <Widget>[
              AppCache.currentWorkProject.isEdited == 0
                  ? SizedBox(height: 1.0)
                  : this._headerWidget,
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Ngày bắt đầu:",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                    new Text(AppCache.currentWorkProject.ngayBatDau,
                        style: TextStyle(color: Colors.black, fontSize: 16.0))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // new Icon(Icons.access_time, color: Colors.blue),
                    new Text(
                      "Ngày hoàn thành:",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                    new Text(AppCache.currentWorkProject.ngayKetThuc,
                        style: TextStyle(color: Colors.black, fontSize: 16.0))
                  ],
                ),
              ),
              Text(
                "Tên công việc: ",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              Text(
                AppCache.currentWorkProject.title,
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              SizedBox(height: 10.0),
              Text(
                "Dự án: ",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              Text(
                AppCache.currentWorkProject.msda.isEmpty
                    ? 'Không có'
                    : AppCache.getCategoryNameById(
                        AppCache.allProject, AppCache.currentWorkProject.msda),
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
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
                      child: HtmlWidget(AppCache.currentWorkProject.content,
                         ))),
              AppCache.currentWorkProject.files.length == 0
                  ? SizedBox(height: 0.0)
                  : Container(
                      child: new Column(
                      children: <Widget>[
                        new Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0, 10.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                new Text(
                                  "File đính kèm (${AppCache.currentWorkProject.files.length})",
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
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 20.0),
                  child: Column(
                      children: AppHelpers.getLayoutCorrelativeUsers(
                          AppCache.getUsersByIds(
                              AppCache.currentWorkProject.nguoiXuLys),
                          "Danh sách người xử lý"))),
              Text(
                "Người chịu trách nhiệm chính: ",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]),
                ),
                child: new ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(this.mainPeople.avatar),
                  ),
                  title: new Text(
                    this.mainPeople.fullName,
                    style: new TextStyle(color: Colors.black),
                  ),
                ),
              ),
              AppCache.currentWorkProject.nguoiDuocXems.length == 0
                  ? SizedBox(height: 0.0)
                  : Container(
                      padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 50.0),
                      child: Column(
                          children: AppHelpers.getLayoutCorrelativeUsers(
                              AppCache.getUsersByIds(
                                  AppCache.currentWorkProject.nguoiDuocXems),
                              "Danh sách người được xem")))
            ]));
  }

  Widget getWidgetAttachment() {
    List<Widget> widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentWorkProject.files) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
          child: ListTile(
              leading: item.isDownloading
                  ? CircularProgressIndicator()
                  : Icon(Icons.attach_file),
              title: Text(
                item.fileName,
                style: new TextStyle(color: Colors.black),
              ),
              subtitle:
                  item.progressing.isEmpty ? null : Text(item.progressing),
              trailing: item.isDownloading
                  ? null
                  : IconButton(
                      icon: Icon(
                          item.localPath.isEmpty
                              ? Icons.file_download
                              : Icons.remove_red_eye,
                          color: Colors.green),
                      onPressed: () {
                        if (item.localPath.isEmpty) {
                          this.downloadFile(item, 'CongViec',
                              AppCache.currentWorkProject.id + '/' + 'files');
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
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.white, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Người xử lý"),
    AppHelpers.getHeaderStep(Colors.white, "Người xem"),
    AppHelpers.getHeaderStep(Colors.blue, "Hoàn tất")
  ]));
}

class WorkProjectCreateStep4Page extends StatefulWidget {
  @override
  WorkProjectCreateStep4PageState createState() =>
      WorkProjectCreateStep4PageState();
}
