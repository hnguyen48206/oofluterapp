import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:mime_type/mime_type.dart';
import 'package:onlineoffice_flutter/announcement/announcement_detail.dart';
import 'package:onlineoffice_flutter/calendar/calendar_detail.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_chat.dart';
import 'package:onlineoffice_flutter/document/document_detail.dart';
import 'package:onlineoffice_flutter/helpers/weblink_viewer.dart';
import 'package:onlineoffice_flutter/library/library_detail.dart';
import 'package:onlineoffice_flutter/models/announcement_model.dart';
import 'package:onlineoffice_flutter/models/discuss_work_model.dart';
import 'package:onlineoffice_flutter/models/document_model.dart';
import 'package:onlineoffice_flutter/models/library_model.dart';
import 'package:onlineoffice_flutter/models/report_daily_model.dart';
import 'package:onlineoffice_flutter/models/work_project_model.dart';
import 'package:onlineoffice_flutter/old_version.dart';
import 'package:onlineoffice_flutter/report_daily/report_daily_detail.dart';
import 'package:onlineoffice_flutter/work_project/work_project_chat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:open_file/open_file.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:onlineoffice_flutter/helpers/image_viewer.dart';
import 'package:onlineoffice_flutter/helpers/pdf_viewer.dart';
import 'package:onlineoffice_flutter/announcement/announcement_list.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';

class AppHelpers {
  static getBadgeNumberRepeater() {
    const interval = Duration(seconds: 3);
    Timer.periodic(interval, (Timer t) => loadBadgeNumber());
  }

  static Future<void> loadBadgeNumber() async {
    // print('Gọi sau mỗi 3s');
    if (AppCache.currentUser.userId.isNotEmpty) {
      FetchService.getBadgeNumberApp().then((List<int> items) {
        if (items != null && items.length > 0) {
          for (int i = 0; i < items.length; i++) AppCache.badges[i] = items[i];
        }
        if (HomePage.globalKey.currentState != null) {
          HomePage.globalKey.currentState.refreshState();
        }
        if (AppCache.badges[IndexBadgeApp.TotalApp.index] == 0)
          FlutterAppBadger.removeBadge();
        else
          FlutterAppBadger.updateBadgeCount(
              AppCache.badges[IndexBadgeApp.TotalApp.index]);
      });
    }
  }

  static openNextForm(BuildContext context) async {
    if (AppCache.currentUser.isOldVersion) {
      if (AppCache.messageNotify == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => OldVersionPage()));
      } else {
        String module;
        String id;
        if (Platform.isAndroid == true) {
          module = AppCache.messageNotify['data']['module'];
          id = AppCache.messageNotify['data']['id'];
        } else {
          module = AppCache.messageNotify['module'];
          id = AppCache.messageNotify['id'];
        }
        AppCache.messageNotify = null;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OldVersionPage(module: module, id: id)));
      }
    } else {
      if (AppCache.messageNotify == null) {
        navigatorToHome(context, IndexTabHome.Dashboard);
      } else {
        bool resultOpenDetailFromNotify = await _openDetailFromNotify(context);
        if (resultOpenDetailFromNotify == false) {
          String module;
          String id;
          if (Platform.isAndroid == true) {
            module = AppCache.messageNotify['data']['module'];
            id = AppCache.messageNotify['data']['id'];
          } else {
            module = AppCache.messageNotify['module'];
            id = AppCache.messageNotify['id'];
          }
          String linkWeb =
              FetchService.getLinkMobileLogin() + "&L=" + module + "&I=" + id;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebLinkViewerPage(
                      title: "Online Office", link: linkWeb)));
        }
      }
    }
  }

  static Future<bool> _openDetailFromNotify(BuildContext context) async {
    String module = Platform.isAndroid
        ? AppCache.messageNotify['data']['module']
        : AppCache.messageNotify['module'];
    if (module == 'TraoDoi') module = 'TraoDoiCV';
    if (AppCache.currentUser.modulesActive.contains(module) == false)
      return false;
    String id = Platform.isAndroid
        ? AppCache.messageNotify['data']['id']
        : AppCache.messageNotify['id'];
    if (module == 'BaoCao') {
      AppCache.messageNotify = null;
      AppCache.currentReportDaily = ReportDaily(id, '', '');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ReportDailyDetailPage()));
      return true;
    }
    if (module == 'LichTuan') {
      AppCache.messageNotify = null;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CalendarDetailPage(lichTuanId: id)),
      );
      return true;
    }
    if (module == 'TraoDoiCV') {
      AppCache.messageNotify = null;
      DiscussWork result = await FetchService.getDiscussWorkById(id);
      if (result != null) {
        AppCache.currentDiscussWork = result;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DiscussWorkChatPage()));
        return true;
      }
      return false;
    }
    if (module == 'CongViec') {
      AppCache.messageNotify = null;
      WorkProject result = await FetchService.workProjectGetById(id);
      if (result != null) {
        AppCache.currentWorkProject = result;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => WorkProjectChatPage()));
        return true;
      }
      return false;
    }
    if (module == 'VanBan') {
      AppCache.messageNotify = null;
      AppCache.currentDocumentDetail = DocumentDetail(id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DocumentDetailPage(kind: '')));
      return true;
    }
    if (module == 'ThongBao') {
      AppCache.messageNotify = null;
      AppCache.currentAnnouncement = Announcement(id);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => AnnouncementDetailPage()));
      return true;
    }
    if (module == 'ThuVien') {
      AppCache.messageNotify = null;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LibraryDetailPage(
                  library: Library(id), isFromFormList: false)));
      return true;
    }
    return false;
  }

  static void navigatorToHome(BuildContext context, IndexTabHome indexTabHome) {
    if (HomePage.globalKey.currentState == null) {
      Navigator.of(context).push(MaterialPageRoute(
          settings: RouteSettings(name: "/HomePage"),
          builder: (context) => HomePage(startTabIndex: indexTabHome)));
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName("/HomePage"));
      HomePage.globalKey.currentState.setFromDashboard(indexTabHome);
    }
  }

  static Expanded getHeaderStep(Color colorChecked, String text) {
    return new Expanded(
      child: new Column(
        children: <Widget>[
          new RawMaterialButton(
            onPressed: () {},
            constraints: new BoxConstraints(minWidth: 20.0, minHeight: 20.0),
            shape: new CircleBorder(),
            elevation: 1.0,
            fillColor: colorChecked,
            padding: const EdgeInsets.all(7.0),
          ),
          new Text(
            text,
            style: new TextStyle(fontSize: 12.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  static Widget getItemFile(
      FileAttachment item,
      String module,
      String recordId,
      Function setProgressing,
      Function setCompleted,
      EdgeInsets margin,
      BuildContext context) {
    return InkWell(
        child: Container(
            margin: margin,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: item.isDownloading
                          ? CircularProgressIndicator()
                          : item.icon.isEmpty
                              ? Icon(Icons.attach_file,
                                  color: Colors.green, size: 24.0)
                              : Image(
                                  width: 24,
                                  height: 24,
                                  image: NetworkImage(item.icon))),
                  Flexible(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 10, right: 10),
                            child: Text(item.fileName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(color: Colors.black))),
                        Padding(
                            padding:
                                EdgeInsets.only(right: 10, top: 5, bottom: 10),
                            child: item.progressing.isEmpty
                                ? (item.size > 0
                                    ? Text(item.getTextSize(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(color: Colors.grey))
                                    : Text(''))
                                : Text(item.progressing,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(color: Colors.grey)))
                      ]))
                ])),
        onTap: () {
          if (item.localPath.isEmpty) {
            downloadFile(item, module, recordId, setProgressing, setCompleted);
          } else {
            openFile(item, context);
          }
        });
  }

  static Future<void> createFolder(String path) async {
    if (await Directory(path).exists() == false) {
      Directory(path).createSync(recursive: true);
    }
  }

  static deleteFile(String pathFile) async {
    getApplicationDocumentsDirectory().then((dir) {
      var file = File('${dir.path}/$pathFile');
      file.exists().then((isExist) {
        if (isExist) {
          file.delete();
        }
      });
    });
  }

  static Future<void> downloadFile(FileAttachment file, String module,
      String id, Function func1, Function func2) async {
    Dio dio = Dio();
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      file.localPath = "${dir.path}/$module";
      await createFolder(file.localPath);
      file.localPath += "/$id";
      await createFolder(file.localPath);
      file.localPath += "/${file.fileName}";
      dio.download(file.url, file.localPath, onReceiveProgress: (rec, total) {
        func1(file, rec, total);
      }).then((val) {
        func2(file);
      });
    } catch (e) {
      print(e);
    }
  }

  static openFile(FileAttachment file, BuildContext context) {
    if (file.extension == null || file.extension.isEmpty) {
      file.extension = file.fileName.split(".").last.toLowerCase();
    }
    if (file.extension == "pdf") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => PdfViewerPage(file: file)));
    } else if (AppCache.extsImage.contains(file.extension.toLowerCase())) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ImageViewerPage(file: file)));
    } else {
      try {
        OpenFile.open(file.localPath).then((result) {
          if (result.type == ResultType.noAppToOpen ||
              result.type == ResultType.error) {
            shareFile(file);
          }
        });
      } on Exception {
        shareFile(file);
      }
    }
  }

  static shareFile(FileAttachment file) {
    if (file.mimeType == null || file.mimeType.isEmpty) {
      file.mimeType = mime(file.fileName);
    }
    if (file.fileName.length > 100) {
      file.fileName = file.fileName.substring(file.fileName.length - 100);
    }
    if (file.bytes == null) {
      File(file.localPath).readAsBytes().then((bytes) {
        Share.file(file.fileName, file.fileName, bytes.buffer.asUint8List(),
            file.mimeType);
      });
    } else {
      Share.file(file.fileName, file.fileName, file.bytes, file.mimeType);
    }
  }

  static getLayoutCorrelativeUsers(List<Account> listUser, String title) {
    List<Widget> widgets = <Widget>[];
    if (listUser == null || listUser.length == 0) return widgets;
    widgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Text("$title (${listUser.length})",
            style: new TextStyle(
                color: Colors.blue,
                fontSize: 16.0,
                fontWeight: FontWeight.bold)),
        // new Icon(Icons.create, size: 18.0, color: Colors.blue)
      ],
    ));

    for (Account item in listUser) {
      widgets.add(Container(
        margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]),
        ),
        child: new ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(item.avatar),
          ),
          title: new Text(
            item.fullName,
            style: new TextStyle(color: Colors.black),
          ),
        ),
      ));
    }

    return widgets;
  }

  static void alertDialogClose(
      BuildContext context, String title, String content, bool isOK) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
              title: Text(title),
              content: Text(content,
                  style: TextStyle(
                      color: isOK ? Colors.blueAccent : Colors.redAccent)),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Đóng", style: TextStyle(color: Colors.black)))
              ]);
        });
  }

  static void showActionSheet(
      String title, List<Widget> widgets, BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              title: Text(title, style: TextStyle(color: Colors.black)),
              // message: Text("Chọn hành động"),
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Đóng")),
              actions: widgets);
        });
  }

  static void announcementCancelAction(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(AppCache.currentAnnouncement.title),
            content: Text("Bạn có chắc chắn muốn hủy thao tác ?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Không")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    AppCache.currentAnnouncement = null;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AnnouncementPage()));
                  },
                  child: Text("Có"))
            ],
          );
        });
  }
}
