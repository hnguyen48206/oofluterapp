import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/helpers/group_user_list.dart';
import 'package:onlineoffice_flutter/helpers/find_user.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/calendar/calendar_create_step4.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class CalendarCreateStep3PageState extends State<CalendarCreateStep3Page> {
  String _titleSave = '';
  Widget _headerWidget = Container(
      child: Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Thành phần"),
    AppHelpers.getHeaderStep(Colors.blue, "Phân công"),
    AppHelpers.getHeaderStep(Colors.white, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => CalendarCreateStep4Page()));
  }

  @override
  void initState() {
    this._titleSave = AppCache.currentCalendar.lichTuanId.isEmpty
        ? 'Đăng ký lịch tuần'
        : 'Chỉnh sửa lịch tuần';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _widgetTitle = Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Danh sách tham gia (${AppCache.currentCalendar.nguoiThamGias.length})",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.person_add,
                            size: 40.0, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => FindUserPage(
                                      kindAction: KindAction.WeekCalendar)));
                        }),
                    IconButton(
                        icon: Icon(Icons.playlist_add,
                            size: 40.0, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => GroupUserListPage(
                                      kindAction: KindAction.WeekCalendar)));
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
                  icon: Icon(Icons.home),
                  onPressed: () {
                    AppHelpers.navigatorToHome(
                        context, IndexTabHome.CalendarWeek);
                  })
            ],
            title: Center(
              child: Text(
                this._titleSave,
                style: TextStyle(fontSize: 18.0, color: Colors.white),
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
                      AppCache.currentCalendar.nguoiThamGias))
            ]));
  }

  getWidgetsNguoiThamGia(List<String> nguoiXuLys) {
    List<Widget> widgets = [];
    List<Account> users = AppCache.getUsersByIds(nguoiXuLys);
    for (var i = 0; i < users.length; i++) {
      widgets.add(Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
          decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(users[i].avatar),
            ),
            title: Text(
              users[i].fullName,
              style: TextStyle(color: Colors.blue),
            ),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    if (AppCache.currentCalendar.nguoiThamGias
                            .contains(users[i].userId) ==
                        true) {
                      AppCache.currentCalendar.nguoiThamGias
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

class CalendarCreateStep3Page extends StatefulWidget {
  @override
  CalendarCreateStep3PageState createState() => CalendarCreateStep3PageState();
}
