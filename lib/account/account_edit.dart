import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class AccountEditPageState extends State<AccountEditPage> {
  Account user;
  final formKey = GlobalKey<FormState>();
  TextEditingController _birthdayController, _emailController, _phoneController;

  PickedFile imageAvatar;

  @override
  void initState() {
    this.user = AppCache.getUserById(AppCache.currentUser.userId);

    this._birthdayController = TextEditingController(text: user.birthDay);
    this._emailController = TextEditingController(text: user.email);
    this._phoneController = TextEditingController(text: user.phone);

    // this._listRecords = [];
    // this._listRecords.add(TitleValue('Họ và tên', user.fullName));
    // this
    //     ._listRecords
    //     .add(TitleValue('Phòng ban', AppCache.getGroupNameById(user.groupId)));
    // this._listRecords.add(TitleValue('Chức danh', user.roleName));

    // this._listRecords.add(TitleValue('Sinh nhật', user.birthDay));

    // this._listRecords.add(TitleValue('Email', user.email));
    // this._listRecords.add(TitleValue('Điện thoại', user.phone));
    super.initState();
  }

  attachFileOptions() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text("Upload hình đại diện",
                style: TextStyle(color: Colors.black)),
            message: Text("Chọn hành động"),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Đóng")),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageSource(ImageSource.gallery);
                  },
                  child: Text("Chọn từ thư viện ảnh")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    attachImageSource(ImageSource.camera);
                  },
                  child: Text("Chụp ảnh từ camera"))
            ],
          );
        });
  }

  attachImageSource(ImageSource imageSource) async {
    ImagePicker().getImage(source: imageSource).then((item) async {
      if (item == null) return;
      setState(() {
        this.imageAvatar = item;
      });
    });
  }

  _setBodyForm() {
    return Form(
        key: this.formKey,
        child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.0),
              child: Center(
                  child: CircleAvatar(
                backgroundImage: this.imageAvatar == null
                    ? NetworkImage(this.user.avatar)
                    : Image.file(File(this.imageAvatar.path)).image,
                maxRadius: 100.0,
              ))),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.0),
              child: Center(
                  child: GestureDetector(
                      child: Text("Thay đổi hình đại diện",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onTap: () {
                        attachFileOptions();
                      }))),
          ListTile(
            title: Text('Họ và tên',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(this.user.fullName),
          ),
          ListTile(
            title: Text('Phòng ban',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(AppCache.getGroupNameById(this.user.groupId)),
          ),
          ListTile(
            title: Text('Chức danh',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(this.user.roleName),
          ),
          ListTile(
            title: Text('Sinh nhật',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: DateTimeField(
                    format: AppCache.dateVnFormat,
                    initialValue: ObjectHelper.dateVnToDateTime(
                        this._birthdayController.text),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                    controller: this._birthdayController,
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
                      // if (val == null || val.isEmpty) {
                      //   return 'Vui lòng nhập tiêu đề';
                      // }
                      return null;
                    },
                    onSaved: (val) => {
                          if (this._birthdayController.text != '')
                            this._birthdayController.text =
                                formatDate(val, AppCache.dateVnFormatArray)
                        })),
          ),
          ListTile(
            title: Text('Email',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: TextFormField(
                    autocorrect: true,
                    keyboardType: TextInputType.emailAddress,
                    controller: this._emailController,
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
                      // if (val == null || val.isEmpty) {
                      //   return 'Vui lòng nhập tiêu đề';
                      // }
                      return null;
                    },
                    onSaved: (val) => this._emailController.text = val)),
          ),
          ListTile(
            title: Text('Điện thoại',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold)),
            subtitle: Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: TextFormField(
                    autocorrect: true,
                    keyboardType: TextInputType.phone,
                    controller: this._phoneController,
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
                      // if (val == null || val.isEmpty) {
                      //   return 'Vui lòng nhập tiêu đề';
                      // }
                      return null;
                    },
                    onSaved: (val) => this._phoneController.text = val)),
          )
        ]));
  }

  void onSubmit() {
    final form = formKey.currentState;
    if (form.validate() == true) {
      form.save();
      // this._birthdayController.text =
      //                   formatDate(val, AppCache.dateVnFormatArray)))
      String birth_day = '';
      if (this._birthdayController.text != '')
        birth_day = this._birthdayController.text;
      else {
        var now = new DateTime.now();
        birth_day = formatDate(now, AppCache.dateVnFormatArray);
      }
      FetchService.accountChangeInfo(
              birth_day, this._emailController.text, this._phoneController.text)
          .then((index) {
        if (index > 0) {
          if (this.imageAvatar != null) {
            String fileName = this.imageAvatar.path.split('/').last;
            FetchService.fileUpload(
                    'HinhUser',
                    AppCache.currentUser.userId + '/Thumbnail',
                    fileName,
                    File(this.imageAvatar.path))
                .then((value) {
              if (value) {
                AppCache.currentUser.avatar = FetchService.getDomainLink() +
                    '/Upload/HinhUser/' +
                    AppCache.currentUser.userId +
                    '/Thumbnail/' +
                    fileName;
                AppCache.allUser[index].avatar = AppCache.currentUser.avatar;
              }
            });
          }
          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Cập nhật thông tin cá nhân'),
                  content: Text('THÀNH CÔNG !!!',
                      style: TextStyle(color: Colors.blueAccent)),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child:
                            Text("OK", style: TextStyle(color: Colors.black)))
                  ],
                );
              });
        } else {
          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Lỗi hệ thống'),
                  content: Text(
                      'Cập nhật không thành công, xin vui lòng thử lại.',
                      style: TextStyle(color: Colors.blueAccent)),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
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
            backgroundColor: AppCache.colorApp,
            title: Text('Cập nhật thông tin cá nhân')),
        body: _setBodyForm(),
        persistentFooterButtons: [
          ElevatedButton.icon(
              label: Text("Hủy",
                  style: TextStyle(color: Colors.white, fontSize: 14.0)),
              style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent //elevated btton background color
                  ),
              icon: Icon(Icons.cancel, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              }),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.green //elevated btton background color
                  ),
              icon: Icon(Icons.save, color: Colors.black),
              onPressed: () {
                onSubmit();
              },
              label: Text("Lưu thông tin",
                  style: TextStyle(color: Colors.white, fontSize: 14.0)))
        ]);
  }
}

class AccountEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountEditPageState();
  }
}
