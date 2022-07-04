import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/models/calendar_week_model.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/calendar/calendar_list.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';

class CalendarCreateStep4PageState extends State<CalendarCreateStep4Page> {
  bool _isSubmitting = false;
  String _titleSave = '';

  @override
  void initState() {
    this._titleSave = AppCache.currentCalendar.lichTuanId.isEmpty
        ? 'Đăng ký lịch tuần'
        : 'Chỉnh sửa lịch tuần';
    super.initState();
  }

  void onNextClick() {
    setState(() {
      this._isSubmitting = true;
    });
    FetchService.calendarWeekInsertUpdate().then((saveOK) async {
      if (saveOK) {
        var filesOld = <String>[];
        for (int i = 0; i < AppCache.currentCalendar.files.length; i++) {
          if (AppCache.currentCalendar.files[i].url.isEmpty) {
            await FetchService.fileUpload(
                "LichTuan",
                AppCache.currentCalendar.lichTuanId,
                AppCache.currentCalendar.files[i].fileName,
                File(AppCache.currentCalendar.files[i].localPath));
          } else {
            filesOld.add(AppCache.currentCalendar.files[i].fileName);
          }
        }
        if (filesOld.length > 0 &&
            AppCache.currentCalendar.fileDinhKems != null &&
            AppCache.currentCalendar.fileDinhKems.length > 0) {
          var filesRemove = <String>[];
          String fileName = '';
          for (int i = 0;
              i < AppCache.currentCalendar.fileDinhKems.length;
              i++) {
            fileName = AppCache.currentCalendar.fileDinhKems[i].split('?')[0];
            if (filesOld.contains(fileName) == false) {
              filesRemove.add(fileName);
            }
          }
          if (filesRemove.length > 0) {
            FetchService.fileDelete(
                "LichTuan", AppCache.currentCalendar.lichTuanId, filesRemove);
          }
        }
        AppCache.currentCalendar = LichTuan();

        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(this._titleSave),
                content: Text("THÀNH CÔNG !!!"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        AppHelpers.navigatorToHome(
                            context, IndexTabHome.CalendarWeek);
                        CalendarPage.globalKey.currentState.loadData();
                      },
                      child: Text("OK", style: TextStyle(color: Colors.blue)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(context, this._titleSave,
            'Lưu KHÔNG THÀNH CÔNG, vui lòng thử lại !', false);
        setState(() {
          this._isSubmitting = false;
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
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName("/HomePage"));
                  })
            ],
            title: Center(
              child: Text(
                this._titleSave,
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: this._isSubmitting
            ? CircularProgressIndicator()
            : FloatingActionButton(
                backgroundColor: Colors.teal,
                onPressed: onNextClick,
                child: Icon(Icons.send, color: Colors.white),
              ),
        body: ListView(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            children: <Widget>[
              this._headerWidget,
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Bắt đầu:",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                    Text(AppCache.currentCalendar.thoigianbatdau,
                        style: TextStyle(color: Colors.black, fontSize: 16.0))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Icon(Icons.access_time, color: Colors.blue),
                    Text(
                      "Kết thúc:",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                    Text(AppCache.currentCalendar.thoigianketthuc,
                        style: TextStyle(color: Colors.black, fontSize: 16.0))
                  ],
                ),
              ),
              Text(
                "Nội dung: ",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              Text(
                AppCache.currentCalendar.noidung,
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              AppCache.currentCalendar.files.length == 0
                  ? SizedBox.shrink()
                  : Container(
                      child: Column(
                      children: <Widget>[
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0, 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "File đính kèm (${AppCache.currentCalendar.files.length})",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )),
                        getWidgetAttachment()
                      ],
                    )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Chủ trì:",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                    Text(
                      AppCache.currentCalendar.chutri,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Thành phần: ",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                    Text(AppCache.currentCalendar.thanhphan,
                        style: TextStyle(color: Colors.black, fontSize: 16.0))
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Chuẩn bị: ",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                    Text(AppCache.currentCalendar.chuanbi,
                        style: TextStyle(color: Colors.black, fontSize: 16.0))
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
                child: Text("Địa điểm: ",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ),
              Text(
                AppCache.currentCalendar.diadiem,
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
                child: Text("Khách mời: ",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
              ),
              Text(
                AppCache.currentCalendar.khachmoi,
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              SizedBox(height: 10.0),
              AppCache.currentCalendar.ghichu.isEmpty
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
                      child: Text("Ghi chú: ",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0)),
                    ),
              AppCache.currentCalendar.ghichu.isEmpty
                  ? SizedBox.shrink()
                  : Text(
                      AppCache.currentCalendar.ghichu,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 50.0),
                  child: Column(
                      children: AppHelpers.getLayoutCorrelativeUsers(
                          AppCache.getUsersByIds(
                              AppCache.currentCalendar.nguoiThamGias),
                          "Danh sách tham gia")))
            ]));
  }

  Widget getWidgetAttachment() {
    List<Widget> widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentCalendar.files) {
      widgets.add(Container(
        margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: ListTile(
            leading: Icon(
              Icons.attach_file,
              color: Colors.blue,
            ),
            title: Text(
              item.fileName,
              style: TextStyle(color: Colors.black),
            )),
      ));
    }
    return Column(children: widgets);
  }

  Widget _headerWidget = Container(
      child: Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Thành phần"),
    AppHelpers.getHeaderStep(Colors.blue, "Phân công"),
    AppHelpers.getHeaderStep(Colors.blue, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));
}

class CalendarCreateStep4Page extends StatefulWidget {
  @override
  CalendarCreateStep4PageState createState() => CalendarCreateStep4PageState();
}
