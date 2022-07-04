import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/find_user.dart';
import 'package:onlineoffice_flutter/helpers/group_user_list.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step3.dart';

class WorkProjectCreateStep2PageState
    extends State<WorkProjectCreateStep2Page> {
  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.white, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Người xử lý"),
    AppHelpers.getHeaderStep(Colors.white, "Người xem"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    if (AppCache.currentWorkProject.nguoiChinh.isEmpty) {
      AppHelpers.alertDialogClose(context, 'Người chịu trách nhiệm chính',
          'Bạn phải chọn người chịu trách nhiệm chính.', false);
    } else {
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => WorkProjectCreateStep3Page()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: getWidgetsForm()));
  }

  getWidgetsForm() {
    List<Widget> widgets = [];
    widgets.add(this._headerWidget);
    widgets.add(getHeaderNguoiXuLys());
    if (AppCache.currentWorkProject.nguoiXuLys.length > 0) {
      widgets.add(Column(
          children:
              getWidgetsNguoiXuLy(AppCache.currentWorkProject.nguoiXuLys)));
      widgets.add(getHeaderNguoiChiuTrachNhiemChinh());
      if (AppCache.currentWorkProject.nguoiChinh.isNotEmpty) {
        widgets.add(SizedBox(height: 5.0));
        var user = AppCache.getUserById(AppCache.currentWorkProject.nguoiChinh);
        widgets.add(ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
            ),
            title: Text('Người chịu trách nhiệm chính'),
            subtitle: Text(user.fullName)));
      }
    }
    return widgets;
  }

  getHeaderNguoiChiuTrachNhiemChinh() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Người chịu trách nhiệm chính",
                style: new TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: IconButton(
                      icon: Icon(Icons.person_add,
                          size: 40.0, color: Colors.green),
                      onPressed: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return CupertinoActionSheet(
                                  title: Text(
                                      "Chọn người chịu trách nhiệm chính",
                                      style: TextStyle(color: Colors.black)),
                                  cancelButton: CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Đóng")),
                                  actions: getSheetNguoiXuLys());
                            });
                      }))
            ]));
  }

  getSheetNguoiXuLys() {
    List<Widget> result = [];
    List<Account> users =
        AppCache.getUsersByIds(AppCache.currentWorkProject.nguoiXuLys);
    for (var i = 0; i < users.length; i++) {
      result.add(CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              AppCache.currentWorkProject.nguoiChinh = users[i].userId;
            });
          },
          child: Text(users[i].fullName)));
    }
    return result;
  }

  getHeaderNguoiXuLys() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Danh sách người xử lý (${AppCache.currentWorkProject.nguoiXuLys.length})",
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
                                          KindAction.WorkProjectNguoiXuLy)));
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
                                          KindAction.WorkProjectNguoiXuLy)));
                        })
                  ],
                ))
          ],
        ));
  }

  getWidgetsNguoiXuLy(List<String> userIds) {
    List<Widget> widgets = [];
    List<Account> users = AppCache.getUsersByIds(userIds);
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
                    if (AppCache.currentWorkProject.nguoiXuLys
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentWorkProject.nguoiXuLys
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

class WorkProjectCreateStep2Page extends StatefulWidget {
  @override
  WorkProjectCreateStep2PageState createState() =>
      WorkProjectCreateStep2PageState();
}
