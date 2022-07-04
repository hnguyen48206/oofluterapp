import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/calendar/calendar_create_step3.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';

class CalendarCreateStep2PageState extends State<CalendarCreateStep2Page> {
  TextEditingController _chuTriController,
      _thanhPhanController,
      _chuanBiController,
      _diaDiemController,
      _khachMoiController,
      _ghiChuController;

  Widget _headerWidget = Container(
      child: Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.blue, "Thành phần"),
    AppHelpers.getHeaderStep(Colors.white, "Phân công"),
    AppHelpers.getHeaderStep(Colors.white, "Xem lại"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  String _titleSave = '';

  void onNextClick() {
    AppCache.currentCalendar.chutri = this._chuTriController.text.trim();
    AppCache.currentCalendar.thanhphan = this._thanhPhanController.text.trim();
    AppCache.currentCalendar.chuanbi = this._chuanBiController.text.trim();
    AppCache.currentCalendar.diadiem = this._diaDiemController.text.trim();
    AppCache.currentCalendar.khachmoi = this._khachMoiController.text.trim();
    AppCache.currentCalendar.ghichu = this._ghiChuController.text.trim();
    Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => CalendarCreateStep3Page()));
  }

  @override
  initState() {
    this._titleSave = AppCache.currentCalendar.lichTuanId.isEmpty
        ? 'Đăng ký lịch tuần'
        : 'Chỉnh sửa lịch tuần';
    this._chuTriController =
        TextEditingController(text: AppCache.currentCalendar.chutri);
    this._thanhPhanController =
        TextEditingController(text: AppCache.currentCalendar.thanhphan);
    this._chuanBiController =
        TextEditingController(text: AppCache.currentCalendar.chuanbi);
    this._diaDiemController =
        TextEditingController(text: AppCache.currentCalendar.diadiem);
    this._khachMoiController =
        TextEditingController(text: AppCache.currentCalendar.khachmoi);
    this._ghiChuController =
        TextEditingController(text: AppCache.currentCalendar.ghichu);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            actions: [
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    AppHelpers.navigatorToHome(
                        context, IndexTabHome.CalendarWeek);
                  })
            ],
            title: Center(
              child: Text(
                this._titleSave,
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: ListView(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), children: <
            Widget>[
          this._headerWidget,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text("Chủ trì:",
                    style: TextStyle(color: Colors.blue, fontSize: 15.0)),
              ),
              TextFormField(
                autocorrect: true,
                controller: _chuTriController,
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text("Thành phần:",
                    style: TextStyle(color: Colors.blue, fontSize: 15.0)),
              ),
              TextFormField(
                autocorrect: true,
                controller: _thanhPhanController,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text("Chuẩn bị:",
                    style: TextStyle(color: Colors.blue, fontSize: 15.0)),
              ),
              TextFormField(
                autocorrect: true,
                controller: _chuanBiController,
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text("Địa điểm:",
                    style: TextStyle(color: Colors.blue, fontSize: 15.0)),
              ),
              TextFormField(
                autocorrect: true,
                controller: _diaDiemController,
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text("Khách mời:",
                    style: TextStyle(color: Colors.blue, fontSize: 15.0)),
              ),
              TextFormField(
                autocorrect: true,
                controller: _khachMoiController,
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text("Ghi chú:",
                    style: TextStyle(color: Colors.blue, fontSize: 15.0)),
              ),
              TextFormField(
                autocorrect: true,
                controller: _ghiChuController,
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
              )
            ],
          )
        ]));
  }
}

class CalendarCreateStep2Page extends StatefulWidget {
  @override
  CalendarCreateStep2PageState createState() => CalendarCreateStep2PageState();
}
