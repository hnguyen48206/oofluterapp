import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:onlineoffice_flutter/announcement/announcement_detail.dart';
import 'package:onlineoffice_flutter/calendar/calendar_detail.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_chat.dart';
import 'package:onlineoffice_flutter/document/document_detail.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/library/library_detail.dart';
import 'package:onlineoffice_flutter/main.dart';
import 'package:onlineoffice_flutter/models/announcement_model.dart';
import 'package:onlineoffice_flutter/models/discuss_work_model.dart';
import 'package:onlineoffice_flutter/models/document_model.dart';
import 'package:onlineoffice_flutter/models/library_model.dart';
import 'package:onlineoffice_flutter/models/work_project_model.dart';
import 'package:onlineoffice_flutter/models/report_daily_model.dart';
import 'package:onlineoffice_flutter/report_daily/report_daily_detail.dart';
import 'package:onlineoffice_flutter/work_project/work_project_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final Map<int, Widget> protocols = const <int, Widget>{
    0: Center(
      child: Text(
        "http",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    ),
    1: Text(
      'https',
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    )
  };

  int valHttpHttps = 1;
  String _username = '', _password = '', _url = '';
  TextEditingController _controllerUsername,
      _controllerPassword,
      _controllerUrl;

  @override
  initState() {
    this._controllerUsername = TextEditingController();
    this._controllerPassword = TextEditingController();
    this._controllerUrl = TextEditingController();
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      if (prefs != null) {
        this._username = prefs.getString('username') ?? "";
        this._password = prefs.getString('password') ?? "";
        this._url = prefs.getString('url') ?? "";
        if (this._url.isNotEmpty) {
          if (this._url.contains('://') == false) {
            this.valHttpHttps = prefs.getInt('https') ?? 1;
          } else {
            this.valHttpHttps = this._url.startsWith('https') ? 1 : 0;
          }
        }
        setState(() {
          this._controllerUsername.text = _username;
          this._controllerPassword.text = _password;
          this._controllerUrl.text = _url
              .replaceFirst('https://', '')
              .replaceFirst('http://', '')
              .replaceFirst('/api/api/', '')
              .replaceFirst('/appmobile/api/', '');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _switched() {
      return Container(
        height: 50,
        width: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18.0))),
        child: CupertinoSegmentedControl<int>(
          children: protocols,
          onValueChanged: (int val) {
            setState(() {
              this.valHttpHttps = val;
            });
          },
          groupValue: valHttpHttps,
        ),
      );
    }

    _getDetailLogin() {
      List<Widget> result = [];
      result.add(_switched());
      result.add(ListTile(
        title: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18.0)),
              color: Color.fromARGB(120, 157, 162, 170)),
          child: TextFormField(
            decoration: InputDecoration(
                hintText: 'demo.onlineoffice.vn',
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                    child: Icon(Icons.cloud_circle, color: Colors.white))),
            validator: (val) {
              String _text;
              val.length < 1 ? _text = 'Vui lòng nhập url' : _text = null;
              return _text;
            },
            onSaved: (val) {
              this._url = val.trim().toLowerCase();
              if (this._url.startsWith('http')) {
                if (this._url.startsWith('http://')) {
                  this.valHttpHttps = 0;
                  this._url = this._url.replaceFirst('http://', '');
                }
                if (this._url.startsWith('https://')) {
                  this.valHttpHttps = 1;
                  this._url = this._url.replaceFirst('https://', '');
                }
              }
            },
            obscureText: false,
            controller: this._controllerUrl,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
      result.add(ListTile(
        title: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18.0)),
              color: Color.fromARGB(120, 157, 162, 170)),
          child: TextFormField(
            decoration: InputDecoration(
                hintText: 'Tên đăng nhập',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                    child: Icon(Icons.people, color: Colors.white)),
                labelStyle: TextStyle(color: Colors.white)),
            validator: (val) {
              String _text;
              val.length < 1 ? _text = 'Vui lòng nhập tài khoản' : _text = null;
              return _text;
            },
            onSaved: (val) => _username = val.trim(),
            obscureText: false,
            keyboardType: TextInputType.text,
            controller: this._controllerUsername,
            autocorrect: false,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
      result.add(ListTile(
        title: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18.0)),
              color: Color.fromARGB(120, 157, 162, 170)),
          child: TextFormField(
            decoration: InputDecoration(
                hintText: "Mật khẩu",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                    child: Icon(Icons.lock_open, color: Colors.white)),
                labelStyle: TextStyle(color: Colors.white)),
            validator: (val) {
              return val.length < 1 ? 'Vui lòng nhập mật khẩu' : null;
            },
            onSaved: (val) => _password = val,
            obscureText: true,
            controller: this._controllerPassword,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
      result.add(SizedBox(height: 20));
      result.add(_widgetSubmit());
      result.add(SizedBox(
        height: 150.0,
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Image(
                image: AssetImage("images/logo_150.jpg"),
                fit: BoxFit.fitHeight)),
      ));
      return result;
    }

    _layoutFormLogin() {
      return Form(
        key: formKey,
        child: Column(
            // physics: FixedExtentScrollPhysics(),
            mainAxisSize: MainAxisSize.min,
            children: _getDetailLogin()),
      );
    }

    return WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
            backgroundColor: Colors.blueGrey[100],
            resizeToAvoidBottomInset: false,
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: Center(child: _layoutFormLogin())),
            bottomNavigationBar: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Text("Copyright © ONLINE OFFICE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 20.0)))));
  }

  bool isSubmitting = false;

  Widget _widgetSubmit() {
    return ListTile(
      title: this.isSubmitting
          ? Container(child: Center(child: CircularProgressIndicator()))
          : Container(
              child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                  primary: Colors.transparent //elevated btton background color
                  ),
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    submitForm();
                  }),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
            ),
    );
  }

  // openNextForm() async {
  //   if (AppCache.currentUser.isOldVersion) {
  //     if (AppCache.messageNotify == null) {
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => OldVersionPage()));
  //     } else {
  //       String module;
  //       String id;
  //       if (Platform.isAndroid == true) {
  //         module = AppCache.messageNotify['data']['module'];
  //         id = AppCache.messageNotify['data']['id'];
  //       } else {
  //         module = AppCache.messageNotify['module'];
  //         id = AppCache.messageNotify['id'];
  //       }
  //       AppCache.messageNotify = null;
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => OldVersionPage(module: module, id: id)));
  //     }
  //   } else {
  //     if (AppCache.messageNotify == null) {
  //       AppHelpers.navigatorToHome(context, IndexTabHome.Dashboard);
  //     } else {
  //       bool isOpenDetailFromNotify =
  //           await openDetailNewVersionFromNotify(AppCache.messageNotify);
  //       if (isOpenDetailFromNotify == false) {
  //         String module;
  //         String id;
  //         if (Platform.isAndroid == true) {
  //           module = AppCache.messageNotify['data']['module'];
  //           id = AppCache.messageNotify['data']['id'];
  //         } else {
  //           module = AppCache.messageNotify['module'];
  //           id = AppCache.messageNotify['id'];
  //         }
  //         String linkWeb =
  //             FetchService.getLinkMobileLogin() + "&L=" + module + "&I=" + id;
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => WebLinkViewerPage(
  //                     title: "Online Office", link: linkWeb)));
  //       }
  //     }
  //   }
  // }

  login(String username, String password) {
    setState(() {
      this.isSubmitting = true;
    });
    FlutterUdid.udid.then((imei) {
      appAuth
          .login(imei, Platform.isAndroid ? "A" : "I", username, password)
          .then((result) {
        if (result) {
          AppCache.imei = imei;
          AppHelpers.openNextForm(context);
        } else {
          AppHelpers.alertDialogClose(
              context, 'Lỗi đăng nhập', AppCache.currentUser.error, false);
        }
        setState(() {
          this.isSubmitting = false;
        });
      });
    });
  }

  submitForm() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      FetchService.linkService =
          (this.valHttpHttps == 1 ? "https://" : "http://") +
              this._url +
              "/api/api/";
      login(_username.toLowerCase(), _password);
    }
  }

  Future<bool> openDetailNewVersionFromNotify(
      Map<String, dynamic> message) async {
    String module =
        Platform.isAndroid ? message['data']['module'] : message['module'];
    if (module == 'TraoDoi') module = 'TraoDoiCV';
    if (AppCache.currentUser.modulesActive.contains(module) == false)
      return false;
    String id = Platform.isAndroid ? message['data']['id'] : message['id'];
    if (module == 'BaoCao') {
      AppCache.messageNotify = null;
      AppCache.currentReportDaily = ReportDaily(id, '', '');
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => ReportDailyDetailPage()));
      return true;
    }
    if (module == 'LichTuan') {
      Navigator.push(
        this.context,
        MaterialPageRoute(
            builder: (context) => CalendarDetailPage(lichTuanId: id)),
      );
      AppCache.messageNotify = null;
      return true;
    }
    if (module == 'TraoDoiCV') {
      AppCache.messageNotify = null;
      DiscussWork result = await FetchService.getDiscussWorkById(id);
      if (result != null) {
        AppCache.currentDiscussWork = result;
        Navigator.push(this.context,
            MaterialPageRoute(builder: (context) => DiscussWorkChatPage()));
        return true;
      }
      return false;
    }
    if (module == 'CongViec') {
      AppCache.messageNotify = null;
      WorkProject result = await FetchService.workProjectGetById(id);
      if (result != null) {
        AppCache.currentWorkProject = result;
        Navigator.push(this.context,
            MaterialPageRoute(builder: (context) => WorkProjectChatPage()));
        return true;
      }
      return false;
    }
    if (module == 'VanBan') {
      AppCache.messageNotify = null;
      AppCache.currentDocumentDetail = DocumentDetail(id);
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => DocumentDetailPage(kind: '')),
      );
      return true;
    }
    if (module == 'ThongBao') {
      AppCache.messageNotify = null;
      AppCache.currentAnnouncement = Announcement(id);
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => AnnouncementDetailPage()));
      return true;
    }
    if (module == 'ThuVien') {
      AppCache.messageNotify = null;
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => LibraryDetailPage(
                  library: Library(id), isFromFormList: false)));
      return true;
    }
    return false;
  }

  // void showAlertNotify(Map<String, dynamic> message) {
  //   String module =
  //       Platform.isAndroid ? message['data']['module'] : message['module'];
  //   String id = Platform.isAndroid ? message['data']['id'] : message['id'];

  //   showCupertinoModalPopup(
  //       context: context,
  //       builder: (context) {
  //         return CupertinoAlertDialog(
  //           title: Text("Thông báo"),
  //           content: Text(
  //               "\n${message["notification"]["title"]}\n\n${message["notification"]["body"]}"),
  //           actions: <Widget>[
  //             FlatButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text("Đóng", style: TextStyle(color: Colors.black))),
  //             FlatButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                   if (module == "LichTuan") {
  //                     Navigator.push(
  //                       this.context,
  //                       MaterialPageRoute(
  //                           builder: (context) =>
  //                               CalendarDetailPage(lichTuanId: id)),
  //                     );
  //                   }
  //                   if (module == "CongViec") {
  //                     FetchService.workProjectGetById(id).then((result) {
  //                       AppCache.currentWorkProject = result;
  //                       if (result != null) {
  //                         Navigator.push(
  //                             this.context,
  //                             MaterialPageRoute(
  //                                 builder: (context) => WorkProjectChatPage()));
  //                       }
  //                     });
  //                   }
  //                   if (module == "TraoDoi" || module == "TraoDoiCV") {
  //                     FetchService.getDiscussWorkById(id).then((result) {
  //                       AppCache.currentDiscussWork = result;
  //                       if (result != null) {
  //                         Navigator.push(
  //                             this.context,
  //                             MaterialPageRoute(
  //                                 builder: (context) => DiscussWorkChatPage()));
  //                       }
  //                     });
  //                   }
  //                   if (module == "VanBan") {
  //                     AppCache.currentDocumentDetail = DocumentDetail(id);
  //                     Navigator.push(
  //                       this.context,
  //                       MaterialPageRoute(
  //                           builder: (context) => DocumentDetailPage(kind: '')),
  //                     );
  //                   }
  //                 },
  //                 child: Text("Xem", style: TextStyle(color: Colors.green)))
  //           ],
  //         );
  //       });
  // }
}
