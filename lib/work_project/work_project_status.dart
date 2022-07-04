import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class WorkProjectStatusPageState extends State<WorkProjectStatusPage> {
  int sharedValue = 0;
  List<ViewerStatus> _records = [];

  final Map<int, Widget> segmentButtons = const <int, Widget>{
    0: Text('Chưa xử lý', style: TextStyle(fontWeight: FontWeight.bold)),
    2: Text('Đang xử lý', style: TextStyle(fontWeight: FontWeight.bold)),
    1: Text('Đã xử lý', style: TextStyle(fontWeight: FontWeight.bold))
  };

  @override
  void initState() {
    super.initState();
    this._loadData();
  }

  _loadData() async {
    FetchService.workProjectStatusGetList(this.sharedValue)
        .then((List<ViewerStatus> items) {
      if (this.mounted) {
        setState(() {
          this._records = items;
        });
      }
    });
  }

  _setBodyForm() {
    return Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.0),
              child: CupertinoSegmentedControl<int>(
                  children: segmentButtons,
                  onValueChanged: (int val) {
                    sharedValue = val;
                    this._loadData();
                  },
                  groupValue: sharedValue)),
          this._records.length == 0
              ? Center(child: Text('', style: TextStyle(fontSize: 20.0)))
              : Expanded(
                  child: ListView.separated(
                      itemCount: this._records.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        ViewerStatus record = this._records[index];
                        return ListTile(
                            title: Text(record.getFullName()),
                            subtitle: Text(
                                record.countView == 0
                                    ? 'Chưa xem lần nào'
                                    : 'Xem ${record.countView} lần, lần cuối: ${record.getTimeInChat()}',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey)));
                      }))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Tình trạng xử lý')), body: _setBodyForm());
  }
}

class WorkProjectStatusPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WorkProjectStatusPageState();
  }
}
