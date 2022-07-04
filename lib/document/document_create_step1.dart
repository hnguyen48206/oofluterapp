import 'dart:core';

import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/document/document_create_step2.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/find_project.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class DocumentCreateStep1PageState extends State<DocumentCreateStep1Page> {
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  TextEditingController _soThuTuController,
      _noiGuiController,
      _soVanBanController,
      _noiPhatHanhController,
      _nguoiKyController,
      _trichYeuController,
      _ghiChuController;

  Widget _headerWidget = new Container(
      child: new Row(children: <Widget>[
    AppHelpers.getHeaderStep(Colors.blue, "Nội dung"),
    AppHelpers.getHeaderStep(Colors.white, "Thời gian"),
    AppHelpers.getHeaderStep(Colors.white, "File VB"),
    AppHelpers.getHeaderStep(Colors.white, "Người xem"),
    AppHelpers.getHeaderStep(Colors.white, "Hoàn tất")
  ]));

  void onNextClick() {
    final form = formKey.currentState;
    if (form.validate() == true) {
      form.save();

      AppCache.currentDocument.soThuTu = this._soThuTuController.text;
      AppCache.currentDocument.noiGui = this._noiGuiController.text;
      AppCache.currentDocument.code = this._soVanBanController.text;
      AppCache.currentDocument.noiPhatHanh = this._noiPhatHanhController.text;
      AppCache.currentDocument.nguoiKy = this._nguoiKyController.text;
      AppCache.currentDocument.trichYeu = this._trichYeuController.text;
      AppCache.currentDocument.ghiChu = this._ghiChuController.text;

      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => DocumentCreateStep2Page()));
    }
  }

  @override
  initState() {
    this._soThuTuController =
        TextEditingController(text: AppCache.currentDocument.soThuTu);
    this._noiGuiController =
        TextEditingController(text: AppCache.currentDocument.noiGui);
    this._soVanBanController =
        TextEditingController(text: AppCache.currentDocument.code);
    this._noiPhatHanhController =
        TextEditingController(text: AppCache.currentDocument.noiPhatHanh);
    this._nguoiKyController =
        TextEditingController(text: AppCache.currentDocument.nguoiKy);
    this._trichYeuController =
        TextEditingController(text: AppCache.currentDocument.trichYeu);
    this._ghiChuController =
        TextEditingController(text: AppCache.currentDocument.ghiChu);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppCache.colorApp,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    AppHelpers.navigatorToHome(context, IndexTabHome.Document);
                  })
            ],
            title: Text(
              'TẠO VĂN BẢN ĐẾN',
              style: new TextStyle(fontSize: 18.0, color: Colors.white),
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: onNextClick,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
        body: this._isLoading
            ? Container(child: Center(child: CircularProgressIndicator()))
            : Form(
                key: this.formKey,
                child: ListView(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    children: <Widget>[
                      this._headerWidget,
                      CheckboxListTile(
                          title: Text('Khẩn',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.normal)),
                          value: AppCache.currentWorkProject.cvKhanCap,
                          // secondary: Icon(Icons.directions_run),
                          // selected: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() {
                              AppCache.currentWorkProject.cvKhanCap = val;
                            });
                          }),
                      getTitle('Số TT'),
                      getTextBox(this._soThuTuController, false, 1,
                          TextInputType.number),
                      SizedBox(height: 5.0),
                      getTitle('Lưu bản cứng'),
                      getSelectedList(
                          AppCache.currentDocument.luuHoSo.isEmpty
                              ? '-- Chọn phòng ban --'
                              : AppCache.getGroupNameById(
                                  AppCache.currentDocument.luuHoSo),
                          KindAction.DocumentLuuBanCung),
                      SizedBox(height: 5.0),
                      getTitle('Nơi gửi'),
                      getTextBox(
                          this._noiGuiController, false, 1, TextInputType.text),
                      SizedBox(height: 5.0),
                      getTitle('Số văn bản'),
                      getTextBox(this._soVanBanController, false, 1,
                          TextInputType.text),
                      SizedBox(height: 5.0),
                      getTitle('Thư mục'),
                      getSelectedList(
                          AppCache.currentDocument.loaiVanBan == 0
                              ? '-- Chọn thư mục --'
                              : AppCache.getCategoryNameById(
                                  AppCache.allDocumentDirectories,
                                  AppCache.currentDocument.loaiVanBan
                                      .toString()),
                          KindAction.DocumentDirectories),
                      SizedBox(height: 5.0),
                      getTitle('Nơi phát hành'),
                      getTextBox(this._noiPhatHanhController, false, 1,
                          TextInputType.text),
                      SizedBox(height: 5.0),
                      getTitle('Nguồn văn bản'),
                      getSelectedList(
                          AppCache.currentDocument.nguonVanBan == 0
                              ? '-- Chọn nguồn văn bản --'
                              : AppCache.getCategoryNameById(
                                  AppCache.allDocumentSource,
                                  AppCache.currentDocument.nguonVanBan
                                      .toString()),
                          KindAction.DocumentSource),
                      SizedBox(height: 5.0),
                      getTitle('Trích yếu'),
                      getTextBox(this._trichYeuController, false, 4,
                          TextInputType.text),
                      SizedBox(height: 5.0),
                      getTitle('Ghi chú'),
                      getTextBox(
                          this._ghiChuController, false, 4, TextInputType.text),
                      SizedBox(height: 80.0)
                    ])));
  }

  Widget getSelectedList(String name, KindAction kindAction) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
        child: ListTile(
            title: Text(name),
            trailing: IconButton(
                icon: Icon(Icons.fast_forward, color: Colors.green),
                onPressed: () {
                  this._soThuTuController.text =
                      AppCache.currentDocument.soThuTu;
                  this._noiGuiController.text = AppCache.currentDocument.noiGui;
                  this._soVanBanController.text = AppCache.currentDocument.code;
                  this._noiPhatHanhController.text =
                      AppCache.currentDocument.noiPhatHanh;
                  this._trichYeuController.text =
                      AppCache.currentDocument.trichYeu;
                  this._ghiChuController.text = AppCache.currentDocument.ghiChu;

                  switch (kindAction) {
                    case KindAction.DocumentLuuBanCung:
                      showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return CupertinoActionSheet(
                                title: Text("Chọn phòng ban",
                                    style: TextStyle(color: Colors.black)),
                                cancelButton: CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Đóng")),
                                actions: getSheetGroups());
                          });
                      break;
                    case KindAction.DocumentDirectories:
                      if (AppCache.allDocumentDirectories.length == 0) {
                        setState(() {
                          this._isLoading = true;
                        });
                        FetchService.documentGetDirectories().then((isOK) {
                          setState(() {
                            this._isLoading = false;
                          });
                          if (isOK) {
                            Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                    builder: (context) => FindCategoryPage(
                                        kindAction:
                                            KindAction.DocumentDirectories,
                                        listCategory:
                                            AppCache.allDocumentDirectories)));
                          }
                        });
                      } else
                        Navigator.push(
                            this.context,
                            MaterialPageRoute(
                                builder: (context) => FindCategoryPage(
                                    kindAction: KindAction.DocumentDirectories,
                                    listCategory:
                                        AppCache.allDocumentDirectories)));
                      break;
                    case KindAction.DocumentSource:
                      if (AppCache.allDocumentSource.length == 0) {
                        setState(() {
                          this._isLoading = true;
                        });
                        FetchService.documentGetSource().then((isOK) {
                          setState(() {
                            this._isLoading = false;
                          });
                          if (isOK) {
                            Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                    builder: (context) => FindCategoryPage(
                                        kindAction: KindAction.DocumentSource,
                                        listCategory:
                                            AppCache.allDocumentSource)));
                          }
                        });
                      } else
                        Navigator.push(
                            this.context,
                            MaterialPageRoute(
                                builder: (context) => FindCategoryPage(
                                    kindAction: KindAction.DocumentSource,
                                    listCategory: AppCache.allDocumentSource)));
                      break;
                    default:
                  }
                  // Navigator.push(
                  //     this.context,
                  //     MaterialPageRoute(
                  //         builder: (context) => FindProjectPage()));
                })));
  }

  getSheetGroups() {
    List<Widget> result = [];
    List<GroupUser> groups = AppCache.allGroupUser;
    for (var i = 0; i < groups.length; i++) {
      result.add(CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              AppCache.currentDocument.luuHoSo = groups[i].groupId;
            });
          },
          child: Text(groups[i].groupName)));
    }
    return result;
  }

  Widget getTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: new Text(
        title,
        style: new TextStyle(
            color: Colors.blue, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getTextBox(TextEditingController _controller, bool _autoCorrect,
      int _maxLines, TextInputType _inputType) {
    return TextFormField(
        autocorrect: _autoCorrect,
        maxLines: _maxLines,
        keyboardType: _inputType,
        controller: _controller,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(),
            ),
            contentPadding:
                new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.blue))),
        // validator: (val) {
        //   if (val == null || val.isEmpty) {
        //     return 'Vui lòng nhập tên công việc';
        //   }
        //   return null;
        // },
        onChanged: (val) {
          if (_controller == this._soThuTuController) {
            AppCache.currentDocument.soThuTu = val;
          }
          if (_controller == this._soVanBanController) {
            AppCache.currentDocument.code = val;
          }
          if (_controller == this._noiPhatHanhController) {
            AppCache.currentDocument.noiPhatHanh = val;
          }
          if (_controller == this._trichYeuController) {
            AppCache.currentDocument.trichYeu = val;
          }
          if (_controller == this._ghiChuController) {
            AppCache.currentDocument.ghiChu = val;
          }
        },
        onSaved: (val) => _controller.text = val);
  }
}

class DocumentCreateStep1Page extends StatefulWidget {
  @override
  DocumentCreateStep1PageState createState() => DocumentCreateStep1PageState();
}
