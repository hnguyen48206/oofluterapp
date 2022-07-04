import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/account/account_detail.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class AccountListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountListPageState();
  }
}

class AccountListPageState extends State<AccountListPage> {
  List<Account> _listRecords;
  List<GroupUser> _allGroup;
  String _groupId = 'All';
  bool _isChangeTextSearch = false;
  TextEditingController _textEditingController;

  @override
  void initState() {
    this._listRecords = List<Account>.from(AppCache.allUser);
    this._allGroup = List<GroupUser>.from(AppCache.allGroupUser);
    this._allGroup.insert(
        0,
        GroupUser(
            groupId: 'All', groupName: 'Tất cả', children: [], listUser: []));
    this._textEditingController = TextEditingController(text: '');
    super.initState();
    this.loadData();
    this.loadCountLogin();
  }

  loadData() async {
    if (this._textEditingController.text.isEmpty) {
      setState(() {});
    } else {
      String text = this._textEditingController.text.toLowerCase();
      setState(() {
        this._listRecords = this
            ._listRecords
            .where((p) =>
                p.fullName.toLowerCase().contains(text) ||
                ObjectHelper.convertToUnSign(p.fullName.toLowerCase())
                    .contains(text))
            .toList();
      });
    }
  }

  loadCountLogin() {
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      for (var item in this._listRecords) {
        setLastLogin(item);
      }
    });
  }

  setLastLogin(Account user) async {
    FetchService.userGetLastLogin(user.userId).then((value) {
      setState(() {
        user.lastLogin = value;
      });
    });
  }

  onSelectGroupChildren(GroupUser group) {
    this._groupId = group.groupId;
    this._listRecords = group.listUser;
    this.loadData();
    if (group.children.length > 0) {
      var widgets =
          group.children.map<CupertinoActionSheetAction>((GroupUser val) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              this._groupId = val.groupId;
              this._listRecords = group.listUser;
              this.loadData();
            },
            child: Text(val.groupName));
      }).toList();
      AppHelpers.showActionSheet('Chọn Phòng Ban', widgets, context);
    }
  }

  _layoutForm() {
    return Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Center(
                  child: ListTile(
                      onTap: () {
                        var widgets = this
                            ._allGroup
                            .map<CupertinoActionSheetAction>((GroupUser val) {
                          return CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onSelectGroupChildren(val);
                              },
                              child: Text(val.groupName));
                        }).toList();
                        AppHelpers.showActionSheet(
                            'Chọn Phòng Ban', widgets, context);
                      },
                      leading:
                          Icon(Icons.filter_alt_outlined, color: Colors.blue),
                      trailing: Icon(Icons.navigate_next, color: Colors.blue),
                      title: Text(AppCache.getGroupNameById(this._groupId),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))))),
          Padding(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      color: Colors.grey[100]),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Tìm theo tên ...',
                        labelStyle: new TextStyle(color: Colors.white),
                        hintStyle: new TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        suffixIcon: this._textEditingController.text.isEmpty
                            ? null
                            : (this._isChangeTextSearch
                                ? IconButton(
                                    icon: Icon(Icons.send,
                                        color: Colors.blueAccent),
                                    onPressed: () {
                                      setState(() {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        this._isChangeTextSearch = false;
                                      });
                                      this.loadData();
                                    })
                                : IconButton(
                                    icon: Icon(Icons.close,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        this._isChangeTextSearch = false;
                                        this._textEditingController.text = '';
                                      });
                                      this.loadData();
                                    })),
                        icon: Padding(
                            padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                            child: Icon(Icons.search, color: Colors.grey))),
                    controller: this._textEditingController,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        if (this._isChangeTextSearch == false) {
                          setState(() {
                            this._isChangeTextSearch = true;
                          });
                        }
                      }
                    },
                    onSubmitted: (val) {
                      this._textEditingController.text = val;
                      this.loadData();
                    },
                  ))),
          this._listRecords == null
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : this._listRecords.length == 0
                  ? Expanded(
                      child: Center(
                          child: Text('Không tìm thấy',
                              style: TextStyle(fontSize: 20.0))))
                  : Expanded(
                      child: ListView.separated(
                          itemCount: this._listRecords.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.black),
                          itemBuilder: (BuildContext context, int index) {
                            return _buildItem(this._listRecords[index]);
                          }))
        ]));
  }

  Widget _buildItem(Account record) {
    return ListTile(
        onTap: () {
          Navigator.push(
              this.context,
              MaterialPageRoute(
                  builder: (context) =>
                      AccountDetailPage(accountId: record.userId)));
        },
        leading: CircleAvatar(
            backgroundImage:
                NetworkImage(AppCache.getAvatarUrl(record.userId))),
        subtitle: record.lastLogin.isNotEmpty
            ? FittedBox(child: Text(record.lastLogin), fit: BoxFit.fitWidth)
            : null,
        title: Text(record.fullName,
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
  }

  Future<bool> onBackClick() async {
    AppHelpers.navigatorToHome(context, IndexTabHome.More);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => onBackClick(),
        child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title:
                    new Text('Danh Bạ', style: TextStyle(color: Colors.white))),
            body: this._listRecords == null
                ? Center(child: CircularProgressIndicator())
                : _layoutForm()));
  }
}
