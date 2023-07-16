import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:date_format/date_format.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/document/document_create_step1.dart';
import 'package:onlineoffice_flutter/document/document_detail.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/document_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:html_unescape/html_unescape.dart';

class DocumentPageState extends State<DocumentPage> {
  List<Document> _listRecords;
  bool _isChangeTextSearch = false;
  TextEditingController _textEditingController;
  RefreshController _refreshController;
  int minTick = 0;
  var unescape = HtmlUnescape();

  Map<String, int> countNewBySegment = <String, int>{
    'VBDE': 0,
    'VBDI': 0,
    'VBNO': 0
  };

  Map<String, Widget> getListSegmentButtons() {
    var result = Map<String, Widget>();
    result['VBDE'] = getSegmentButtons('VBDE', 'VB Đến');
    result['VBDI'] = getSegmentButtons('VBDI', 'VB Đi');
    result['VBNO'] = getSegmentButtons('VBNO', 'VB Nội Bộ');
    return result;
  }

  Widget getSegmentButtons(String key, String textSegment) {
    Widget result;
    if (this.countNewBySegment[key] > 0) {
      textSegment += '     ';
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
      result = Text(textSegment, style: TextStyle(fontWeight: FontWeight.bold));
    }
    return FittedBox(
        fit: BoxFit.fitHeight, clipBehavior: Clip.none, child: result);
  }

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
    FetchService.documentGetList(
            AppCache.tabIndexDocumentList, this._textEditingController.text, 0)
        .then((List<Document> items) {
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
    FetchService.documentGetList(AppCache.tabIndexDocumentList,
            this._textEditingController.text, this.minTick)
        .then((List<Document> items) {
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

  checkNewMessage(int index, String id) async {
    FetchService.checkExistNewMessage(id, 'VB', index)
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
        });
      }
    });
  }

  setCountNew() async {
    FetchService.getCountNewDocument(countNewBySegment)
        .then((List<int> results) {
      if (this.mounted && results != null) {
        setState(() {
          this.countNewBySegment['VBDE'] = results[0];
          this.countNewBySegment['VBDI'] = results[1];
          this.countNewBySegment['VBNO'] = results[2];
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
              child: CupertinoSegmentedControl<String>(
                  children: getListSegmentButtons(),
                  onValueChanged: (String val) {
                    setState(() {
                      this._listRecords = null;
                    });
                    AppCache.tabIndexDocumentList = val;
                    this.loadData();
                  },
                  groupValue: AppCache.tabIndexDocumentList)),
          Padding(
              padding: EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 5.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      color: Colors.grey[100]),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Tìm theo trích yếu ...',
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
                          child: Text('Chưa có văn bản !',
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

  Widget _buildItem(Document record) {
    return ListTile(
        onTap: () {
          AppCache.currentDocumentDetail = DocumentDetail(record.id);
          setState(() {
            record.hasNewMessage = false;
          });
          Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => DocumentDetailPage(
                    kind: AppCache.tabIndexDocumentList, isFromFormList: true)),
          );
        },
        title: Text(record.trichYeu,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getRowInfo(record)));
  }

  getRowInfo(Document record) {
    List<Widget> widgets = [];
    widgets.add(FittedBox(
        fit: BoxFit.fitWidth,
        clipBehavior: Clip.none,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: getLineInfo(record))));
    if (record.ngayGui.endsWith('1900') == false) {
      widgets.add(Text('Ngày phát hành: ${record.ngayGui}',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red)));
    }
    if (record.noiSoanThao.isNotEmpty && record.noiSoanThao != '0') {
      widgets.add(Text(
          'Nơi soạn thảo: ${AppCache.getGroupNameById(record.noiSoanThao)}',
          style: TextStyle(fontStyle: FontStyle.normal, color: Colors.black)));
    }
    if (record.noiNhan.isNotEmpty) {
      widgets.add(Text('Nơi nhận: ${unescape.convert(record.noiNhan)}',
          style: TextStyle(fontStyle: FontStyle.normal, color: Colors.black)));
    }
    return widgets;
  }

  getLineInfo(Document record) {
    List<Widget> widgets = [];
    widgets.add(Icon(Icons.people, color: Colors.blueGrey));
    widgets.add(Text('Tạo bởi: ${AppCache.getFullNameById(record.nguoiTao)}'));
    if (record.hasNewMessage) {
      widgets.add(SizedBox(width: 20.0));
      widgets.add(Image(
          image:
              NetworkImage('https://oo.onlineoffice.vn/Images/new_flash.gif')));
    }
    return widgets;
  }

  onAddDocument() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              title:
                  Text("Chọn hành động", style: TextStyle(color: Colors.black)),
              // message: Text("Chọn hành động"),
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Không tạo")),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      createNewDocument("VBDI");
                    },
                    child: Text("Tạo văn bản ĐI")),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      createNewDocument("VBDE");
                    },
                    child: Text("Tạo văn bản ĐẾN")),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      createNewDocument("VBNB");
                    },
                    child: Text("Tạo văn bản NỘI BỘ"))
              ]);
        });
  }

  createNewDocument(String kieuVB) {
    AppCache.currentDocument = Document(null);
    AppCache.currentDocument.luuHoSo = AppCache.currentUser.groupId;
    AppCache.currentDocument.kieuVB = kieuVB;
    String today = formatDate(DateTime.now(), AppCache.dateVnFormatArray);
    AppCache.currentDocument.ngayGui = today;
    AppCache.currentDocument.ngayNhan = today;
    AppCache.currentDocument.ngayKy = today;
    AppCache.currentDocument.thoiHanXuLy = today;
    FetchService.documentGetNewOrderNumber(kieuVB).then((value) {
      AppCache.currentDocument.soThuTu = value;
      if (kieuVB == "VBDE") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DocumentCreateStep1Page()));
      } else {
        AppHelpers.alertDialogClose(context, "TODO", "TODO", true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    this.setCountNew();
    return Scaffold(
        appBar: null,
        // floatingActionButton: FloatingActionButton(
        //     backgroundColor: Colors.teal,
        //     onPressed: onAddDocument,
        //     child: Icon(Icons.add, color: Colors.white)),
        body: this._listRecords == null
            ? Center(child: CircularProgressIndicator())
            : _setBodyForm());
  }
}

class DocumentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DocumentPageState();
  }
}
