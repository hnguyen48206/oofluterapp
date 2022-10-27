import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/work_project_model.dart';
import 'package:onlineoffice_flutter/work_project/work_project_chat.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step1.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WorkProjectPageState extends State<WorkProjectPage> {
  bool _isCreateNew = false;
  List<WorkProject> _listRecords;
  bool _isChangeTextSearch = false;
  TextEditingController _textEditingController;
  RefreshController _refreshController;
  int minTick = 0;

  Map<int, int> countNewBySegment = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};

  final Map<int, String> segmentsTextFull = const <int, String>{
    1: ' Được giao ',
    2: ' Chuyển giao ',
    3: ' Được xem ',
    4: ' Đã kết thúc '
  };

  final Map<int, String> segmentsTextCount = const <int, String>{
    1: ' Đ.Giao',
    2: ' C.Giao',
    3: ' Đ.Xem',
    4: ' K.Thúc'
  };

  Map<int, Widget> getListSegmentButtons() {
    var result = Map<int, Widget>();
    result[1] = getSegmentButtons(1);
    result[2] = getSegmentButtons(2);
    result[3] = getSegmentButtons(3);
    result[4] = getSegmentButtons(4);
    return result;
  }

  Widget getSegmentButtons(int key) {
    Widget result;
    String textSegment = '';
    if (this.countNewBySegment[key] > 0) {
      textSegment = segmentsTextCount[key] + '     ';
      var widgets = <Widget>[];
      widgets.add(
          Text(textSegment, style: TextStyle(fontWeight: FontWeight.bold)));
      widgets.add(Positioned(
          right: 0,
          child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(6)),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(this.countNewBySegment[key].toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center))));
      result = Stack(children: widgets);
    } else {
      textSegment = segmentsTextFull[key];
      result = Text(textSegment, style: TextStyle(fontWeight: FontWeight.bold));
    }
    return FittedBox(
        fit: BoxFit.fitHeight, clipBehavior: Clip.none, child: result);
  }

  @override
  void initState() {
    this._isCreateNew =
        AppCache.listRole.where((i) => i.roleId == "ADM11").length > 0;
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
    FetchService.workProjectGetList(
            AppCache.tabIndexWorkList, this._textEditingController.text, 0)
        .then((List<WorkProject> items) {
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
    FetchService.workProjectGetList(AppCache.tabIndexWorkList,
            this._textEditingController.text, this.minTick)
        .then((List<WorkProject> items) {
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

  checkNewMessage(int index, String workProjectId) async {
    FetchService.checkExistNewMessage(workProjectId, 'CV', index)
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
            this._listRecords[indexMessage].content = arr[1];
          }
        });
      }
    });
  }

  setCountNew() async {
    FetchService.workProjectGetCountNew(countNewBySegment.values)
        .then((List<int> results) {
      if (this.mounted && results != null) {
        setState(() {
          this.countNewBySegment[1] = results[0];
          this.countNewBySegment[2] = results[1];
          this.countNewBySegment[3] = results[2];
          this.countNewBySegment[4] = results[3];
        });
      }
    });
  }

  _setBodyForm() {
    return Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: CupertinoSegmentedControl<int>(
                  children: this.getListSegmentButtons(),
                  onValueChanged: (int val) {
                    setState(() {
                      this._listRecords = null;
                    });
                    AppCache.tabIndexWorkList = val;
                    this.loadData();
                  },
                  groupValue: AppCache.tabIndexWorkList)),
          Padding(
              padding: EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 5.0),
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
                          child: Text('Chưa có công việc !',
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

  Widget _buildItem(WorkProject record) {
    return ListTile(
        onTap: () {
          setState(() {
            record.hasNewMessage = false;
          });
          FetchService.workProjectGetById(record.id).then((result) {
            if (result != null) {
              AppCache.currentWorkProject = result;
              Navigator.push(
                this.context,
                MaterialPageRoute(
                    builder: (context) =>
                        WorkProjectChatPage(isFromFormList: true)),
              );
            }
          });
        },
        title: Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image(image: NetworkImage(record.linkIcon)),
              SizedBox(width: 3.0),
              Flexible(
                  child: Text(record.title,
                      style: TextStyle(
                          color: ObjectHelper.getColorFromHex(record.hexColor),
                          fontWeight: FontWeight.bold)))
            ]),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FittedBox(
                  fit: BoxFit.fitWidth,
                  clipBehavior: Clip.none,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: getLineInfo(record))),
              Text('Thời hạn: ${record.ngayBatDau} - ${record.ngayKetThuc}',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.red)),
              Text(record.content)
            ]));
  }

  getLineInfo(WorkProject record) {
    List<Widget> widgets = [];
    widgets.add(Icon(Icons.people, color: Colors.blueGrey));
    widgets.add(Text('Tạo bởi: ${AppCache.getFullNameById(record.nguoiTao)}'));
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

  onCreateWorkProject() {
    AppCache.currentWorkProject = WorkProject(null);
    AppCache.isCreatedFromDocs = false;

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WorkProjectCreateStep1Page()));
  }

  @override
  Widget build(BuildContext context) {
    this.setCountNew();
    return Scaffold(
        appBar: null,
        body: this._listRecords == null
            ? Center(child: CircularProgressIndicator())
            : _setBodyForm(),
        floatingActionButton: this._isCreateNew
            ? FloatingActionButton(
                backgroundColor: Colors.teal,
                onPressed: onCreateWorkProject,
                child: Icon(Icons.add, color: Colors.white),
              )
            : null);
  }
}

class WorkProjectPage extends StatefulWidget {
  static GlobalKey<WorkProjectPageState> globalKey = GlobalKey();
  WorkProjectPage({Key key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() {
    return WorkProjectPageState();
  }
}
