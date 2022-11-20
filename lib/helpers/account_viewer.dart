import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/authentication/login.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/main.dart';

class AccountViewerPageState extends State<AccountViewerPage> {
  @override
  void initState() {
    super.initState();
  }

  getButtons() {
    List<Widget> widgets = <Widget>[];
    widgets.add(ElevatedButton.icon(
         style: ElevatedButton.styleFrom(
                  primary: Colors.green //elevated btton background color
                  ),
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          appAuth.logout().then((prefs) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        },
        label: Text("Đăng xuất",
            style: TextStyle(color: Colors.white, fontSize: 14.0))));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Tài khoản của bạn'),
            backgroundColor: AppCache.colorApp),
        persistentFooterButtons: getButtons(),
        body: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(AppCache.currentUser.avatar),
              ),
              ListTile(
                  leading: Text('Tên đăng nhập',
                      style: TextStyle(color: Colors.grey)),
                  title: Text(AppCache.currentUser.userName,
                      style: TextStyle(color: Colors.black))),
              ListTile(
                  leading: Text('Họ tên', style: TextStyle(color: Colors.grey)),
                  title: Text(AppCache.currentUser.fullName,
                      style: TextStyle(color: Colors.black))),
              ListTile(
                  leading:
                      Text('Vai trò', style: TextStyle(color: Colors.grey)),
                  title: Text(AppCache.currentUser.fullName,
                      style: TextStyle(color: Colors.black)))
            ]));
  }
}

class AccountViewerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountViewerPageState();
  }
}
