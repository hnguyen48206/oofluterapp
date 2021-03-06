import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class DocumentCreateStep5PageState extends State<DocumentCreateStep5Page> {
  bool isSubmitting = false;
  Account nguoiXuLy;

  @override
  initState() {
    this.nguoiXuLy = AppCache.getUserById(AppCache.currentDocument.nguoiXuLy);
    super.initState();
  }

  void onNextClick() {
    setState(() {
      this.isSubmitting = true;
    });
    FetchService.documentInsertUpdate().then((saveOK) async {
      if (saveOK) {
        List<String> filesOld = <String>[];
        for (int i = 0; i < AppCache.currentDocument.files.length; i++) {
          if (AppCache.currentDocument.files[i].url.isEmpty) {
            await FetchService.fileUpload(
                AppCache.currentDocument.kieuVB == "VBDE"
                    ? "VBDen"
                    : (AppCache.currentDocument.kieuVB == "VBNB"
                        ? "VBNoiBo"
                        : "VBDi"),
                AppCache.currentDocument.id,
                AppCache.currentDocument.files[i].fileName,
                File(AppCache.currentDocument.files[i].localPath));
          } else {
            filesOld.add(AppCache.currentDocument.files[i].fileName);
          }
        }
        if (filesOld.length > 0 &&
            AppCache.currentDocument.fileDinhKems != null &&
            AppCache.currentDocument.fileDinhKems.length > 0) {
          List<String> filesRemove = <String>[];
          String fileName = '';
          for (int i = 0;
              i < AppCache.currentDocument.fileDinhKems.length;
              i++) {
            fileName = AppCache.currentDocument.fileDinhKems[i].split('?')[0];
            if (filesOld.contains(fileName) == false) {
              filesRemove.add(fileName);
            }
          }
          if (filesRemove.length > 0) {
            FetchService.fileDelete(
                "VanBan", AppCache.currentDocument.id, filesRemove);
          }
        }

        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text("T???o v??n b???n ?????n"),
                content: Text("TH??NH C??NG !!!"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        // Navigator.push(
                        //     this.context,
                        //     MaterialPageRoute(
                        //         builder: (context) => WorkProjectChatPage()));
                      },
                      child: Text("OK", style: TextStyle(color: Colors.blue)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(context, 'T???o v??n b???n ?????n',
            'KH??NG TH??NH C??NG, vui l??ng th??? l???i !', false);
        setState(() {
          this.isSubmitting = false;
        });
      }
    });
  }

  Widget getSubmitButton() {
    // if (AppCache.currentDocument.id != null &&
    //     AppCache.currentDocument.isEdited == 0) {
    //   return null;
    // }
    return this.isSubmitting
        ? CircularProgressIndicator()
        : FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: onNextClick,
            child: Icon(Icons.send, color: Colors.white),
          );
  }

  List<Widget> getWidgetsBody() {
    List<Widget> result = [];
    result.add(this._headerWidget);
    result.add(SizedBox(height: 10.0));
    result.add(getWidgetField("S??? th??? t???: ", AppCache.currentDocument.soThuTu));
    result.add(getWidgetField(
        "L??u b???n c???ng: ",
        AppCache.currentDocument.luuHoSo.isEmpty
            ? '-- Kh??ng ch???n ph??ng ban --'
            : AppCache.getGroupNameById(AppCache.currentDocument.luuHoSo)));
    result.add(getWidgetField("N??i g???i: ", AppCache.currentDocument.noiGui));
    result.add(getWidgetField("S??? v??n b???n: ", AppCache.currentDocument.code));
    result.add(getWidgetField(
        "Th?? m???c: ",
        AppCache.currentDocument.loaiVanBan == 0
            ? '-- Kh??ng ch???n th?? m???c --'
            : AppCache.getCategoryNameById(AppCache.allDocumentDirectories,
                AppCache.currentDocument.loaiVanBan.toString())));
    result.add(getWidgetField(
        "N??i ph??t h??nh: ", AppCache.currentDocument.noiPhatHanh));
    result.add(getWidgetField(
        "Ngu???n v??n b???n: ",
        AppCache.currentDocument.nguonVanBan == 0
            ? '-- Kh??ng ch???n ngu???n v??n b???n --'
            : AppCache.getCategoryNameById(AppCache.allDocumentSource,
                AppCache.currentDocument.nguonVanBan.toString())));
    result
        .addAll(getHtmlField("Tr??ch y???u: ", AppCache.currentDocument.trichYeu));
    result.addAll(getHtmlField("Ghi ch??: ", AppCache.currentDocument.ghiChu));

    result.add(getWidgetField("Ng??y g???i: ", AppCache.currentDocument.ngayGui));
    result
        .add(getWidgetField("Ng??y nh???n: ", AppCache.currentDocument.ngayNhan));
    result.add(getWidgetField("Ng??y k??: ", AppCache.currentDocument.ngayKy));
    result.add(getWidgetField(
        "Th???i h???n x??? l??: ", AppCache.currentDocument.thoiHanXuLy));
    if (AppCache.currentDocument.files.length > 0) {
      result.add(Container(
          child: new Column(
        children: <Widget>[
          new Padding(
              padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text(
                    "File ????nh k??m (${AppCache.currentDocument.files.length})",
                    style: new TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )),
          getWidgetAttachment()
        ],
      )));
    }
    if (AppCache.currentDocument.nguoiDuocXems.length > 0) {
      result.add(Container(
          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 20.0),
          child: Column(
              children: AppHelpers.getLayoutCorrelativeUsers(
                  AppCache.getUsersByIds(
                      AppCache.currentDocument.nguoiDuocXems),
                  "Danh s??ch ng?????i xem"))));
      if (this.nguoiXuLy != null) {
        result.add(Text(
          "Ng?????i chuy???n x??? l??: ",
          style: TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16.0),
        ));
        result.add(Container(
          margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]),
          ),
          child: new ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(this.nguoiXuLy.avatar),
            ),
            title: new Text(
              this.nguoiXuLy.fullName,
              style: new TextStyle(color: Colors.black),
            ),
          ),
        ));
      }
    }
    return result;
  }

  Widget getWidgetField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(
            title,
            style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
          new Text(value, style: TextStyle(color: Colors.black, fontSize: 16.0))
        ],
      ),
    );
  }

  List<Widget> getHtmlField(String title, String value) {
    List<Widget> result = [];
    result.add(SizedBox(height: 10.0));
    result.add(Text(
      title,
      style: TextStyle(
          color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16.0),
    ));
    result.add(Container(
        constraints: BoxConstraints(maxHeight: 400.0),
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(8.0)),
        child: SingleChildScrollView(
            child: HtmlWidget(value, webView: true, webViewJs: false))));
    return result;
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
                    AppHelpers.navigatorToHome(context, IndexTabHome.Document);
                  })
            ],
            title: new Center(
                child: Text('T???o v??n b???n ?????n',
                    style:
                        new TextStyle(fontSize: 18.0, color: Colors.white)))),
        floatingActionButton: getSubmitButton(),
        body: ListView(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            children: getWidgetsBody()));
  }

  Widget getWidgetAttachment() {
    List<Widget> widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentDocument.files) {
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
                          this.downloadFile(item, 'VanBan',
                              AppCache.currentDocument.id + '/' + 'files');
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
              "??ang t???i file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
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
    AppHelpers.getHeaderStep(Colors.white, "N???i dung"),
    AppHelpers.getHeaderStep(Colors.white, "Th???i gian"),
    AppHelpers.getHeaderStep(Colors.white, "File VB"),
    AppHelpers.getHeaderStep(Colors.white, "Ng?????i xem"),
    AppHelpers.getHeaderStep(Colors.blue, "Ho??n t???t")
  ]));
}

class DocumentCreateStep5Page extends StatefulWidget {
  @override
  DocumentCreateStep5PageState createState() => DocumentCreateStep5PageState();
}
