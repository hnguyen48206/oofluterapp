import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/report_daily_model.dart';
import 'package:onlineoffice_flutter/report_daily/report_daily_detail.dart';
import 'package:onlineoffice_flutter/report_daily/report_daily_create.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReportDailyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReportDailyPageState();
  }
}

class ReportDailyPageState extends State<ReportDailyPage> {
  List<ReportDaily> _listRecords;
  bool _isChangeTextSearch = false;
  TextEditingController _textEditingController;
  RefreshController _refreshController;
  String _parentId = '';
  String _childrenId = '';
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
      setState(() {
        this._listRecords = null;
      });
    }
    FetchService.getListReportDaily(this._parentId, this._childrenId,
            this._textEditingController.text, 0)
        .then((List<ReportDaily> items) {
      if (items.length > 0) {
        if (this.mounted) {
          setState(() {
            this._listRecords = items;
          });
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
    FetchService.getListReportDaily(this._parentId, this._childrenId,
            this._textEditingController.text, this.minTick)
        .then((List<ReportDaily> items) {
      if (items.length > 0) {
        this.minTick = items.map((p) => p.tick).reduce(min);
        this._listRecords.addAll(items);
        if (this.mounted) {
          setState(() {});
        }
      }
    });
  }

  onSelectParentReport(String id) {
    this._parentId = id;
    this._childrenId = '';
    this.loadData();
    if (id.isEmpty) {
      return;
    }
    var childrenReport =
        AppCache.listChildrenReport.where((p) => p.parentId == id);
    if (childrenReport.length > 0) {
      var widgets =
          childrenReport.map<CupertinoActionSheetAction>((IdText val) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              this._childrenId = val.id;
              this.loadData();
            },
            child: Text(val.text));
      }).toList();
      AppHelpers.showActionSheet('Chọn mục báo cáo', widgets, context);
    }
  }

  _setLayoutForm() {
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
                        var widgets = AppCache.listParentReport
                            .map<CupertinoActionSheetAction>((IdText val) {
                          return CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onSelectParentReport(val.id);
                              },
                              child: Text(val.text));
                        }).toList();
                        AppHelpers.showActionSheet(
                            'Chọn loại báo cáo', widgets, context);
                      },
                      leading:
                          Icon(Icons.filter_alt_outlined, color: Colors.blue),
                      trailing: Icon(Icons.navigate_next, color: Colors.blue),
                      title: Text(
                          AppCache.getGroupReportName(
                              this._parentId, this._childrenId),
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
                        hintText: 'Tìm theo tiêu đề...',
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
                          child: Text('Chưa có báo cáo',
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

  Widget _buildItem(ReportDaily record) {
    return ListTile(
        onTap: () {
          AppCache.currentReportDaily = record;
          Navigator.push(
              this.context,
              MaterialPageRoute(
                  builder: (context) =>
                      ReportDailyDetailPage(isFromFormList: true)));
        },
        leading: CircleAvatar(
            backgroundImage:
                NetworkImage(AppCache.getAvatarUrl(record.creator))),
        title: Text(record.title,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: FittedBox(
            fit: BoxFit.fitWidth,
            clipBehavior: Clip.none,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getLineInfo(record))));
  }

  getLineInfo(ReportDaily record) {
    List<Widget> widgets = [];
    widgets.add(Text(
        '${AppCache.getFullNameById(record.creator)} (${record.getTimeInChat()})',
        style: TextStyle(fontSize: 12.0)));
    widgets.add(SizedBox(width: 5.0));
    widgets.add(Icon(Icons.remove_red_eye, color: Colors.teal));
    widgets
        .add(Text(' (${record.countView})', style: TextStyle(fontSize: 12.0)));
    return widgets;
  }

  onCreateReportDaily() {
    AppCache.currentReportDaily =
        ReportDaily(null, this._childrenId, this._parentId);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ReportDailyCreatePage()));
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
                title: Text('Báo Cáo Định Kỳ',
                    style: TextStyle(color: Colors.white))),
            body: this._listRecords == null
                ? Center(child: CircularProgressIndicator())
                : _setLayoutForm(),
            floatingActionButton: this._childrenId.isNotEmpty
                ? FloatingActionButton(
                    backgroundColor: Colors.teal,
                    onPressed: onCreateReportDaily,
                    child: Icon(Icons.add, color: Colors.white),
                  )
                : null));
  }
}
