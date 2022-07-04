import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/library_model.dart';
import 'package:onlineoffice_flutter/library/library_detail.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LibraryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LibraryPageState();
  }
}

class LibraryPageState extends State<LibraryPage> {
  List<Library> _listRecords;
  List<IdText> _listFolders;
  IdText _currentFolder, _allFolder;
  bool _isChangeTextSearch = false;
  TextEditingController _textEditingController;
  RefreshController _refreshController;
  int minTick = 0;

  @override
  void initState() {
    this._allFolder = IdText('', 'Tất cả', '');
    this._currentFolder = this._allFolder;
    this._textEditingController = TextEditingController();
    this._refreshController = RefreshController(initialRefresh: false);
    super.initState();
    this.loadData(this._allFolder.id);
    this.loadFolders();
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    this._refreshController.refreshCompleted();
  }

  void _onLoading() async {
    this.loadOldData();
    await Future.delayed(Duration(milliseconds: 1000));
    this._refreshController.loadComplete();
  }

  loadData(String folderId) async {
    if (this._listRecords != null) {
      setState(() {
        this._listRecords = null;
      });
    }
    FetchService.libraryGetList(folderId, this._textEditingController.text, 0)
        .then((List<Library> items) {
      if (this.mounted) {
        setState(() {
          this._listRecords = items;
        });
        if (items.length > 0) {
          this.minTick = items.map((p) => p.tick).reduce(min);
        }
      }
    });
  }

  loadFolders() async {
    FetchService.libraryGetFolders().then((List<IdText> items) {
      if (this.mounted) {
        this._listFolders = items;
      }
    });
  }

  setActionSelectFolder(IdText folder, {bool isFirst = true}) {
    if (isFirst == false) {
      this._currentFolder = folder;
      this.loadData(folder.id);
      if (folder.id.isEmpty) {
        return null;
      }
    }
    var items =
        this._listFolders.where((i) => i.parentId == folder.id).toList();
    if (items.length == 0) {
      return null;
    } else if (isFirst == true) {
      items.insert(0, this._allFolder);
    }

    var widgets = items.map<CupertinoActionSheetAction>((IdText val) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            this.setActionSelectFolder(val, isFirst: false);
          },
          child: Text(val.text));
    }).toList();
    AppHelpers.showActionSheet('Chọn thư mục', widgets, context);
  }

  loadOldData() async {
    FetchService.libraryGetList(this._currentFolder.id,
            this._textEditingController.text, this.minTick)
        .then((List<Library> items) {
      if (items.length > 0) {
        this.minTick = items.map((p) => p.tick).reduce(min);
        this._listRecords.addAll(items);
        if (this.mounted) {
          setState(() {});
        }
      }
    });
  }

  _layoutListView() {
    if (this._listRecords == null)
      return Expanded(child: Center(child: CircularProgressIndicator()));
    if (this._listRecords.length == 0)
      return Expanded(
          child: Center(
              child:
                  Text('Không có dữ liệu', style: TextStyle(fontSize: 20.0))));
    return Expanded(
        child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            controller: this._refreshController,
            onRefresh: this._onRefresh,
            onLoading: this._onLoading,
            child: ListView.separated(
                itemCount: this._listRecords.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.black),
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(this._listRecords[index]);
                })));
  }

  Widget _buildItem(Library record) {
    return ListTile(
        onTap: () {
          Navigator.push(
              this.context,
              MaterialPageRoute(
                  builder: (context) => LibraryDetailPage(library: record)));
        },
        title: Row(children: getTitleRecord(record)),
        subtitle: FittedBox(
            fit: BoxFit.fitWidth,
            clipBehavior: Clip.none,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getLineInfo(record))));
  }

  getTitleRecord(Library record) {
    List<Widget> result = [];
    if (record.title.isNotEmpty) {
      result.add(Text(record.title,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)));
      result.add(Text(' - ',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
    }
    result.add(Flexible(
        child: new Container(
            child: Text(record.content,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal)))));
    return result;
  }

  getLineInfo(Library record) {
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

  Future<bool> onBackClick() async {
    AppHelpers.navigatorToHome(context, IndexTabHome.More);
    return false;
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
                        setActionSelectFolder(this._allFolder);
                      },
                      leading:
                          Icon(Icons.filter_alt_outlined, color: Colors.blue),
                      trailing: Icon(Icons.navigate_next, color: Colors.blue),
                      title: Text(this._currentFolder.text,
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
                        hintText: 'Tìm theo nội dung...',
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
                                      this.loadData(this._currentFolder.id);
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
                                      this.loadData(this._currentFolder.id);
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
                      this.loadData(this._currentFolder.id);
                    },
                  ))),
          _layoutListView()
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => onBackClick(),
        child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text('Thư Viện', style: TextStyle(color: Colors.white))),
            body: _layoutForm()));
  }
}
