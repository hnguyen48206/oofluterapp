import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/account/account_detail.dart';
import 'package:onlineoffice_flutter/account/account_list.dart';
import 'package:onlineoffice_flutter/announcement/announcement_list.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/weblink_viewer.dart';
import 'package:onlineoffice_flutter/authentication/login.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/library/library_list.dart';
import 'package:onlineoffice_flutter/main.dart';
import 'package:onlineoffice_flutter/report_daily/report_daily_list.dart';
import 'package:onlineoffice_flutter/signature/signature_list.dart';

class MenuPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MenuPageState();
  }
}

class MenuPageState extends State<MenuPage> {
  Widget getTabIcon(
      IndexBadgeApp enumBadgeApp, IconData iconData, Color colorIcon) {
    if (AppCache.badges[enumBadgeApp.index] == 0) {
      return Icon(iconData, color: colorIcon);
    }
    return Stack(children: <Widget>[
      Icon(iconData, color: colorIcon),
      Positioned(
          right: 0,
          child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                AppCache.badges[enumBadgeApp.index].toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )))
    ]);
  }

  getListWidget() {
    List<Widget> result = [];
    var isWebAvailable = true;
    for (var i = 0; i < AppCache.currentUser.modulesActive.length; i++) {
      // TO DO
      if (AppCache.currentUser.modulesActive[i]
          .toLowerCase()
          .contains('NOWEB'.toLowerCase())) isWebAvailable = false;
    }
    if (isWebAvailable)
      result.add(Card(
        child: ListTile(
            leading: Icon(Icons.web, color: Colors.blue),
            title: Text('Giao diện web'),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
            onTap: () {
              AppCache.webviewLastURL = FetchService.getLinkMobileLogin();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebLinkViewerPage(
                          title: "Giao diện web",
                          link: FetchService.getLinkMobileLogin())));
            }),
      ));
    if (AppCache.currentUser.modulesActive.contains('TrinhKy')) {
      result.add(Card(
        child: ListTile(
            leading: getTabIcon(
                IndexBadgeApp.Signature, Icons.edit_rounded, Colors.red),
            title: Text('Trình ký'),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignaturePage()));
            }),
      ));
    }
    if (AppCache.currentUser.modulesActive.contains('ThongBao')) {
      result.add(Card(
        child: ListTile(
            leading: getTabIcon(
                IndexBadgeApp.Announcement, Icons.volume_up, Colors.orange),
            title: Text('Thông báo'),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AnnouncementPage()));
            }),
      ));
    }
    if (AppCache.currentUser.modulesActive.contains('BaoCao')) {
      result.add(Card(
        child: ListTile(
            leading: getTabIcon(IndexBadgeApp.ReportDaily,
                Icons.stacked_bar_chart, Colors.black),
            title: Text('Báo cáo định kỳ'),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReportDailyPage()));
            }),
      ));
    }
    if (AppCache.currentUser.modulesActive.contains('ThuVien')) {
      result.add(Card(
        child: ListTile(
            leading: getTabIcon(
                IndexBadgeApp.Library, Icons.book_outlined, Colors.brown),
            title: Text('Thư viện'),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LibraryPage()));
            }),
      ));
    }
    result.add(Card(
      child: ListTile(
          leading: Icon(Icons.people, color: Colors.green),
          title: Text('Danh bạ'),
          trailing: Icon(Icons.navigate_next, color: Colors.black),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AccountListPage()));
          }),
    ));
    result.add(Card(
      child: ListTile(
          leading: Icon(Icons.person, color: Colors.blue),
          title: Text('Thông tin cá nhân'),
          trailing: Icon(Icons.navigate_next, color: Colors.black),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AccountDetailPage(
                        accountId: AppCache.currentUser.userId)));
          }),
    ));
    result.add(Card(
      child: ListTile(
          leading: Icon(Icons.reply_all, color: Colors.redAccent),
          title: Text('Đăng xuất'),
          trailing: Icon(Icons.navigate_next, color: Colors.black),
          onTap: () {
            appAuth.logout().then((prefs) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            });
          }),
    ));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: getListWidget());
  }
}
