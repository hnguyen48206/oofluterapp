import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/announcement/announcement_list.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class AnnouncementCreateStep3PageState
    extends State<AnnouncementCreateStep3Page> {
  bool isSubmitting = false;

  @override
  initState() {
    super.initState();
  }

  void onNextClick() {
    setState(() {
      this.isSubmitting = true;
    });
    FetchService.announcementSave().then((recordId) async {
      if (recordId.isNotEmpty) {
        List<String> filesOld = <String>[];
        for (int i = 0; i < AppCache.currentAnnouncement.files.length; i++) {
          if (AppCache.currentAnnouncement.files[i].url.isEmpty) {
            await FetchService.fileUpload(
                "ThongBao",
                recordId,
                AppCache.currentAnnouncement.files[i].fileName,
                File(AppCache.currentAnnouncement.files[i].localPath));
          } else {
            filesOld.add(AppCache.currentAnnouncement.files[i].fileName);
          }
        }
        if (filesOld.length > 0 &&
            AppCache.currentAnnouncement.fileDinhKems != null &&
            AppCache.currentAnnouncement.fileDinhKems.length > 0) {
          var filesRemove = <String>[];
          String fileName = '';
          for (int i = 0;
              i < AppCache.currentAnnouncement.fileDinhKems.length;
              i++) {
            fileName =
                AppCache.currentAnnouncement.fileDinhKems[i].split('?')[0];
            if (filesOld.contains(fileName) == false) {
              filesRemove.add(fileName);
            }
          }
          if (filesRemove.length > 0) {
            FetchService.fileDelete("ThongBao", recordId, filesRemove);
          }
        }

        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(AppCache.currentAnnouncement.getTitleAction()),
                content: Text("THÀNH CÔNG !!!"),
                actions: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            this.context,
                            MaterialPageRoute(
                                builder: (context) => AnnouncementPage()));
                      },
                      child: Text("OK", style: TextStyle(color: Colors.blue)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(
            context,
            AppCache.currentAnnouncement.getTitleAction(),
            'KHÔNG THÀNH CÔNG, vui lòng thử lại !',
            false);
        setState(() {
          this.isSubmitting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            actions: [
              IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => AppHelpers.announcementCancelAction(context))
            ],
            title: new Center(
              child: new Text(
                AppCache.currentAnnouncement.getTitleAction(),
                style: new TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: getSubmitButton(),
        body: ListView(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            children: <Widget>[
              this._headerWidget,
              SizedBox(height: 10.0),
              Text(
                "Tiêu đề",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              Text(AppCache.currentAnnouncement.title,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
              SizedBox(height: 10.0),
              Text(
                "Nội dung",
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
                      child: HtmlWidget(AppCache.currentAnnouncement.content,
                          webView: true, webViewJs: false))),
              Container(
                  child: new Column(
                children: <Widget>[
                  new Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Text(
                            "File đính kèm (${AppCache.currentAnnouncement.files.length})",
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
              SizedBox(height: 10.0),
              AppCache.currentAnnouncement.isCheckAll()
                  ? Text(
                      "Tất cả được xem",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    )
                  : Container(
                      padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                      child: Column(
                          children: AppHelpers.getLayoutCorrelativeUsers(
                              AppCache.getUsersByIds(
                                  AppCache.currentAnnouncement.nguoiDuocXems),
                              "Danh sách được xem")))
            ]));
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

  Widget getWidgetAttachment() {
    var widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentAnnouncement.files) {
      widgets.add(Container(
        margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: new ListTile(
            leading: Icon(
              Icons.attach_file,
              color: Colors.blue,
            ),
            title: new Text(
              item.fileName,
              style: new TextStyle(color: Colors.black),
            )),
      ));
    }
    return Column(children: widgets);
  }

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Được xem"),
    AppHelpers.getHeaderStep(Colors.blue, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));
}

class AnnouncementCreateStep3Page extends StatefulWidget {
  @override
  AnnouncementCreateStep3PageState createState() =>
      AnnouncementCreateStep3PageState();
}
