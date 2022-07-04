import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/work_project/work_project_chat.dart';
import 'package:onlineoffice_flutter/work_project/work_project_list.dart';

class WorkProjectInputResultState extends State<WorkProjectInputResultPage> {
  TextEditingController _noiDungController;

  @override
  initState() {
    this._noiDungController = TextEditingController();

    super.initState();
  }

  void onSubmitClick() {
    FetchService.workProjectInputResult(
            AppCache.currentWorkProject.id, _noiDungController.text, '')
        .then((bool result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text("Lưu kết quả công việc"),
                content: Text("THÀNH CÔNG !!!",
                    style: TextStyle(color: Colors.blueAccent)),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkProjectChatPage()));
                      },
                      child: Text("Đóng", style: TextStyle(color: Colors.black)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(context, 'Lưu kết quả công việc',
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
                'Nhập Kết Quả Công Việc',
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
                  "Kết quả: ",
                  style: new TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
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
                          borderSide: new BorderSide(color: Colors.blue))),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Vui lòng nhập kết quả';
                    }
                    return null;
                  },
                  onSaved: (val) => this._noiDungController.text = val)
            ]));
  }
}

class WorkProjectInputResultPage extends StatefulWidget {
  @override
  WorkProjectInputResultState createState() => WorkProjectInputResultState();
}
