import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_list.dart';
import 'package:onlineoffice_flutter/helpers/group_user_list.dart';
import 'package:onlineoffice_flutter/helpers/find_user.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_create_step3.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class DiscussWorkCreateStep2PageState
    extends State<DiscussWorkCreateStep2Page> {
  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Phân công"),
    AppHelpers.getHeaderStep(Colors.white, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DiscussWorkCreateStep3Page()));
  }

  void goBack() {
    AppHelpers.navigatorToHome(context, IndexTabHome.DiscussWork);
    DiscussWorkPage.globalKey.currentState.loadData();
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
              "Danh sách tham gia (${AppCache.currentDiscussWork.nguoiThamGias.length})",
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
                                      kindAction: KindAction.DiscussWork)));
                        }),
                    new IconButton(
                        icon: Icon(Icons.playlist_add,
                            size: 40.0, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => GroupUserListPage(
                                      kindAction: KindAction.DiscussWork)));
                        })
                  ],
                ))
          ],
        ));

    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            actions: [
              IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.black),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text(AppCache.currentDiscussWork.title),
                            content: Text("Bạn có chắc chắn muốn xoá ?"),
                            actions: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Không")),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    FetchService.deleteDiscussWork(
                                            AppCache.currentDiscussWork.id)
                                        .then((bool value) {
                                      if (value) {
                                        goBack();
                                      } else {
                                        AppHelpers.alertDialogClose(
                                            context,
                                            "Xoá trao đổi công việc",
                                            'KHÔNG THÀNH CÔNG, vui lòng thử lại !',
                                            false);
                                      }
                                    });
                                  },
                                  child: Text("Có"))
                            ],
                          );
                        });
                  })
            ],
            title: new Center(
              child: new Text(
                'TRAO ĐỔI CÔNG VIỆC',
                style: new TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: ListView(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            children: <Widget>[
              this._headerWidget,
              _widgetTitle,
              Column(
                  children: getWidgetsNguoiThamGia(
                      AppCache.currentDiscussWork.nguoiThamGias))
            ]));
  }

  getWidgetsNguoiThamGia(List<String> userIds) {
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
                    if (AppCache.currentDiscussWork.nguoiThamGias
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentDiscussWork.nguoiThamGias
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

class DiscussWorkCreateStep2Page extends StatefulWidget {
  @override
  DiscussWorkCreateStep2PageState createState() =>
      DiscussWorkCreateStep2PageState();
}
