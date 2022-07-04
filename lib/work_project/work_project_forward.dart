import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/helpers/find_user.dart';
import 'package:onlineoffice_flutter/helpers/group_user_list.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:onlineoffice_flutter/work_project/work_project_chat.dart';
import 'package:onlineoffice_flutter/work_project/work_project_list.dart';

class WorkProjectForwardState extends State<WorkProjectForwardPage> {
  TextEditingController _noiDungController;

  @override
  initState() {
    this._noiDungController = TextEditingController();

    super.initState();
  }

  void onSubmitClick() {
    FetchService.workProjectForward(
            AppCache.currentWorkProject.nguoiChuyenTieps,
            _noiDungController.text)
        .then((bool result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text("Chuyển tiếp công việc"),
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
                      child:
                          Text("Đóng", style: TextStyle(color: Colors.black)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(context, 'Chuyển tiếp công việc',
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
                    AppHelpers.navigatorToHome(
                        context, IndexTabHome.WorkProject);
                    WorkProjectPage.globalKey.currentState.loadData();
                  })
            ],
            title: new Center(
              child: new Text(
                'CHUYỂN TIẾP',
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
                  "Nội dung: ",
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
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                  onSaved: (val) => this._noiDungController.text = val),
              getLayoutMembers(),
              Column(children: getWidgetsMember())
            ]));
  }

  getLayoutMembers() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Người tiếp nhận (${AppCache.currentWorkProject.nguoiChuyenTieps.length})",
              style: new TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            new Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new IconButton(
                        icon: Icon(Icons.person_add,
                            size: 40.0, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => FindUserPage(
                                      kindAction: KindAction
                                          .WorkProjectNguoiChuyenTiep)));
                        }),
                    new IconButton(
                        icon: Icon(Icons.playlist_add,
                            size: 40.0, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => GroupUserListPage(
                                      kindAction: KindAction
                                          .WorkProjectNguoiChuyenTiep)));
                        })
                  ],
                ))
          ],
        ));
  }

  getWidgetsMember() {
    List<Widget> widgets = [];
    List<Account> users =
        AppCache.getUsersByIds(AppCache.currentWorkProject.nguoiChuyenTieps);
    for (var i = 0; i < users.length; i++) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
          decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
          child: new ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(users[i].avatar),
            ),
            title: new Text(
              users[i].fullName,
              style: new TextStyle(color: Colors.blue),
            ),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    if (AppCache.currentWorkProject.nguoiChuyenTieps
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentWorkProject.nguoiChuyenTieps
                          .remove(users[i].userId);
                    }
                  });
                },
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                )),
          )));
    }
    return widgets;
  }
}

class WorkProjectForwardPage extends StatefulWidget {
  @override
  WorkProjectForwardState createState() => WorkProjectForwardState();
}
