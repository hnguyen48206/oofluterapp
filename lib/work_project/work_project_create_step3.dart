import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/helpers/group_user_list.dart';
import 'package:onlineoffice_flutter/helpers/find_user.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step4.dart';

class WorkProjectCreateStep3PageState
    extends State<WorkProjectCreateStep3Page> {
  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.white, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Người xử lý"),
    AppHelpers.getHeaderStep(Colors.blue, "Người xem"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => WorkProjectCreateStep4Page()));
  }

  @override
  Widget build(BuildContext context) {
    Widget _widgetTitle = new Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Danh sách được xem (${AppCache.currentWorkProject.nguoiDuocXems.length})",
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
                                      kindAction:
                                          KindAction.WorkProjectNguoiDuocXem)));
                        }),
                    new IconButton(
                        icon: Icon(Icons.playlist_add,
                            size: 40.0, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => GroupUserListPage(
                                      kindAction:
                                          KindAction.WorkProjectNguoiDuocXem)));
                        })
                  ],
                ))
          ],
        ));

    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            title: new Center(
              child: new Text(
                'TẠO CÔNG VIỆC',
                style: new TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: new ListView(
            padding: new EdgeInsets.fromLTRB(10, 0, 10, 0),
            children: <Widget>[
              this._headerWidget,
              _widgetTitle,
              Column(
                  children: getWidgetsNguoiThamGia(
                      AppCache.currentWorkProject.nguoiDuocXems))
            ]));
  }

  getWidgetsNguoiThamGia(List<String> nguoiDuocXems) {
    List<Widget> widgets = [];
    List<Account> users = AppCache.getUsersByIds(nguoiDuocXems);
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
                    if (AppCache.currentWorkProject.nguoiDuocXems
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentWorkProject.nguoiDuocXems
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

class WorkProjectCreateStep3Page extends StatefulWidget {
  @override
  WorkProjectCreateStep3PageState createState() =>
      WorkProjectCreateStep3PageState();
}
