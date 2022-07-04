import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/announcement/announcement_create_step1.dart';
import 'package:onlineoffice_flutter/announcement/announcement_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  int sharedValue = 0;
  List<Widget> _buttons = <Widget>[];

  final Map<int, Widget> segmentButtons = const <int, Widget>{
    0: Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold)),
    1: Text('Đã xem', style: TextStyle(fontWeight: FontWeight.bold))
  };

  @override
  void initState() {
    super.initState();
    this._loadData();
  }

  _loadData() async {
    FetchService.announcementGetDetail().then((bool status) {
      if (status && this.mounted) {
        setState(() {
          if (AppCache.currentAnnouncement.buttons != null &&
              AppCache.currentAnnouncement.buttons.length > 0) {
            _setButtonsAction();
          }
          if (AppCache.currentAnnouncement.fileDinhKems != null &&
              AppCache.currentAnnouncement.fileDinhKems.length > 0) {
            AppCache.currentAnnouncement.files = AppCache
                .currentAnnouncement.fileDinhKems
                .map((p) => FileAttachment(p))
                .toList();
          }
        });
        FetchService.announcementGetViewerStatus().then((bool status) {});
      }
    });
  }

  void _setButtonsAction() {
    this._buttons.clear();
    for (var button in AppCache.currentAnnouncement.buttons) {
      switch (button) {
        case "Delete":
          this._buttons.add(RaisedButton.icon(
              label: Text("Xoá",
                  style: TextStyle(color: Colors.white, fontSize: 14.0)),
              color: Colors.redAccent,
              elevation: 0.0,
              icon: Icon(Icons.cancel, color: Colors.black),
              onPressed: () {
                showPopupDelete();
              }));
          break;
        case "Edit":
          this._buttons.add(RaisedButton.icon(
              color: Colors.green,
              elevation: 0.0,
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                    this.context,
                    MaterialPageRoute(
                        builder: (context) => AnnouncementCreateStep1Page()));
              },
              label: Text("Chỉnh sửa",
                  style: TextStyle(color: Colors.white, fontSize: 14.0))));
          break;
        default:
      }
    }
  }

  showPopupDelete() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(AppCache.currentAnnouncement.title),
            content: Text("Bạn có chắc chắn muốn xoá ?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Không")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FetchService.deleteAnnouncement(
                            AppCache.currentAnnouncement.id)
                        .then((bool value) {
                      if (value) {
                        AppHelpers.alertDialogClose(
                            context, "Xoá thông báo", 'THÀNH CÔNG !!!', true);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnnouncementPage()));
                      } else {
                        AppHelpers.alertDialogClose(context, "Xoá thông báo",
                            'KHÔNG THÀNH CÔNG, vui lòng thử lại !', false);
                      }
                    });
                  },
                  child: Text("Có"))
            ],
          );
        });
  }

  _setBodyForm() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(5.0),
        child: Column(children: <Widget>[
          ListTile(
              trailing: AppCache.currentAnnouncement.isUrgent()
                  ? Text('Khẩn',
                      style: TextStyle(
                          backgroundColor: Colors.orange, color: Colors.white))
                  : null,
              title: Text(AppCache.currentAnnouncement.title,
                  style: TextStyle(
                      color: AppCache.currentAnnouncement.isUrgent()
                          ? Colors.red
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0))),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.0),
              child: CupertinoSegmentedControl<int>(
                  children: segmentButtons,
                  onValueChanged: (int val) {
                    setState(() {
                      this.sharedValue = val;
                    });
                  },
                  groupValue: this.sharedValue)),
          getDetail()
        ]));
  }

  Widget getDetail() {
    if (this.sharedValue == 0) {
      return Expanded(
          child: ListView.separated(
              itemCount: AppCache.currentAnnouncement.files.length + 1,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SingleChildScrollView(
                      child: HtmlWidget(AppCache.currentAnnouncement.content,
                          webView: true, webViewJs: false));
                }
                FileAttachment item =
                    AppCache.currentAnnouncement.files[index - 1];
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
                                    this.downloadFile(item, "ThongBao",
                                        AppCache.currentAnnouncement.id);
                                  } else {
                                    AppHelpers.openFile(item, this.context);
                                  }
                                })));
              }));
    }
    if (this.sharedValue == 1) {
      return Expanded(
          child: ListView.separated(
        itemCount: AppCache.currentAnnouncement.viewerStatus.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.grey),
        itemBuilder: (context, index) {
          ViewerStatus record =
              AppCache.currentAnnouncement.viewerStatus[index];
          return ListTile(
              title: Text(record.getFullName()),
              subtitle: Text(
                  record.countView == 0
                      ? 'Chưa xem lần nào'
                      : 'Xem ${record.countView} lần, lần cuối: ${record.getTimeInChat()}',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey)));
        },
      ));
    }
    return Center(child: CircularProgressIndicator());
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

  Future<bool> onBackClick() async {
    if (widget.isFromFormList == true) {
      Navigator.pop(context);
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => AnnouncementPage()));
    }
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
                title: Text('Chi tiết thông báo')),
            persistentFooterButtons:
                this._buttons.length > 0 ? this._buttons : null,
            body: _setBodyForm()));
  }
}

class AnnouncementDetailPage extends StatefulWidget {
  AnnouncementDetailPage({this.isFromFormList = false});

  final bool isFromFormList;

  @override
  State<StatefulWidget> createState() {
    return AnnouncementDetailPageState();
  }
}
