import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_create_step1.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_chat.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/discuss_work_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DiscussWorkPage extends StatefulWidget {
  static GlobalKey<DiscussWorkPageState> globalKey = GlobalKey();
  DiscussWorkPage({Key key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() {
    return DiscussWorkPageState();
  }
}

class DiscussWorkPageState extends State<DiscussWorkPage> {
  List<DiscussWork> _listRecords;

  bool _isChangeTextSearch = false;
  TextEditingController _textEditingController;
  RefreshController _refreshController;
  int minTick = 0;

  @override
  void initState() {
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
    FetchService.disscusWorkGetList(this._textEditingController.text, 0)
        .then((List<DiscussWork> items) {
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
    FetchService.disscusWorkGetList(
            this._textEditingController.text, this.minTick)
        .then((List<DiscussWork> items) {
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

  checkNewMessage(int index, String discussWorkId) async {
    FetchService.checkExistNewMessage(discussWorkId, 'TD', index)
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
          if (result.trim().length > 1) {
            List<String> arr = result.substring(1).split('!;!');
            this._listRecords[indexMessage].countMessage = arr[0];
            this._listRecords[indexMessage].subTitle = arr[1];
          }
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
                        hintText: 'T??m theo ch??? ?????...',
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
                          child: Text('Kh??ng c?? m???c trao ?????i n??o',
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

  Widget _buildItem(DiscussWork record) {
    return ListTile(
        onTap: () {
          if (record.hasNewMessage == true) {
            setState(() {
              record.hasNewMessage = false;
            });
          }
          AppCache.currentDiscussWork = record;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DiscussWorkChatPage(isFromFormList: true)));
        },
        title: Text(record.title,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FittedBox(
                  fit: BoxFit.fitWidth,
                  clipBehavior: Clip.none,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: getLineInfo(record))),
              Text(record.subTitle)
            ]));
  }

  getLineInfo(DiscussWork record) {
    List<Widget> widgets = [];
    widgets.add(Icon(Icons.people, color: Colors.blueGrey));
    widgets.add(Text('T???o b???i: ${AppCache.getFullNameById(record.creator)}'));
    widgets.add(SizedBox(width: 10.0));
    widgets.add(Icon(Icons.chat, color: Colors.grey));
    widgets.add(Text('(${record.countMessage})'));
    if (record.hasNewMessage) {
      widgets.add(SizedBox(width: 10.0));
      widgets.add(Image(
          image:
              NetworkImage('https://oo.onlineoffice.vn/Images/new_flash.gif')));
    }
    return widgets;
  }

  onCreateDiscussWork() {
    AppCache.currentDiscussWork = DiscussWork(null);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DiscussWorkCreateStep1Page()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: this._listRecords == null
            ? Center(child: CircularProgressIndicator())
            : _setBodyForm(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onCreateDiscussWork,
          child: Icon(Icons.add, color: Colors.white),
        ));
  }
}
