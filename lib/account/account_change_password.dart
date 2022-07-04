import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/main.dart';

class AccountChangePasswordPageState extends State<AccountChangePasswordPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _oldPassController,
      _newPassController,
      _newPassConfirmController;

  @override
  void initState() {
    this._oldPassController = TextEditingController();
    this._newPassController = TextEditingController();
    this._newPassConfirmController = TextEditingController();
    super.initState();
  }

  _setBodyForm() {
    return Form(
        key: this.formKey,
        child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
          ListTile(
            title: Text('Mật khẩu cũ',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: TextFormField(
                    autocorrect: true,
                    obscureText: true,
                    controller: this._oldPassController,
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blue))),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập mật khẩu cũ';
                      }
                      return null;
                    },
                    onSaved: (val) => this._oldPassController.text = val)),
          ),
          ListTile(
            title: Text('Mật khẩu mới',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: TextFormField(
                    autocorrect: true,
                    obscureText: true,
                    controller: this._newPassController,
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blue))),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      return null;
                    },
                    onSaved: (val) => this._newPassController.text = val)),
          ),
          ListTile(
            title: Text('Nhập lại mật khẩu mới',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: TextFormField(
                    autocorrect: true,
                    obscureText: true,
                    controller: this._newPassConfirmController,
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blue))),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu mới';
                      }
                      return null;
                    },
                    onSaved: (val) =>
                        this._newPassConfirmController.text = val)),
          )
        ]));
  }

  void onSubmit() {
    final form = formKey.currentState;
    if (form.validate() == true) {
      form.save();
      FetchService.accountChangePass(this._newPassController.text.trim())
          .then((value) {
        if (value) {
          appAuth.changePass(this._newPassController.text.trim());
          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Đổi mật khẩu'),
                  content: Text('THÀNH CÔNG !!!',
                      style: TextStyle(color: Colors.blueAccent)),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child:
                            Text("OK", style: TextStyle(color: Colors.black)))
                  ],
                );
              });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp, title: Text('Đổi mật khẩu')),
        body: _setBodyForm(),
        persistentFooterButtons: [
          RaisedButton.icon(
              label: Text("Hủy",
                  style: TextStyle(color: Colors.white, fontSize: 14.0)),
              color: Colors.redAccent,
              elevation: 0.0,
              icon: Icon(Icons.cancel, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              }),
          RaisedButton.icon(
              color: Colors.green,
              elevation: 0.0,
              icon: Icon(Icons.save, color: Colors.black),
              onPressed: () {
                onSubmit();
              },
              label: Text("Đổi mật khẩu",
                  style: TextStyle(color: Colors.white, fontSize: 14.0)))
        ]);
  }
}

class AccountChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountChangePasswordPageState();
  }
}
