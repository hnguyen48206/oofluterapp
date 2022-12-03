import 'dart:core';
import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:date_format/date_format.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/calendar/calendar_create_step2.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class CalendarCreateStep1PageState extends State<CalendarCreateStep1Page> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _batDauController,
      _ketThucController,
      _noiDungController;
  ImagePicker _imagePicker = ImagePicker();

  DateTime _startTime;
  String _titleSave = '';

  Widget _headerWidget = Container(
      child: Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Thành phần"),
    AppHelpers.getHeaderStep(Colors.white, "Phân công"),
    AppHelpers.getHeaderStep(Colors.white, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    final form = formKey.currentState;
    if (form.validate() == true) {
      form.save();
      AppCache.currentCalendar.thoigianbatdau =
          this._batDauController.text.trim();
      AppCache.currentCalendar.thoigianketthuc =
          this._ketThucController.text.trim();
      AppCache.currentCalendar.noidung = this._noiDungController.text.trim();
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => CalendarCreateStep2Page()));
    }
  }

  @override
  initState() {
    this._titleSave = AppCache.currentCalendar.lichTuanId.isEmpty
        ? 'Đăng ký lịch tuần'
        : 'Chỉnh sửa lịch tuần';
    this._batDauController =
        TextEditingController(text: AppCache.currentCalendar.thoigianbatdau);
    this._ketThucController =
        TextEditingController(text: AppCache.currentCalendar.thoigianketthuc);
    this._noiDungController =
        TextEditingController(text: AppCache.currentCalendar.noidung);
    if (AppCache.currentCalendar.fileDinhKems != null &&
        AppCache.currentCalendar.fileDinhKems.length > 0) {
      AppCache.currentCalendar.files = AppCache.currentCalendar.fileDinhKems
          .map((p) => FileAttachment(p))
          .toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _lableTimeStart = Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Positioned(
                  //left: 0.0,
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                    size: 17.0,
                  ),
                ),
                Padding(
                  //left: 0,
                  //right: 0.0,
                  padding: const EdgeInsets.fromLTRB(30.0, 0, 0.0, 0.0),
                  child: Text('Thời gian bắt đầu',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.blue)),
                )
              ],
            )
          ],
        ));

    Widget _timeStart = Padding(
        padding: EdgeInsets.all(0),
        child: DateTimeField(
            autovalidateMode: AutovalidateMode.always,
            format: AppCache.datetimeFormat,
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            controller: _batDauController,
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                // labelText: 'Thời gian bắt đầu',
                labelStyle: TextStyle(
                    color: this._batDauController.text.isEmpty
                        ? Colors.grey
                        : Colors.black),
                fillColor: Colors.blue),
            onChanged: (dt) {
              this._startTime = dt;
              this._batDauController.text =
                  formatDate(dt, AppCache.datetimeFormatArray);
            },
            validator: (val) {
              var current = new DateTime.now();
              if (val != null && val.isBefore(current)) {
                return 'Thời gian bắt đầu nhỏ hơn thời gian hiện tại';
              }
              if (this._batDauController.text.isNotEmpty) return null;
              return val == null ? 'Vui lòng chọn thời gian bắt đầu' : null;
            },
            onSaved: (dt) {
              if (dt != null) {
                this._startTime = dt;
                this._batDauController.text =
                    formatDate(dt, AppCache.datetimeFormatArray);
              }
            }));
    Widget _lableTimeEnd = Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Padding(
                    //left: 0,
                    //right: 0.0,
                    padding: const EdgeInsets.fromLTRB(30.0, 0, 0.0, 0.0),
                    child: Text('Thời gian kết thúc',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.blue)),
                  ),
                  Positioned(
                    left: 0.0,
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                      size: 17,
                    ),
                  ),
                ],
              )
            ]));
    Widget _timeEnd = DateTimeField(
        format: AppCache.datetimeFormat,
        autovalidateMode: AutovalidateMode.always,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
        controller: this._ketThucController,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.blue,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            // labelText: 'Thời gian kết thúc',
            labelStyle: TextStyle(
                color: this._ketThucController.text.isEmpty
                    ? Colors.grey
                    : Colors.black),
            fillColor: Colors.blue),
        onChanged: (dt) => this._ketThucController.text =
            formatDate(dt, AppCache.datetimeFormatArray),
        validator: (val) {
          if (val == null) {
            if (this._ketThucController.text.isNotEmpty) return null;
            return 'Vui lòng chọn thời gian kết thúc';
          }
          if (this._startTime != null && val.isBefore(this._startTime)) {
            return 'Thời gian kết thúc lớn hơn thời gian bắt đầu';
          }
          return null;
        },
        onSaved: (dt) {
          if (dt != null) {
            this._ketThucController.text =
                formatDate(dt, AppCache.datetimeFormatArray);
          }
        });

    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            title: Text(
              this._titleSave,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: Form(
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
                  child: Text(
                    "Nội dung: ",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                    // autocorrect: true,
                    maxLines: 4,
                    controller: this._noiDungController,
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue))),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập nội dung';
                      }
                      return null;
                    },
                    onSaved: (val) => this._noiDungController.text = val),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "File đính kèm (${AppCache.currentCalendar.files.length})",
                          style: TextStyle(
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
      AppCache.currentCalendar.files.add(file);
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
            AppCache.currentCalendar.files.add(file);
          }
        });
      } else {
        return;
      }
    });
  }

  Widget getWidgetAttachment() {
    var widgets = <Widget>[];
    for (FileAttachment item in AppCache.currentCalendar.files) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
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
                                                  "LichTuan",
                                                  AppCache.currentCalendar
                                                      .lichTuanId)
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
                                                              .currentCalendar
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

class CalendarCreateStep1Page extends StatefulWidget {
  @override
  CalendarCreateStep1PageState createState() => CalendarCreateStep1PageState();
}
