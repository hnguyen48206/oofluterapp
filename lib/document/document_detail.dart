import 'dart:async';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/work_project/work_project_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class DocumentDetailPageState extends State<DocumentDetailPage> {
  int sharedValue = 0;

  final Map<int, Widget> segmentButtons = const <int, Widget>{
    0: Text('Tập tin', style: TextStyle(fontWeight: FontWeight.bold)),
    1: Text('Thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
    2: Text('Đã xem', style: TextStyle(fontWeight: FontWeight.bold))
  };

  @override
  void initState() {
    super.initState();
    this._loadData();
  }

  _loadData() async {
    FetchService.documentInfo(widget.kind, this.sharedValue)
        .then((bool status) {
      if (status && this.mounted) {
        setState(() {});
      }
    });
  }

  _setBodyForm() {
    return Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.0),
              child: CupertinoSegmentedControl<int>(
                  children: segmentButtons,
                  onValueChanged: (int val) {
                    this.sharedValue = val;
                    this._loadData();
                  },
                  groupValue: this.sharedValue)),
          getDetail()
        ]));
  }

  String getTitle() {
    switch (widget.kind) {
      case 'VBNO':
        return 'Chi tiết văn bản nội bộ';
      case 'VBDI':
        return 'Chi tiết văn bản đi';
      case 'VBDE':
        return 'Chi tiết văn bản đến';
      default:
        return 'Chi tiết văn bản';
    }
  }

  Widget getDetail() {
    if (this.sharedValue == 0) {
      return Expanded(
          child: ListView.builder(
        itemCount: AppCache.currentDocumentDetail.files.length +
            (AppCache.currentDocumentDetail.workProjectId.length > 1 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < AppCache.currentDocumentDetail.files.length) {
            FileAttachment item = AppCache.currentDocumentDetail.files[index];
            return AppHelpers.getItemFile(
                item,
                "VanBan",
                AppCache.currentDocumentDetail.id,
                setProgressing,
                setCompleted,
                EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                this.context);
          } else {
            return Container(
                margin: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
                child: Center(
                    child: RaisedButton(
                        color: Colors.blue,
                        elevation: 0.0,
                        highlightElevation: 0.0,
                        child: Text(
                          'Xem xử lý',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          FetchService.workProjectGetById(
                                  AppCache.currentDocumentDetail.workProjectId)
                              .then((result) {
                            if (result != null) {
                              AppCache.currentWorkProject = result;
                              Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                    builder: (context) => WorkProjectChatPage(
                                        formName: widget.kind,
                                        objId:
                                            AppCache.currentDocumentDetail.id)),
                              );
                            }
                          });
                        })));
          }
        },
      ));
    }
    if (this.sharedValue == 1) {
      return Expanded(
          child: ListView.separated(
              itemCount: AppCache.currentDocumentDetail.infos.length,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                List<String> arr =
                    AppCache.currentDocumentDetail.infos[index].split('!;!');
                return ListTile(
                    title: Text(arr[0]),
                    subtitle: Text(arr[1],
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey)));
              }));
    }
    if (this.sharedValue == 2) {
      return Expanded(
          child: ListView.separated(
        itemCount: AppCache.currentDocumentDetail.viewerStatus.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.grey),
        itemBuilder: (context, index) {
          ViewerStatus record =
              AppCache.currentDocumentDetail.viewerStatus[index];
          return ListTile(
              leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(AppCache.getAvatarUrl(record.userId))),
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

  setProgressing(FileAttachment file, int rec, int total) {
    setState(() {
      file.isDownloading = true;
      String mbRec = (rec / 1048576).toStringAsFixed(1);
      String mbTotal = (total / 1048576).toStringAsFixed(1);
      file.progressing =
          "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
    });
  }

  setCompleted(FileAttachment file) {
    setState(() {
      file.isDownloading = false;
      file.progressing = '';
    });
    AppHelpers.openFile(file, this.context);
  }

  Future<bool> onBackClick() async {
    AppHelpers.navigatorToHome(context, IndexTabHome.Document);
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
                title: Text(getTitle())),
            body: _setBodyForm()));
  }
}

class DocumentDetailPage extends StatefulWidget {
  DocumentDetailPage({this.kind, this.isFromFormList = false});

  final String kind;
  final bool isFromFormList;

  @override
  State<StatefulWidget> createState() {
    return DocumentDetailPageState();
  }
}
