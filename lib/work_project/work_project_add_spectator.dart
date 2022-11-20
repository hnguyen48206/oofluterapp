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

class WorkProjectAddSpectatorPageState extends State<WorkProjectAddSpectator> {
  void onNextClick() {
    FetchService.workProjectAddSpectator().then((result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Thêm người xem'),
                content: Text('THÀNH CÔNG !!!',
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
        AppHelpers.alertDialogClose(context, 'Thêm người xem',
            'KHÔNG THÀNH CÔNG. Vui lòng thử lại,', false);
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
                'Thêm người xem',
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
    widgets.add(Text(
      "Danh sách người xem hiện tại (${AppCache.currentWorkProject.nguoiDuocXems.length})",
      style: new TextStyle(
          color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
    ));
    if (AppCache.currentWorkProject.nguoiDuocXems.length > 0) {
      widgets.add(Column(
          children:
              getWidgetsNguoiDuocXem(AppCache.currentWorkProject.nguoiDuocXems)));
    }
    widgets.add(getHeaderNguoiDuocXemsAdditional());
    if (AppCache.currentWorkProject.nguoiDuocXemsAdditional.length > 0) {
      widgets.add(Column(
          children: getWidgetsNguoiDuocXemAdditional(
              AppCache.currentWorkProject.nguoiDuocXemsAdditional)));
    }
    return widgets;
  }

  getHeaderNguoiDuocXemsAdditional() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Thêm người xem (${AppCache.currentWorkProject.nguoiDuocXemsAdditional.length})",
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
                                          .WorkProjectNguoiDuocXemAdditional)));
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
                                          .WorkProjectNguoiDuocXemAdditional)));
                        })
                  ],
                ))
          ],
        ));
  }

  getWidgetsNguoiDuocXem(List<String> userIds) {
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
              ))));
    }
    return widgets;
  }

  getWidgetsNguoiDuocXemAdditional(List<String> userIds) {
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
                    if (AppCache.currentWorkProject.nguoiDuocXemsAdditional
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentWorkProject.nguoiDuocXemsAdditional
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

class WorkProjectAddSpectator extends StatefulWidget {
  @override
  WorkProjectAddSpectatorPageState createState() =>
      WorkProjectAddSpectatorPageState();
}
