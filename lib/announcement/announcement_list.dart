import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/announcement/announcement_create_step1.dart';
import 'package:onlineoffice_flutter/announcement/announcement_detail.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/announcement_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AnnouncementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AnnouncementPageState();
  }
}

class AnnouncementPageState extends State<AnnouncementPage> {
  bool _isCreateNew = false;
  List<Announcement> _listRecords;
  bool _isChangeTextSearch = false;
  TextEditingController _textEditingController;
  RefreshController _refreshController;
  int minTick = 0;

  @override
  void initState() {
    this._isCreateNew =
        AppCache.listRole.where((i) => i.roleId == "ADM08").length > 0;
    this._textEditingController = TextEditingController();
    this._refreshController = RefreshController(initialRefresh: false);
    super.initState();
    this.loadData();
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    this._refreshController.refreshCompleted();
  }

  void _onLoading() async {
    loadOldData();
    await Future.delayed(Duration(milliseconds: 1000));
    this._refreshController.loadComplete();
  }

  loadData() async {
    if (this._listRecords != null) {
      this.minTick = 0;
      setState(() {
        this._listRecords = null;
      });
    }
    FetchService.announcementGetList(this._textEditingController.text, 0)
        .then((List<Announcement> items) {
      if (items.length > 0) {
        this.minTick = items.map((p) => p.tick).reduce(min);
        if (this.mounted) {
          setState(() {
            this._listRecords = items;
          });
          for (var i = 0; i < items.length; i++) {
            checkNewMessage(i, items[i].id);
          }
        }
      } else {
        if (this.mounted) {
          setState(() {
            this._listRecords = [];
          });
        }
      }
    });
  }

  loadOldData() async {
    FetchService.announcementGetList(
            this._textEditingController.text, this.minTick)
        .then((List<Announcement> items) {
      if (items.length > 0) {
        this.minTick = items.map((p) => p.tick).reduce(min);
        this._listRecords.addAll(items);
        if (this.mounted) {
          setState(() {});
        }
        int countNew = items.length;
        int startIndexNew = this._listRecords.length - countNew;
        for (var i = 0; i < countNew; i++) {
          checkNewMessage(startIndexNew + i, items[i].id);
        }
      }
    });
  }

  checkNewMessage(int index, String announcementId) async {
    FetchService.checkExistNewMessage(announcementId, 'TB', index)
        .then((List<Object> results) {
      if (results.length == 1) return;
      int indexMessage = results[0];
      String result = results[1].toString();
      if (this.mounted &&
          this._listRecords != null &&
          this._listRecords.length > indexMessage &&
          result.isNotEmpty) {
        setState(() {
          this._listRecords[indexMessage].hasNewMessage =
              result.startsWith('1');
          this._listRecords[indexMessage].countMessage = result.substring(1);
        });
      }
    });
  }

  _setBodyForm() {
    return Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      color: Colors.grey[100]),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Tìm theo chủ đề...',
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
                          child: Text('Không có thông báo',
                              style: TextStyle(fontSize: 20.0))))
                  : Expanded(
                      child: SmartRefresher(
                          enablePullDown: false,
                          enablePullUp: true,
                          controller: this._refreshController,
                          onRefresh: this._onRefresh,
                          onLoading: this._onLoading,
                          child: ListView.separated(
                              itemCount: this._listRecords.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(color: Colors.black),
                              itemBuilder: (BuildContext context, int index) {
                                return _buildItem(this._listRecords[index]);
                              })))
        ]));
  }

  Widget _buildItem(Announcement record) {
    return ListTile(
        onTap: () {
          if (record.hasNewMessage == true) {
            setState(() {
              record.hasNewMessage = false;
            });
          }
          AppCache.currentAnnouncement = record;
          Navigator.push(
              this.context,
              MaterialPageRoute(
                  builder: (context) =>
                      AnnouncementDetailPage(isFromFormList: true)));
        },
        title: Text(record.title,
            style: TextStyle(
                color: record.isUrgent() ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold)),
        subtitle: FittedBox(
            fit: BoxFit.fitWidth,
            clipBehavior: Clip.none,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getLineInfo(record))));
  }

  getLineInfo(Announcement record) {
    List<Widget> widgets = [];
    widgets.add(Icon(Icons.people, color: Colors.cyan));
    widgets.add(Text(
        '${AppCache.getFullNameById(record.creator)} (${record.ngayTao})'));
    widgets.add(SizedBox(width: 10.0));
    widgets.add(Icon(Icons.remove_red_eye, color: Colors.teal));
    widgets.add(Text(' (${record.countMessage})'));
    if (record.hasNewMessage) {
      widgets.add(SizedBox(width: 10.0));
      widgets.add(Image(
          image:
              NetworkImage('https://oo.onlineoffice.vn/Images/new_flash.gif')));
    }
    return widgets;
  }

  onCreateAnnouncement() {
    AppCache.currentAnnouncement = Announcement(null);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AnnouncementCreateStep1Page()));
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
                title: new Text('Thông Báo',
                    style: TextStyle(color: Colors.white))),
            body: this._listRecords == null
                ? Center(child: CircularProgressIndicator())
                : _setBodyForm(),
            floatingActionButton: this._isCreateNew
                ? FloatingActionButton(
                    backgroundColor: Colors.teal,
                    onPressed: onCreateAnnouncement,
                    child: Icon(Icons.add, color: Colors.white),
                  )
                : null));
  }
}
