import 'dart:core';

import 'package:date_format/date_format.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/document/document_create_step3.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';

class DocumentCreateStep2PageState extends State<DocumentCreateStep2Page> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _ngayGuiController,
      _ngayDenController,
      _ngayKyController,
      _thoiHanXuLyController;

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.white, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Thời gian"),
    AppHelpers.getHeaderStep(Colors.white, "File VB"),
    AppHelpers.getHeaderStep(Colors.white, "Người xem"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    final form = formKey.currentState;
    if (form.validate() == true) {
      form.save();
      AppCache.currentDocument.ngayGui = this._ngayGuiController.text;
      AppCache.currentDocument.ngayNhan = this._ngayDenController.text;
      AppCache.currentDocument.ngayKy = this._ngayKyController.text;
      AppCache.currentDocument.thoiHanXuLy = this._thoiHanXuLyController.text;
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => DocumentCreateStep3Page()));
    }
  }

  @override
  initState() {
    this._ngayGuiController =
        TextEditingController(text: AppCache.currentDocument.ngayGui);
    this._ngayDenController =
        TextEditingController(text: AppCache.currentDocument.ngayNhan);
    this._ngayKyController =
        TextEditingController(text: AppCache.currentDocument.ngayKy);
    this._thoiHanXuLyController =
        TextEditingController(text: AppCache.currentDocument.thoiHanXuLy);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    AppHelpers.navigatorToHome(context, IndexTabHome.Document);
                  })
            ],
            title: Text(
              'TẠO VĂN BẢN ĐẾN',
              style: new TextStyle(fontSize: 18.0, color: Colors.white),
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
                  getTitle('Ngày gửi'),
                  getDateBox(this._ngayGuiController),
                  SizedBox(height: 5.0),
                  getTitle('Ngày đến'),
                  getDateBox(this._ngayDenController),
                  SizedBox(height: 5.0),
                  getTitle('Ngày ký'),
                  getDateBox(this._ngayKyController),
                  SizedBox(height: 5.0),
                  getTitle('Thời hạn xử lý'),
                  getDateBox(this._thoiHanXuLyController),
                  SizedBox(height: 80.0)
                ])));
  }

  Widget getTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: new Text(
        title,
        style: new TextStyle(
            color: Colors.blue, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getDateBox(TextEditingController _controller) {
    return DateTimeField(
        format: AppCache.dateVnFormat,
        initialValue: ObjectHelper.dateVnToDateTime(_controller.text),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
        controller: _controller,
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
            // labelText: 'Chọn ngày',
            labelStyle: TextStyle(
                color: _controller.text.isEmpty ? Colors.grey : Colors.black),
            fillColor: Colors.blue),
        validator: (val) {
          if (val == null) {
            return 'Vui lòng nhập chọn ngày';
          }
          // if (val.isBefore(this._startTime)) {
          //   return 'Ngày hoàn thành lớn hơn ngày bắt đầu';
          // }
          return null;
        },
        onSaved: (dt) {
          _controller.text = formatDate(dt, AppCache.dateVnFormatArray);
        });
  }
}

class DocumentCreateStep2Page extends StatefulWidget {
  @override
  DocumentCreateStep2PageState createState() => DocumentCreateStep2PageState();
}
