import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/document/document_create_step5.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/find_user.dart';
import 'package:onlineoffice_flutter/helpers/group_user_list.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class DocumentCreateStep4PageState extends State<DocumentCreateStep4Page> {
  void onNextClick() {
    //if (AppCache.currentDocument.nguoiXuLy.isEmpty) {
    //  AppHelpers.alertDialogClose(context, 'Người chuyển xử lý',
    //      'Bạn phải chọn người chuyển xử lý.', false);
    //} else {
    Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => DocumentCreateStep5Page()));
    //}
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
                    AppHelpers.navigatorToHome(context, IndexTabHome.Document);
                  })
            ],
            title: new Center(
              child: new Text(
                'TẠO VĂN BẢN ĐẾN',
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
    widgets.add(getHeaderNguoiDuocXems());
    if (AppCache.currentDocument.nguoiDuocXems.length > 0) {
      widgets.add(Column(
          children:
              getWidgetsNguoiXem(AppCache.currentDocument.nguoiDuocXems)));
      widgets.add(getHeaderNguoiXuLy());
      if (AppCache.currentDocument.nguoiXuLy.isNotEmpty) {
        widgets.add(SizedBox(height: 5.0));
        var user = AppCache.getUserById(AppCache.currentDocument.nguoiXuLy);
        widgets.add(ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
            ),
            title: Text('Người chuyển xử lý'),
            subtitle: Text(user.fullName)));
      }
    }
    return widgets;
  }

  getHeaderNguoiXuLy() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Người chuyển xử lý",
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
                                  title: Text("Chọn người chuyển xử lý",
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
        AppCache.getUsersByIds(AppCache.currentDocument.nguoiDuocXems);
    for (var i = 0; i < users.length; i++) {
      result.add(CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              AppCache.currentDocument.nguoiXuLy = users[i].userId;
            });
          },
          child: Text(users[i].fullName)));
    }
    return result;
  }

  getHeaderNguoiDuocXems() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Danh sách người xem (${AppCache.currentDocument.nguoiDuocXems.length})",
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
                                          KindAction.DocumentNguoiDuocXem)));
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
                                          KindAction.DocumentNguoiDuocXem)));
                        })
                  ],
                ))
          ],
        ));
  }

  getWidgetsNguoiXem(List<String> nguoiDuocXems) {
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
                    if (AppCache.currentDocument.nguoiDuocXems
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentDocument.nguoiDuocXems
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

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.white, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Thời gian"),
    AppHelpers.getHeaderStep(Colors.white, "File VB"),
    AppHelpers.getHeaderStep(Colors.blue, "Người xem"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));
}

class DocumentCreateStep4Page extends StatefulWidget {
  @override
  DocumentCreateStep4PageState createState() => DocumentCreateStep4PageState();
}
