import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/work_project/work_project_chat.dart';
import 'package:onlineoffice_flutter/work_project/work_project_list.dart';

class WorkProjectAdjournState extends State<WorkProjectAdjournPage> {
  TextEditingController _dateCompleteController;

  @override
  initState() {
    this._dateCompleteController = TextEditingController();

    super.initState();
  }

  void onSubmitClick() {
    FetchService.workProjectAdjourn(
            AppCache.currentWorkProject.id, _dateCompleteController.text)
        .then((bool result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text("Gia hạn công việc"),
                content: Text("THÀNH CÔNG !!!",
                    style: TextStyle(color: Colors.blueAccent)),
                actions: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkProjectChatPage()));
                      },
                      child:
                          Text("Đóng", style: TextStyle(color: Colors.black)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(context, 'Gia hạn công việc',
            'KHÔNG THÀNH CÔNG. Vui lòng thử lại.', false);
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
                    AppHelpers.navigatorToHome(context, IndexTabHome.WorkProject);
                    WorkProjectPage.globalKey.currentState.loadData();
                  })
            ],
            title: new Center(
              child: new Text(
                'Gia Hạn Công Việc',
                style: new TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onSubmitClick,
          child: Icon(Icons.send, color: Colors.white),
        ),
        body: new ListView(
            padding: new EdgeInsets.fromLTRB(10, 0, 10, 0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: new Text(
                  "Ngày gia hạn: ",
                  style: new TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              DateTimeField(
                  format: AppCache.dateVnFormat,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                  controller: this._dateCompleteController,
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      contentPadding: new EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.blue))),
                  validator: (val) {
                    return val == null ? 'Chọn ngày cần gia hạn' : null;
                  },
                  onSaved: (dt) => this._dateCompleteController.text =
                      formatDate(dt, AppCache.dateVnFormatArray))
            ]));
  }
}

class WorkProjectAdjournPage extends StatefulWidget {
  @override
  WorkProjectAdjournState createState() => WorkProjectAdjournState();
}
