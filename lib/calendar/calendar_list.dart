
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/calendar_week_model.dart';
import 'package:onlineoffice_flutter/calendar/calendar_create_step1.dart';
import 'package:onlineoffice_flutter/calendar/calendar_detail.dart';
import 'package:date_format/date_format.dart';

class CalendarPage extends StatefulWidget {
  static GlobalKey<CalendarPageState> globalKey = GlobalKey();
  CalendarPage({Key key}) : super(key: globalKey);
  
  @override
  State<StatefulWidget> createState() {
    return CalendarPageState();
  }
}

class CalendarPageState extends State<CalendarPage> {
  bool _isSignUp = false;
  bool _isApprove = false;
  List<CalendarDay> _calendars;
  int sharedValue = 0;

  Map<int, Widget> segmentButtons() {
    var result = Map<int, Widget>();
    result[0] = getSegmentButtons(' Hôm nay ');
    result[1] = getSegmentButtons(' Ngày mai ');
    result[2] = getSegmentButtons(' Đã duyệt ');
    result[3] = getSegmentButtons(' Chưa duyệt ');
    return result;
  }

  Widget getSegmentButtons(String textSegment) {
    Widget result =
        Text(textSegment, style: TextStyle(fontWeight: FontWeight.bold));
    return FittedBox(
        fit: BoxFit.fitHeight, clipBehavior: Clip.none, child: result);
  }

  @override
  void initState() {
    this._isSignUp =
        AppCache.listRole.where((i) => i.roleId == "ADM04").length > 0;
    this._isApprove =
        AppCache.listRole.where((i) => i.roleId == "ADM05").length > 0;
    super.initState();
    this.loadData();
  }

  loadData() async {
    if (this.sharedValue == 0) {
      this._loadToday();
      return;
    }
    var now = new DateTime.now();
    var date = formatDate(now, [mm, '/', dd, '/', yyyy]);

    if (this.sharedValue == 1) {
      var tomorrow = now.add(Duration(days: 1));
      var dateTomorrow = formatDate(tomorrow, [dd, '-', mm]);
      this._loadTomorrow(date, dateTomorrow);
      return;
    }
    if (this.sharedValue == 2) {
      this._loadLichTuan(date);
      return;
    }
    if (this.sharedValue == 3) {
      this._loadChuaDuyet(date);
      return;
    }
  }

  _loadLichTuan(String date) async {
    FetchService.lichTuan(date).then((List<CalendarDay> items) {
      if (this.mounted) {
        setState(() {
          this._calendars = items;
        });
      }
    });
  }

  _loadChuaDuyet(String date) async {
    FetchService.lichTuanChuaDuyet(date).then((List<CalendarDay> items) {
      if (this.mounted) {
        setState(() {
          this._calendars = items;
        });
      }
    });
  }

  _loadToday() async {
    FetchService.lichTuanHomNay().then((List<CalendarDay> items) {
      if (this.mounted) {
        setState(() {
          this._calendars = items;
        });
      }
    });
  }

  _loadTomorrow(String date, String dateTomorrow) async {
    if (AppCache.currentUser.modulesActive.contains('LichTuanNgayMai')) {
      FetchService.lichTuanNgayMai().then((List<CalendarDay> items) {
        if (this.mounted) {
          setState(() {
            this._calendars = items;
          });
        }
      });
    } else {
      FetchService.lichTuan(date).then((List<CalendarDay> items) {
        if (this.mounted) {
          setState(() {
            this._calendars = [];
            for (var item in items) {
              if (item.day == dateTomorrow) {
                this._calendars.add(item);
              }
            }
          });
        }
      });
    }
  }

  _setBodyForm() {
    return Container(
        color: Colors.grey[100],
        child: Column(children: <Widget>[
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.0),
              child: CupertinoSegmentedControl<int>(
                  children: segmentButtons(),
                  onValueChanged: (int val) {
                    setState(() {
                      this.sharedValue = val;
                      this._calendars = null;
                    });
                    this.loadData();
                  },
                  groupValue: sharedValue)),
          Expanded(
              child: this._calendars == null
                  ? Center(child: CircularProgressIndicator())
                  : this._calendars.length == 0
                      ? Center(
                          child: Text('Không có lịch',
                              style: TextStyle(fontSize: 25.0)))
                      : ListView.separated(
                          itemCount: this._calendars.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.black),
                          itemBuilder: (context, index) {
                            return _buildItem(this._calendars[index]);
                          }))
        ]));
  }

  onCreateCalendar() {
    AppCache.currentCalendar = LichTuan();
    Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => CalendarCreateStep1Page()));
  }

  // bool isSaigonCoopExporting = false;

  // onExportPDF() {
  //   setState(() {
  //     this.isSaigonCoopExporting = true;
  //   });
  //   FetchService.calendarSaigonCoopPDF().then((String linkPDF) {
  //     if (linkPDF != null) {
  //       try {
  //         Dio dio = Dio();
  //         var arrStr = linkPDF.split('?');
  //         getApplicationDocumentsDirectory().then((Directory dir) {
  //           FileAttachment file = FileAttachment.empty();
  //           file.url = FetchService.getDomainLink() + "/" + arrStr[0];
  //           file.fileName = arrStr[1];
  //           arrStr = file.url.split('/');
  //           file.localPath =
  //               "${dir.path}/LichTuan/" + arrStr[arrStr.length - 2];
  //           AppHelpers.createFolder(file.localPath).then((value) {
  //             file.localPath += "/${arrStr.last}";
  //             dio
  //                 .download(file.url, file.localPath,
  //                     onReceiveProgress: (rec, total) {})
  //                 .then((val) {
  //               setState(() {
  //                 this.isSaigonCoopExporting = false;
  //               });
  //               // AppHelpers.alertDialogClose(context, file.url, file.localPath, false);
  //               Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => PdfViewerPage(file: file)));
  //             });
  //           });
  //         });
  //       } catch (e) {
  //         setState(() {
  //           this.isSaigonCoopExporting = false;
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: _setBodyForm(),
        floatingActionButton: this._isSignUp
            ? FloatingActionButton(
                backgroundColor: Colors.teal,
                onPressed: onCreateCalendar,
                child: Icon(Icons.add, color: Colors.white),
              )
            : null,
        persistentFooterButtons: (this._calendars == null ||
                this._calendars.length == 0)
            ? null
            : this._calendars.any(
                    (p) => p.details.where((k) => k.checked == true).length > 0)
                ? [
                    ElevatedButton.icon(
                        label: Text("Phê duyệt",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.0)),
                         style: ElevatedButton.styleFrom(
                  primary: Colors.green //elevated btton background color
                  ),
                        icon: Icon(Icons.send, color: Colors.black),
                        onPressed: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text('Duyệt lịch tuần'),
                                  content: Text(
                                      'Bạn có chắc chắn muốn duyệt các lịch tuần này ?'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Không",
                                            style: TextStyle(
                                                color: Colors.black))),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _approve();
                                        },
                                        child: Text("Duyệt",
                                            style:
                                                TextStyle(color: Colors.blue)))
                                  ],
                                );
                              });
                        })
                  ]
                : null);
  }

  void _approve() async {
    var lichTuanIds = <String>[];
    for (var item in this._calendars) {
      for (var child in item.details) {
        if (child.checked == true) {
          lichTuanIds.add(child.id);
        }
      }
    }

    FetchService.approveCalendar(lichTuanIds.join('?')).then((result) {
      if (result) {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Duyệt lịch tuần'),
                content: Text('THÀNH CÔNG !!!'),
                actions: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          this._calendars = null;
                        });
                        this.loadData();
                      },
                      child: Text("OK", style: TextStyle(color: Colors.black)))
                ],
              );
            });
      } else {
        AppHelpers.alertDialogClose(
            context, 'Duyệt lịch tuần', 'KHÔNG THÀNH CÔNG.', false);
      }
    });
  }

  _getLayoutCalendarDayDetail(List<CalendarDetail> details) {
    List<Widget> result = [];
    for (int i = 0; i < details.length; i++) {
      result.add(_getLayoutCalendarDayDetailItem(details[i]));
    }
    return result;
  }

  List<Widget> getWidgetsDetailItem(CalendarDetail detail) {
    List<Widget> result = <Widget>[];
    result.add(Text(detail.title,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            decoration: detail.status == "2"
                ? TextDecoration.lineThrough
                : TextDecoration.none)));
    result.add(SizedBox(height: 10.0));
    result.add(Text('Chủ trì: ' + detail.mainPeople,
        style: TextStyle(
            color: Colors.red,
            decoration: detail.status == "2"
                ? TextDecoration.lineThrough
                : TextDecoration.none)));
    result.add(SizedBox(height: 3.0));
    result.add(Row(children: <Widget>[
      Icon(Icons.location_on, color: Colors.orange),
      Padding(padding: EdgeInsets.only(left: 5.0)),
      Expanded(
          child: Text(detail.address,
              style: TextStyle(
                  color: Colors.black54,
                  decoration: detail.status == "2"
                      ? TextDecoration.lineThrough
                      : TextDecoration.none)))
    ]));
    result.add(SizedBox(height: 3.0));
    result.add(Row(children: <Widget>[
      Icon(Icons.access_time, color: Colors.orange),
      Padding(padding: EdgeInsets.only(left: 5.0)),
      Text(detail.start + ' - ' + detail.end,
          style: TextStyle(
              color: Colors.green,
              fontStyle: FontStyle.italic,
              decoration: detail.status == "2"
                  ? TextDecoration.lineThrough
                  : TextDecoration.none))
    ]));
    if (this.sharedValue == 3 && this._isApprove == true) {
      result.add(ListTile(
          contentPadding: EdgeInsets.all(0.0),
          // title: Text("Duyệt"),
          title: Row(children: [
            Text("Duyệt lịch này  ", style: TextStyle(color: Colors.green)),
            CupertinoSwitch(
                value: detail.checked,
                onChanged: (val) {
                  setState(() {
                    detail.checked = val;
                  });
                })
          ])));
    }
    return result;
  }

  _getLayoutCalendarDayDetailItem(CalendarDetail detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[
            ListTile(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getWidgetsDetailItem(detail)),
                onTap: () {
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(
                        builder: (context) => CalendarDetailPage(
                            lichTuanId: detail.id, isFromFormList: true)),
                  );
                }),
          ],
        ),
      ),
    );
  }

  _getLayoutCalendarDay(CalendarDay calendar) {
    return ListTile(
      leading: (this.sharedValue == 0 || this.sharedValue == 1)
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: new Text(calendar.weekOfDay,
                      style: new TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold)),
                  decoration: new BoxDecoration(
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(30.0)),
                      color: Colors.orangeAccent),
                  padding: new EdgeInsets.all(8.0),
                ),
                SizedBox(height: 2.0),
                new Text(
                  calendar.day,
                  style: new TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.bold),
                )
              ],
            ),
      title: new Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getLayoutCalendarDayDetail(calendar.details)),
      ),
    );
  }

  Widget _buildItem(CalendarDay calendar) {
    return Column(children: <Widget>[
      _getLayoutCalendarDay(calendar),
      SizedBox(height: 10.0)
    ]);
  }
}
