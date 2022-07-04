import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onlineoffice_flutter/account/account_change_password.dart';
import 'package:onlineoffice_flutter/account/account_edit.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class AccountDetailPageState extends State<AccountDetailPage> {
  List<TitleValue> _listRecords;
  Account user;

  @override
  void initState() {
    super.initState();
  }

  setData() {
    this._listRecords = [];
    this.user = AppCache.getUserById(widget.accountId);
    this._listRecords.add(TitleValue('Họ và tên', user.fullName));
    this
        ._listRecords
        .add(TitleValue('Phòng ban', AppCache.getGroupNameById(user.groupId)));
    this._listRecords.add(TitleValue('Chức danh', user.roleName));
    if (user.birthDay.isNotEmpty)
      this._listRecords.add(TitleValue('Sinh nhật', user.birthDay));
    if (user.birthDay.isNotEmpty)
      this._listRecords.add(TitleValue('Email', user.email));
    if (user.birthDay.isNotEmpty)
      this._listRecords.add(TitleValue('Điện thoại', user.phone));
  }

  _setBodyForm() {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.0),
              child: Center(
                  child: CircleAvatar(
                      maxRadius: 100.0,
                      backgroundImage: NetworkImage(this.user.picture)))),
          getDetail()
        ]));
  }

  Widget getDetail() {
    return Expanded(
        child: this._listRecords == null
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: this._listRecords.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  TitleValue record = this._listRecords[index];
                  return ListTile(
                      title: Text(record.title),
                      trailing: getWidgetTrailing(record),
                      subtitle: Text(record.value,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey)));
                },
              ));
  }

  Widget getWidgetTrailing(TitleValue record) {
    if (record.title == 'Email') {
      return IconButton(
          icon: Icon(Icons.mail_outline, color: Colors.blue),
          onPressed: () => launch('mailto:${record.value}'));
    }
    if (record.title == 'Điện thoại') {
      return IconButton(
          icon: Icon(Icons.phone, color: Colors.green),
          onPressed: () => launch('tel:${record.value}'));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    setData();
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            title: Text('Thông tin cá nhân')),
        body: _setBodyForm(),
        persistentFooterButtons: widget.accountId != AppCache.currentUser.userId
            ? null
            : [
                RaisedButton.icon(
                    label: Text("Đổi mật khẩu",
                        style: TextStyle(color: Colors.white, fontSize: 14.0)),
                    color: Colors.redAccent,
                    elevation: 0.0,
                    icon: Icon(Icons.security, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountChangePasswordPage()),
                      );
                    }),
                RaisedButton.icon(
                    color: Colors.green,
                    elevation: 0.0,
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountEditPage()),
                      );
                    },
                    label: Text("Đổi thông tin",
                        style: TextStyle(color: Colors.white, fontSize: 14.0)))
              ]);
  }
}

class AccountDetailPage extends StatefulWidget {
  AccountDetailPage({this.accountId});

  final String accountId;

  @override
  State<StatefulWidget> createState() {
    return AccountDetailPageState();
  }
}
