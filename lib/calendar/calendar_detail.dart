import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/models/calendar_week_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/calendar/calendar_create_step1.dart';
import 'package:onlineoffice_flutter/calendar/calendar_list.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class CalendarDetailPageState extends State<CalendarDetailPage> {
  LichTuan lichTuan;
  var _users = <Account>[];
  List<FileAttachment> _files = <FileAttachment>[];
  List<Widget> _buttons = <Widget>[];

  @override
  void initState() {
    super.initState();
    _loadLichTuanChiTiet();
  }

  Future<void> _loadLichTuanChiTiet() async {
    FetchService.getLichTuanChiTiet(widget.lichTuanId).then((lichTuan) {
      setState(() {
        this.lichTuan = lichTuan;
        this._users = AppCache.getUsersByIds(lichTuan.nguoiThamGias);
        if (this.lichTuan.fileDinhKems != null &&
            this.lichTuan.fileDinhKems.length > 0) {
          this._files =
              this.lichTuan.fileDinhKems.map((p) => FileAttachment(p)).toList();
        }
        if (this.lichTuan.buttons != null && this.lichTuan.buttons.length > 0) {
          _setButtonsAction();
        }
      });
    });
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

  void _setButtonsAction() {
    this._buttons.clear();
    for (var button in lichTuan.buttons) {
      switch (button) {
        case "cancel":
          this._buttons.add(RaisedButton.icon(
              label: Text("Huỷ",
                  style: TextStyle(color: Colors.white, fontSize: 14.0)),
              color: Colors.redAccent,
              elevation: 0.0,
              icon: Icon(Icons.cancel, color: Colors.black),
              onPressed: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text(this.lichTuan.noidung),
                        content:
                            Text('Bạn có chắc chắn muốn huỷ lịch tuần này ?'),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Không",
                                  style: TextStyle(color: Colors.black))),
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _cancel();
                              },
                              child: Text("Huỷ",
                                  style: TextStyle(color: Colors.black)))
                        ],
                      );
                    });
              }));
          break;
        case "approve":
          this._buttons.add(RaisedButton.icon(
              label: Text("Phê duyệt",
                  style: TextStyle(color: Colors.white, fontSize: 14.0)),
              color: Colors.blueAccent,
              elevation: 0.0,
              icon: Icon(Icons.send, color: Colors.black),
              onPressed: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text(this.lichTuan.noidung),
                        content:
                            Text('Bạn có chắc chắn muốn duyệt lịch tuần này ?'),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Không",
                                  style: TextStyle(color: Colors.black))),
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _approve();
                              },
                              child: Text("Duyệt",
                                  style: TextStyle(color: Colors.black)))
                        ],
                      );
                    });
              }));
          break;
        case "edit":
          this._buttons.add(RaisedButton.icon(
              color: Colors.green,
              elevation: 0.0,
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                AppCache.currentCalendar = this.lichTuan;
                Navigator.push(
                    this.context,
                    MaterialPageRoute(
                        builder: (context) => CalendarCreateStep1Page()));
              },
              label: Text("Chỉnh sửa",
                  style: TextStyle(color: Colors.white, fontSize: 14.0))));
          break;
        default:
      }
    }
  }

  void _delete() async {
    FetchService.deleteCalendar(this.lichTuan.lichTuanId, this.lichTuan.noidung)
        .then((result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text(this.lichTuan.noidung),
                  content: Text('Xóa lịch tuần THÀNH CÔNG !!!'),
                  actions: <Widget>[this._btnSuccess()]);
            });
      } else {
        AppHelpers.alertDialogClose(context, this.lichTuan.noidung,
            'Xóa lịch tuần KHÔNG THÀNH CÔNG.', false);
      }
    });
  }

  Widget _btnSuccess() {
    return FlatButton(
        onPressed: () {
          AppHelpers.navigatorToHome(context, IndexTabHome.CalendarWeek);
          CalendarPage.globalKey.currentState.loadData();
        },
        child: Text("OK", style: TextStyle(color: Colors.blue)));
  }

  void _cancel() async {
    FetchService.cancelCalendar(this.lichTuan.lichTuanId, this.lichTuan.noidung)
        .then((result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text(this.lichTuan.noidung),
                  content: Text('Huỷ lịch tuần THÀNH CÔNG !!!'),
                  actions: <Widget>[this._btnSuccess()]);
            });
      } else {
        AppHelpers.alertDialogClose(context, this.lichTuan.noidung,
            'Huỷ lịch tuần KHÔNG THÀNH CÔNG.', false);
      }
    });
  }

  void _approve() async {
    FetchService.approveCalendar(this.lichTuan.lichTuanId).then((result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text(this.lichTuan.noidung),
                  content: Text('Duyệt lịch tuần THÀNH CÔNG !!!'),
                  actions: <Widget>[this._btnSuccess()]);
            });
      } else {
        AppHelpers.alertDialogClose(context, this.lichTuan.noidung,
            'Duyệt lịch tuần KHÔNG THÀNH CÔNG.', false);
      }
    });
  }

  Widget getWidgetAttachment() {
    var widgets = <Widget>[];
    widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              "File đính kèm (${this._files.length})",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        )));
    for (FileAttachment item in this._files) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
          child: ListTile(
              leading: item.isDownloading ? CircularProgressIndicator() : null,
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
                              item, "LichTuan", this.lichTuan.lichTuanId);
                        } else {
                          AppHelpers.openFile(item, this.context);
                        }
                      }))));
    }
    return Container(child: Column(children: widgets));
  }

  getWidgetDelete() {
    var result = <Widget>[];
    result.add(IconButton(
        icon: Icon(Icons.delete, color: Colors.red, size: 35.0),
        onPressed: () {
          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text(this.lichTuan.noidung),
                  content: Text('Bạn có chắc chắn muốn XÓA lịch tuần này ?'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Không",
                            style: TextStyle(color: Colors.black))),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _delete();
                        },
                        child:
                            Text("Xóa", style: TextStyle(color: Colors.black)))
                  ],
                );
              });
        }));
    return result;
  }

  getWidgetLayout() {
    List<Widget> widgets = <Widget>[];
    widgets.add(ListTile(
        title: Text(this.lichTuan.noidung,
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold))));
    widgets.add(ListTile(
        leading: Icon(Icons.accessibility, color: Colors.blue),
        title:
            Text(this.lichTuan.chutri, style: TextStyle(color: Colors.red))));
    widgets.add(ListTile(
        leading: Icon(Icons.people, color: Colors.blue),
        title: Text(this.lichTuan.thanhphan)));
    if (this.lichTuan.khachmoi != null && this.lichTuan.khachmoi.isNotEmpty) {
      widgets.add(ListTile(
          leading: Icon(Icons.people, color: Colors.blue),
          title: Text('Khách mời: ' + this.lichTuan.khachmoi)));
    }
    widgets.add(ListTile(
        leading: Icon(Icons.location_on, color: Colors.blue),
        title: Text(this.lichTuan.diadiem)));
    widgets.add(ListTile(
        leading: Icon(Icons.access_time, color: Colors.blue),
        title: Text(this.lichTuan.thoigian,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.green,
                fontWeight: FontWeight.bold))));
    if (this.lichTuan.ghichu != null && this.lichTuan.ghichu.isNotEmpty) {
      widgets
          .add(SingleChildScrollView(child: HtmlWidget(this.lichTuan.ghichu)));
    }
    if (this._files != null && this._files.length > 0) {
      widgets.add(getWidgetAttachment());
    }
    if (this._users != null && this._users.length > 0) {
      widgets.add(Container(
          padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
          child: Column(
              children: AppHelpers.getLayoutCorrelativeUsers(
                  this._users, "Danh sách tham gia"))));
    }
    return widgets;
  }

  Future<bool> onBackClick() async {
    AppHelpers.navigatorToHome(context, IndexTabHome.CalendarWeek);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => onBackClick(),
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: AppCache.colorApp,
                automaticallyImplyLeading: false,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => onBackClick()),
                actions: (this.lichTuan != null &&
                        this.lichTuan.buttons.contains("delete"))
                    ? getWidgetDelete()
                    : null,
                title: Text(
                  this.lichTuan != null
                      ? "Chi tiết lịch tuần"
                      : "Loading ......",
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                )),
            persistentFooterButtons:
                this._buttons.length > 0 ? this._buttons : null,
            body: Container(
                color: Colors.white,
                child: this.lichTuan == null
                    ? Center(child: CircularProgressIndicator())
                    : ListView(
                        children: getWidgetLayout(),
                      ))));
  }
}

class CalendarDetailPage extends StatefulWidget {
  CalendarDetailPage({this.lichTuanId, this.isFromFormList = false});

  final String lichTuanId;
  final bool isFromFormList;

  @override
  State<StatefulWidget> createState() {
    return CalendarDetailPageState();
  }
}
