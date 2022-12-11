import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/helpers/find_project.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:date_format/date_format.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:diacritic/diacritic.dart';

class WorkProjectCreateStep1PageState
    extends State<WorkProjectCreateStep1Page> {
  final formKey = GlobalKey<FormState>();
  bool _isEnableEditting = true;

  TextEditingController _batDauController,
      _ketThucController,
      _chuDeController,
      _noiDungController;
  ImagePicker _imagePicker = ImagePicker();

  int sharedValue = 0;
  bool _isLoading = false;

  DateTime _startTime;
  DateTime _endTime;

  DateTime _initStartDate = DateTime.now().add(const Duration(minutes: 30));

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Người xử lý"),
    AppHelpers.getHeaderStep(Colors.white, "Người xem"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    final form = formKey.currentState;
    try {
      var check = form.validate();
      if (check) {
        // form.save();
        AppCache.currentWorkProject.ngayBatDau =
            this._batDauController.text.trim();
        AppCache.currentWorkProject.ngayKetThuc =
            this._ketThucController.text.trim();
        AppCache.currentWorkProject.title = this._chuDeController.text.trim();
        AppCache.currentWorkProject.content =
            this._noiDungController.text.trim();
        Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => WorkProjectCreateStep2Page()));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  initState() {
    // if (AppCache.isCreatedFromDocs)
    //   this._isEnableEditting = false;
    // else
    //   this._isEnableEditting = true;
    this._batDauController = TextEditingController();
    this._ketThucController = TextEditingController();
    this._chuDeController = TextEditingController();
    this._noiDungController = TextEditingController();
    if (AppCache.currentWorkProject.title.isNotEmpty) {
      this._chuDeController.text = AppCache.currentWorkProject.title;
    }
    if (AppCache.currentWorkProject.content.isNotEmpty) {
      this._noiDungController.text =
          ObjectHelper.removeHTML(AppCache.currentWorkProject.content);
    }

    if (AppCache.currentWorkProject.fileDinhKems != null &&
        AppCache.currentWorkProject.fileDinhKems.length > 0) {
      AppCache.currentWorkProject.files = AppCache
          .currentWorkProject.fileDinhKems
          .map((p) => FileAttachment(p))
          .toList();
    }

    this._startTime = _initStartDate;
    this._batDauController.text =
        formatDate(_initStartDate, AppCache.dateVnFormatArray);
    this._batDauController.value =
        TextEditingValue(text: this._batDauController.text);
    this._endTime = _initStartDate.add(const Duration(days: 14));
    this._ketThucController.text =
        formatDate(_endTime, AppCache.dateVnFormatArray);
    this._ketThucController.value =
        TextEditingValue(text: this._ketThucController.text);
    AppCache.currentWorkProject.ngayBatDau = this._batDauController.text.trim();
    AppCache.currentWorkProject.ngayKetThuc =
        this._ketThucController.text.trim();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _lableTimeStart = new Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: new Column(
          //mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Stack(
              children: <Widget>[
                new Positioned(
                  //left: 0.0,
                  child: new Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                    size: 17.0,
                  ),
                ),
                new Padding(
                  //left: 0,
                  //right: 0.0,
                  padding: const EdgeInsets.fromLTRB(30.0, 0, 0.0, 0.0),
                  child: new Text('Ngày bắt đầu',
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.blue)),
                )
              ],
            )
          ],
        ));

    Widget _timeStart = new Padding(
        padding: new EdgeInsets.all(0),
        child: new DateTimeField(
            format: AppCache.dateVnFormat,
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? _startTime,
                  lastDate: DateTime(2100));
            },
            controller: _batDauController,
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue,
                  ),
                ),
                contentPadding:
                    new EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.blue)),
                labelText: 'Ngày bắt đầu',
                labelStyle: TextStyle(
                    color: this._batDauController.text.isEmpty
                        ? Colors.grey
                        : Colors.black),
                fillColor: Colors.blue),
            onChanged: (dt) {
              print(dt);
              this._startTime = dt;
            },
            validator: (val) {
              return val == null && this._startTime == null
                  ? 'Chọn ngày bắt đầu'
                  : null;
            },
            onSaved: (dt) {
              this._startTime = dt;
              this._batDauController.text =
                  formatDate(dt, AppCache.dateVnFormatArray);
            }));

    Widget _lableTimeEnd = new Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Stack(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 0, 0.0, 0.0),
                  child: new Text('Ngày hoàn thành',
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.blue)),
                ),
                new Positioned(
                  left: 0.0,
                  child: new Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                    size: 17,
                  ),
                ),
              ],
            ),
            // new Stack(
            //   children: <Widget>[
            //     new Positioned(
            //         //top: 0,
            //         //left: 0.0,
            //         //right: 0.0,
            //         child: new Checkbox(
            //             value: _check,
            //             //checkColor: Colors.blue,
            //             activeColor: Colors.blue,
            //             onChanged: (bool value) {
            //               setState(() {
            //                 _check = !_check;
            //                 //print(_check);
            //               });
            //             })),
            //     new Padding(
            //       //left: 0,
            //       //right: 0.0,
            //       padding: const EdgeInsets.fromLTRB(40.0, 15.0, 0.0, 0.0),
            //       // padding: const EdgeInsets.all(0),
            //       child: new Text('Diễn ra cả ngày',
            //           style: new TextStyle(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 16.0,
            //               color: Colors.blue)),
            //     ),
            //   ],
            // ),
          ],
        ));
    Widget _timeEnd = new DateTimeField(
        format: AppCache.dateVnFormat,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? _endTime,
              lastDate: DateTime(2100));
        },
        controller: this._ketThucController,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.blue,
              ),
            ),
            contentPadding:
                new EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.blue)),
            labelText: 'Ngày hoàn thành',
            labelStyle: TextStyle(
                color: this._ketThucController.text.isEmpty
                    ? Colors.grey
                    : Colors.black),
            fillColor: Colors.blue),
        validator: (val) {
          if (val == null && this._endTime == null) {
            return 'Vui lòng nhập chọn ngày hoàn thành';
          }
          if (this._endTime.isBefore(this._startTime)) {
            return 'Ngày hoàn thành lớn hơn ngày bắt đầu';
          }
          return null;
        },
        onChanged: (dt) {
          this._endTime = dt;
        },
        onSaved: (dt) {
          this._endTime = dt;
          this._ketThucController.text =
              formatDate(dt, AppCache.dateVnFormatArray);
        });

    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            title: Text(
              'TẠO CÔNG VIỆC',
              style: new TextStyle(fontSize: 18.0, color: Colors.white),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: this._isLoading
            ? Container(child: Center(child: CircularProgressIndicator()))
            : Form(
                key: this.formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  children: <Widget>[
                    this._headerWidget,
                    _lableTimeStart,
                    _timeStart,
                    _lableTimeEnd,
                    _timeEnd,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: new Text(
                        "Tên CV: ",
                        style: new TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextFormField(
                        enabled: this._isEnableEditting,
                        autocorrect: true,
                        maxLines: 4,
                        controller: this._chuDeController,
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            contentPadding: new EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.blue))),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Vui lòng nhập tên công việc';
                          }
                          return null;
                        },
                        onChanged: (val) =>
                            AppCache.currentWorkProject.title = val,
                        onSaved: (val) => this._chuDeController.text = val),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: new Text(
                          "Dự án: ",
                          style: new TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue)),
                        child: ListTile(
                            title: Text(AppCache.currentWorkProject.msda.isEmpty
                                ? 'Không có'
                                : AppCache.getCategoryNameById(
                                    AppCache.allProject,
                                    AppCache.currentWorkProject.msda)),
                            trailing: IconButton(
                                icon: Icon(Icons.fast_forward,
                                    color: Colors.green),
                                onPressed: () {
                                  this._batDauController.text = formatDate(
                                      this._startTime,
                                      AppCache.dateVnFormatArray);
                                  this._ketThucController.text = formatDate(
                                      this._endTime,
                                      AppCache.dateVnFormatArray);
                                  this._chuDeController.text =
                                      AppCache.currentWorkProject.title;
                                  this._noiDungController.text =
                                      AppCache.currentWorkProject.content;
                                  if (AppCache.allProject.length == 0) {
                                    setState(() {
                                      this._isLoading = true;
                                    });
                                    FetchService.setAllProject().then((isOK) {
                                      setState(() {
                                        this._isLoading = false;
                                      });
                                      if (isOK) {
                                        Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FindCategoryPage(
                                                        kindAction:
                                                            KindAction.Project,
                                                        listCategory: AppCache
                                                            .allProject)));
                                      }
                                    });
                                  } else
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FindCategoryPage(
                                                    kindAction:
                                                        KindAction.Project,
                                                    listCategory:
                                                        AppCache.allProject)));
                                }))),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: new Text(
                        "Nội dung: ",
                        style: new TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextFormField(
                        enabled: this._isEnableEditting,
                        autocorrect: true,
                        maxLines: 4,
                        controller: this._noiDungController,
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            contentPadding: new EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.blue))),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          return null;
                        },
                        onChanged: (val) =>
                            AppCache.currentWorkProject.content = val,
                        onSaved: (val) => this._noiDungController.text = val),
                    ListTile(
                        title: Text('Công việc khẩn cấp'),
                        trailing: Checkbox(
                          value: AppCache.currentWorkProject.cvKhanCap,
                          tristate: true,
                          activeColor: Colors.blue,
                          checkColor: Colors.lightBlueAccent,
                          onChanged: (val) {
                            setState(() {
                              AppCache.currentWorkProject.cvKhanCap = val;
                            });
                          },
                        )),
                    ListTile(
                        title: Text('Công việc cần theo dõi'),
                        trailing: Checkbox(
                          value: AppCache.currentWorkProject.cvCanTheoDoi,
                          tristate: true,
                          activeColor: Colors.blue,
                          checkColor: Colors.lightBlueAccent,
                          onChanged: (val) {
                            setState(() {
                              AppCache.currentWorkProject.cvCanTheoDoi = val;
                            });
                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              "File đính kèm (${AppCache.currentWorkProject.files.length})",
                              style: new TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                                onPressed: () {
                                  attachFileOptions();
                                },
                                icon: Icon(Icons.add_circle,
                                    size: 30.0, color: Colors.green))
                          ],
                        )),
                    getWidgetAttachment(),
                    SizedBox(height: 80.0)
                  ],
                )));
  }

  attachImageVideo(bool isVideo, ImageSource fromSource) async {
    PickedFile pickedFile;
    if (isVideo) {
      pickedFile = await this._imagePicker.getVideo(source: fromSource);
    } else {
      pickedFile = await this._imagePicker.getImage(source: fromSource);
    }
    if (pickedFile == null) return;
    setState(() {
      FileAttachment file = FileAttachment.empty();
      file.fileName = pickedFile.path.split("/").last;
      file.mimeType = '';
      file.url = '';
      file.localPath = pickedFile.path;
      file.isDownloading = false;
      file.extension = file.fileName.split(".").last;
      file.progressing = '';
      AppCache.currentWorkProject.files.add(file);
    });
  }

  attachFiles() async {
    FilePicker.platform.pickFiles(allowMultiple: true).then((result) {
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path)).toList();
        setState(() {
          for (var item in files) {
            FileAttachment file = FileAttachment.empty();
            file.fileName = item.path.split("/").last;
            file.mimeType = '';
            file.url = '';
            file.localPath = item.path;
            file.isDownloading = false;
            file.extension = file.fileName.split(".").last;
            file.progressing = '';
            AppCache.currentWorkProject.files.add(file);
          }
        });
      } else {
        return;
      }
    });
  }

  attachFileOptions() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text("Upload hình ảnh, video, files",
                style: TextStyle(color: Colors.black)),
            message: Text("Chọn hành động"),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Đóng")),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageVideo(false, ImageSource.gallery);
                  },
                  child: Text("Chọn ảnh từ Gallery")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageVideo(true, ImageSource.gallery);
                  },
                  child: Text("Chọn video từ Gallery")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageVideo(false, ImageSource.camera);
                  },
                  child: Text("Chụp ảnh từ Camera")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageVideo(true, ImageSource.camera);
                  },
                  child: Text("Quay video từ Camera")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachFiles();
                  },
                  child: Text("Chọn từ trình quản lý files",
                      style: TextStyle(color: Colors.red)))
            ],
          );
        });
  }

  Widget getWidgetAttachment() {
    List<Widget> widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentWorkProject.files) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
          child: new ListTile(
              leading: item.isDownloading ? CircularProgressIndicator() : null,
              title: new Text(
                item.fileName,
                style: new TextStyle(color: Colors.black),
              ),
              subtitle:
                  item.progressing.isEmpty ? null : Text(item.progressing),
              trailing: item.isDownloading
                  ? null
                  : IconButton(
                      icon: Icon(Icons.send, color: Colors.green),
                      onPressed: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return CupertinoActionSheet(
                                title: Text(item.fileName,
                                    style: TextStyle(color: Colors.black)),
                                message: Text("Chọn hành động"),
                                cancelButton: CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Đóng")),
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (item.localPath.isEmpty) {
                                          this
                                              .downloadFile(
                                                  item,
                                                  "CongViec",
                                                  AppCache
                                                      .currentWorkProject.id)
                                              .then((val) {
                                            if (val == true) {
                                              AppHelpers.openFile(
                                                  item, this.context);
                                            }
                                          });
                                        } else {
                                          AppHelpers.openFile(
                                              item, this.context);
                                        }
                                      },
                                      child: Text("Xem")),
                                  CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (context) {
                                              return CupertinoAlertDialog(
                                                title: Text(item.fileName),
                                                content: Text(
                                                    "Bạn có chắc chắn muốn xoá file này ?"),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("Không", style: TextStyle(color: Colors.white, fontSize: 14.0))),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          AppCache
                                                              .currentWorkProject
                                                              .files
                                                              .remove(item);
                                                        });
                                                      },
                                                      child: Text("Có", style: TextStyle(color: Colors.white, fontSize: 14.0)))
                                                ],
                                              );
                                            });
                                      },
                                      child: Text("Xoá",
                                          style: TextStyle(color: Colors.red)))
                                ],
                              );
                            });
                      }))));
    }
    return Column(children: widgets);
  }

  Future<bool> downloadFile(
      FileAttachment file, String module, String id) async {
    Dio dio = Dio();
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      file.localPath = "${dir.path}/$module/$id";
      await AppHelpers.createFolder(file.localPath);
      file.localPath += "/${file.fileName}";
      await dio.download(file.url, file.localPath,
          onReceiveProgress: (rec, total) {
        setState(() {
          file.isDownloading = true;
          String mbRec = (rec / 1048576).toStringAsFixed(1);
          String mbTotal = (total / 1048576).toStringAsFixed(1);
          file.progressing =
              "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
        });
      });
      file.isDownloading = false;
      file.progressing = '';
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

class WorkProjectCreateStep1Page extends StatefulWidget {
  @override
  WorkProjectCreateStep1PageState createState() =>
      WorkProjectCreateStep1PageState();
}
