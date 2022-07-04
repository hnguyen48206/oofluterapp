import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/library/library_list.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/library_model.dart';

class LibraryDetailPageState extends State<LibraryDetailPage> {
  List<TitleValue> _listRecords;
  Library record;

  @override
  void initState() {
    this.record = widget.library;
    if (widget.isFromFormList == true) {
      this.setData();
    }
    super.initState();
    this._loadDetail();
  }

  _loadDetail() async {
    FetchService.libraryGetDetailById(widget.library.id).then((Library item) {
      if (this.mounted) {
        setState(() {
          this.record = item;
          setData();
          if (item.fileDinhKems != null && item.fileDinhKems.length > 0) {
            this.record.files =
                item.fileDinhKems.map((p) => FileAttachment(p)).toList();
          }
        });
      }
    });
  }

  setData() {
    this._listRecords = [];
    this._listRecords.add(TitleValue('Mã số', record.title));
    this._listRecords.add(TitleValue('Nội dung', record.content));
    this._listRecords.add(TitleValue('Ngày ban hành', record.datePublish));
    this
        ._listRecords
        .add(TitleValue('Tạo bởi', AppCache.getFullNameById(record.creator)));
    this
        ._listRecords
        .add(TitleValue('Số lần xem', record.countView.toString()));
  }

  Widget _setBodyForm() {
    return Row(children: [
      Expanded(
          child: this._listRecords == null
              ? Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount:
                      this._listRecords.length + this.record.files.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    if (index < this._listRecords.length) {
                      TitleValue record = this._listRecords[index];
                      return ListTile(
                          title: Text(record.title),
                          subtitle: Text(record.value,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey)));
                    } else {
                      FileAttachment item =
                          this.record.files[index - this._listRecords.length];
                      return Container(
                          margin:
                              const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
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
                                          AppHelpers.downloadFile(
                                              item,
                                              "ThuVien",
                                              this.record.id,
                                              setProgressing,
                                              openFile);
                                        } else {
                                          AppHelpers.openFile(
                                              item, this.context);
                                        }
                                      })));
                    }
                  },
                ))
    ]);
  }

  // Future<void> downloadFile(
  //     FileAttachment file, String module, String id) async {
  //   Dio dio = Dio();
  //   try {
  //     Directory dir = await getApplicationDocumentsDirectory();
  //     file.localPath = "${dir.path}/$module";
  //     await AppHelpers.createFolder(file.localPath);
  //     file.localPath += "/$id";
  //     await AppHelpers.createFolder(file.localPath);
  //     file.localPath += "/${file.fileName}";
  //     dio.download(file.url, file.localPath, onReceiveProgress: (rec, total) {
  //       setState(() {
  //         file.isDownloading = true;
  //         String mbRec = (rec / 1048576).toStringAsFixed(1);
  //         String mbTotal = (total / 1048576).toStringAsFixed(1);
  //         file.progressing =
  //             "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
  //       });
  //     }).then((val) {
  //       setState(() {
  //         file.isDownloading = false;
  //         file.progressing = '';
  //       });
  //       AppHelpers.openFile(file, this.context);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  setProgressing(FileAttachment file, int rec, int total) {
    setState(() {
      file.isDownloading = true;
      String mbRec = (rec / 1048576).toStringAsFixed(1);
      String mbTotal = (total / 1048576).toStringAsFixed(1);
      file.progressing =
          "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
    });
  }

  openFile(FileAttachment file) {
    setState(() {
      file.isDownloading = false;
      file.progressing = '';
    });
    AppHelpers.openFile(file, this.context);
  }

  Future<bool> onBackClick() async {
    if (widget.isFromFormList == true) {
      Navigator.pop(context);
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LibraryPage()));
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
                title: Text('Chi tiết thư viện')),
            body: _setBodyForm()));
  }
}

class LibraryDetailPage extends StatefulWidget {
  LibraryDetailPage({this.library, this.isFromFormList = true});

  final Library library;
  final bool isFromFormList;

  @override
  State<StatefulWidget> createState() {
    return LibraryDetailPageState();
  }
}
