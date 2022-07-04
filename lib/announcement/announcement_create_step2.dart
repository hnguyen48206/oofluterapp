import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/announcement/announcement_create_step3.dart';
import 'package:onlineoffice_flutter/helpers/group_user_list.dart';
import 'package:onlineoffice_flutter/helpers/find_user.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class AnnouncementCreateStep2PageState
    extends State<AnnouncementCreateStep2Page> {
  Widget _headerWidget = Container(
      child: Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Được xem"),
    AppHelpers.getHeaderStep(Colors.white, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => AnnouncementCreateStep3Page()));
  }

  getWidgetTitle() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Danh sách được xem (${AppCache.currentAnnouncement.nguoiDuocXems.length})",
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
                                      kindAction: KindAction.Announcement)));
                        }),
                    new IconButton(
                        icon: Icon(Icons.playlist_add,
                            size: 40.0, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => GroupUserListPage(
                                      kindAction: KindAction.Announcement)));
                        })
                  ],
                ))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            actions: [
              IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => AppHelpers.announcementCancelAction(context))
            ],
            title: new Center(
              child: new Text(
                AppCache.currentAnnouncement.getTitleAction(),
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
            children: getListWidgetBody()));
  }

  getListWidgetBody() {
    List<Widget> results = [];
    results.add(this._headerWidget);
    results.add(ListTile(
        title: Text('Tất cả được xem',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        leading: Checkbox(
          value: AppCache.currentAnnouncement.isCheckAll(),
          tristate: true,
          activeColor: Colors.blue,
          checkColor: Colors.lightBlueAccent,
          onChanged: (val) {
            setState(() {
              AppCache.currentAnnouncement.chk = (val == true) ? '2' : '1';
            });
          },
        )));
    if (AppCache.currentAnnouncement.isCheckAll() == false) {
      results.add(getWidgetTitle());
      results.add(Column(
          children: getWidgetsNguoiDuocXem(
              AppCache.currentAnnouncement.nguoiDuocXems)));
    }
    return results;
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
            ),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    if (AppCache.currentAnnouncement.nguoiDuocXems
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentAnnouncement.nguoiDuocXems
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

class AnnouncementCreateStep2Page extends StatefulWidget {
  @override
  AnnouncementCreateStep2PageState createState() =>
      AnnouncementCreateStep2PageState();
}
