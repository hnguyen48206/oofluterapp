import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/document/document_detail.dart';
import 'package:onlineoffice_flutter/helpers/image_viewer.dart';
import 'package:onlineoffice_flutter/helpers/triangle_chat_layout.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:onlineoffice_flutter/models/document_model.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:onlineoffice_flutter/models/work_project_model.dart';
import 'package:onlineoffice_flutter/work_project/work_project_add_implementer.dart';
import 'package:onlineoffice_flutter/work_project/work_project_add_spectator.dart';
import 'package:onlineoffice_flutter/work_project/work_project_adjourn.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step1.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step4.dart';
import 'package:onlineoffice_flutter/work_project/work_project_input_result.dart';
import 'package:onlineoffice_flutter/work_project/work_project_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/work_project/work_project_forward.dart';
import 'package:onlineoffice_flutter/work_project/work_project_status.dart';

class WorkProjectChatPageState extends State<WorkProjectChatPage> {
  ScrollController _scrollController;

  TextEditingController textEditingController;
  TextEditingController textReplyController;

  ImageProvider<dynamic> _background;
  ImagePicker _imagePicker = ImagePicker();

  List<WorkProjectMessage> listRecord;
  List<FileAttachment> files = <FileAttachment>[];
  Map<String, List<FileAttachment>> filesAttachment =
      Map<String, List<FileAttachment>>();
  bool enableButton = false;

  double maxWidthChat = 0.0;
  int minTick = 0;
  String modulePath;

  @override
  void initState() {
    this._background = AppCache.backgroundChatDefault;
    this.textEditingController = TextEditingController();
    this.textReplyController = TextEditingController();
    this._scrollController = ScrollController(initialScrollOffset: 9999999);
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      String imgBackground =
          '${dir.path}/Background/CongViec/${AppCache.currentWorkProject.id}';
      File(imgBackground).exists().then((isExist) {
        if (this.mounted && isExist) {
          setState(() {
            this._background = Image.file(File(imgBackground)).image;
          });
        }
      });
      this.modulePath =
          "${dir.path}/CongViec/${AppCache.currentWorkProject.id}/";
      this.loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    this.textEditingController.dispose();
    this.textReplyController.dispose();
    this._scrollController.dispose();
  }

  loadData() {
    FetchService.workProjectGetListMessage(0)
        .then((List<WorkProjectMessage> items) async {
      int maxTick = 0;
      if (items.length > 0) {
        maxTick = items.map((p) => p.tick).reduce(max);
        this.minTick = items.map((p) => p.tick).reduce(min);
      }
      if (this.mounted) {
        setState(() {
          this.listRecord = items;
        });
      }
      await setDownloadImage(items);
      this.listRecord = items;
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        loadNewMessage(maxTick);
        if (this.mounted) {
          setState(() {});
        }
      });
    });
  }

  setDownloadImage(List<WorkProjectMessage> items) async {
    for (var item in items) {
      String path = this.modulePath + item.id;
      for (FileAttachment file in item.files) {
        String localPath = path + "/${file.fileName}";
        File f = File(localPath);
        bool isExist = f.existsSync();
        if (isExist == true) {
          file.isDownloading = false;
          file.localPath = localPath;
          file.bytes = f.readAsBytesSync();
        } else if (AppCache.extsImage.contains(file.extension.toLowerCase())) {
          if (file.isLowSize()) {
            downloadFile(file, item.id, isOpen: false);
          }
        }
      }
    }
  }

  loadOldData() {
    FetchService.workProjectGetListMessage(this.minTick)
        .then((List<WorkProjectMessage> items) async {
      if (items.length > 0) {
        this.minTick = items.map((p) => p.tick).reduce(min);
        await setDownloadImage(items);
        this.listRecord.insertAll(0, items);
        if (this.mounted) {
          setState(() {});
          scrollMessageToFirst();
        }
      }
    });
  }

  loadNewMessage(int maxTick) {
    Future.delayed(Duration(seconds: 1)).then((value) async {
      List<WorkProjectMessage> items =
          await FetchService.workProjectGetNewMessage(maxTick);
      if (items.length > 0) {
        List<WorkProjectMessage> newItems =
            items.where((p) => !this.listRecord.contains(p)).toList();
        if (newItems.length > 0) {
          maxTick = newItems.map((p) => p.tick).reduce(max);
          for (var item in newItems) {
            if (this.filesAttachment.keys.contains(item.id)) {
              item.files = this.filesAttachment[item.id];
            }
          }
          await setDownloadImage(newItems);
          this.listRecord.addAll(newItems);
          if (this.mounted) {
            setState(() {});
            scrollMessageToEnd();
          }
        }
      }
      loadNewMessage(maxTick);
    });
  }

  void scrollMessageToEnd() {
    Future.delayed(Duration(milliseconds: 100), () {
      this._scrollController.animateTo(
          (this._scrollController.position.maxScrollExtent ?? 0.0) + 100,
          curve: Curves.easeOut,
          duration: Duration(milliseconds: 100));
    });
  }

  void scrollMessageToFirst() {
    Future.delayed(Duration(milliseconds: 1000), () {
      this._scrollController.animateTo(0,
          curve: Curves.easeOut, duration: Duration(milliseconds: 100));
    });
  }

  getTextInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(children: <Widget>[
        IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            icon: Icon(Icons.attach_file, size: 30),
            onPressed: attachFileOptions),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 1.0),
                child: TextField(
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 10,
                  onChanged: (text) {
                    setState(() {
                      enableButton = text.isNotEmpty;
                    });
                  },
                  onSubmitted: (text) {
                    this.textEditingController.text = text;
                    sendMessage();
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: "Nhập tin nhắn ...",
                  ),
                  controller: textEditingController,
                ))),
        enableButton
            ? IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.send,
                ),
                disabledColor: Colors.grey,
                onPressed: sendMessage,
              )
            : IconButton(
                color: Colors.blue,
                icon: Icon(
                  Icons.send,
                ),
                disabledColor: Colors.white,
                onPressed: null,
              )
      ]),
    );
  }

  _layoutForm() {
    return Column(children: <Widget>[
      Expanded(child: getRefreshIndicator()),
      Divider(height: 2.0),
      getTextInput()
    ]);
  }

  Widget getListView() {
    return ListView.separated(
        controller: this._scrollController,
        itemCount: this.listRecord.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: 2.0),
        itemBuilder: (BuildContext context, int index) {
          var record = this.listRecord[index];
          if (record.files.length == 0) {
            if (record.userId == AppCache.currentUser.userId)
              return _getRightChat(record);
            return _getLeftChat(record);
          } else {
            List<Widget> widgets = [];
            if (record.message.isEmpty) {
              widgets.addAll(_layoutItemFile(this.listRecord[index]));
            } else {
              widgets.add(record.userId == AppCache.currentUser.userId
                  ? _getRightChat(record)
                  : _getLeftChat(record));
              widgets.addAll(_layoutItemFile(this.listRecord[index]));
            }
            return Column(
                crossAxisAlignment: record.userId == AppCache.currentUser.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: widgets);
          }
        });
  }

  Future<void> _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    loadOldData();
  }

  Widget getRefreshIndicator() {
    if (this.listRecord[0].id == '0') return getListView();
    return RefreshIndicator(child: getListView(), onRefresh: _onLoading);
  }

  Future<void> downloadFile(FileAttachment file, String id,
      {bool isOpen = true}) async {
    try {
      file.localPath = this.modulePath + id + "/${file.fileName}";
      Dio dio = Dio();
      dio.get(file.url,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status < 500;
              }), onReceiveProgress: (rec, total) {
        file.isDownloading = true;
        String mbRec = (rec / 1048576).toStringAsFixed(1);
        String mbTotal = (total / 1048576).toStringAsFixed(1);
        file.progressing =
            "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
        if (this.mounted) {
          setState(() {});
        }
      }).then((response) {
        file.bytes = response.data;
        var f = File(file.localPath);
        f.createSync(recursive: true);
        f.writeAsBytesSync(response.data);
        dio.close();
        file.isDownloading = false;
        file.progressing = '';
        if (isOpen == true) {
          AppHelpers.openFile(file, this.context);
        } else {
          if (this.mounted) setState(() {});
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _layoutItemFile(WorkProjectMessage record) {
    List<Widget> _widgetFiles = <Widget>[];
    for (FileAttachment item in record.files) {
      if (item.isDownloading) {
        _widgetFiles.add(record.userId == AppCache.currentUser.userId
            ? getWidgetFileRight(item, record.id)
            : getWidgetFileLeft(item, record.id));
        continue;
      }
      if (AppCache.extsImage.contains(item.extension.toLowerCase()) &&
          (item.localPath.isNotEmpty ||
              item.bytes != null)) // check file is image
      {
        _widgetFiles.add(InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageViewerPage(file: item)));
            },
            child: Container(
                width: 200,
                height: 200,
                padding: EdgeInsets.all(0),
                margin: record.userId != AppCache.currentUser.userId
                    ? EdgeInsets.only(left: 50)
                    : EdgeInsets.only(right: 50),
                child: Image(
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                    image: (item.bytes != null
                            ? Image.memory(item.bytes)
                            : Image.file(File(item.localPath)))
                        .image))));
      } else {
        _widgetFiles.add(record.userId == AppCache.currentUser.userId
            ? getWidgetFileRight(item, record.id)
            : getWidgetFileLeft(item, record.id));
      }
    }
    return _widgetFiles;
  }

  getWidgetFileLeft(FileAttachment item, String messageId) {
    return InkWell(
        onTap: () {
          if (item.localPath.isEmpty) {
            this.downloadFile(item, messageId);
          } else {
            AppHelpers.openFile(item, this.context);
          }
        },
        child: Container(
            constraints: BoxConstraints(maxWidth: this.maxWidthChat),
            margin: EdgeInsets.only(left: 50, top: 5, bottom: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                color: Colors.grey[50],
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: item.isDownloading
                          ? CircularProgressIndicator()
                          : item.icon.isEmpty
                              ? Icon(Icons.attach_file,
                                  color: Colors.green, size: 24.0)
                              : Image(
                                  width: 24,
                                  height: 24,
                                  image: NetworkImage(item.icon))),
                  Flexible(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 10, right: 10),
                            child: Text(item.fileName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(color: Colors.black))),
                        Padding(
                            padding:
                                EdgeInsets.only(right: 10, top: 5, bottom: 10),
                            child: item.progressing.isEmpty
                                ? (item.size > 0
                                    ? Text(item.getTextSize(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(color: Colors.grey))
                                    : Text(''))
                                : Text(item.progressing,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(color: Colors.grey)))
                      ]))
                ])));
  }

  getWidgetFileRight(FileAttachment item, String messageId) {
    return InkWell(
        onTap: () {
          if (item.localPath.isEmpty) {
            this.downloadFile(item, messageId);
          } else {
            AppHelpers.openFile(item, this.context);
          }
        },
        child: Container(
            constraints: BoxConstraints(maxWidth: this.maxWidthChat),
            margin: EdgeInsets.only(right: 50, top: 5, bottom: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                color: Colors.grey[50],
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 10, left: 10),
                            child: Text(item.fileName,
                                style: TextStyle(color: Colors.black))),
                        Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 5, bottom: 10),
                            child: item.progressing.isEmpty
                                ? (item.size > 0
                                    ? Text(item.getTextSize(),
                                        style: TextStyle(color: Colors.grey))
                                    : Text(''))
                                : Text(item.progressing,
                                    style: TextStyle(color: Colors.grey)))
                      ])),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: item.isDownloading
                          ? CircularProgressIndicator()
                          : item.icon.isEmpty
                              ? Icon(Icons.attach_file,
                                  color: Colors.green, size: 24.0)
                              : Image(
                                  width: 24,
                                  height: 24,
                                  image: NetworkImage(item.icon)))
                ])));
  }

  _getLeftChat(WorkProjectMessage record) {
    var messageBody = Container(
        constraints: BoxConstraints(maxWidth: this.maxWidthChat),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 1.0, 0, 0),
                  child: Text(AppCache.getFullNameById(record.userId),
                      style: TextStyle(color: Colors.blue))),
              HtmlWidget(record.message, webView: true, webViewJs: false),
              Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                  child: Text(record.getTimeInChat(),
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)))
            ]));

    List<Widget> widgets = [];
    var message = GestureDetector(
        child: Stack(children: <Widget>[
          messageBody,
          Positioned(
              left: 0, bottom: 0, child: CustomPaint(painter: Triangle())),
        ]),
        onLongPress: () {
          showReplyDialog(record);
        });
    widgets.add(SizedBox(width: 5, height: 1));
    widgets.add(_getAvatar(record));
    widgets.add(SizedBox(width: 2, height: 1));
    widgets.add(Padding(padding: const EdgeInsets.all(6.0), child: message));
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widgets);
  }

  getHtmlReply(WorkProjectMessage record) {
    String html = AppCache.htmlReply
        .replaceFirst("{0}", AppCache.getFullNameById(record.userId));
    if (record.message.trim().startsWith('<'))
      html = html.replaceFirst("{1}", record.message);
    else
      html = html.replaceFirst("{1}", "<p>" + record.message + "</p>");
    return html;
  }

  void showReplyDialog(WorkProjectMessage record) {
    this.textReplyController.clear();
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Trả lời tin nhắn'),
            content: Column(children: [
              CupertinoTextField(
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 10,
                  onChanged: (text) {},
                  onSubmitted: (text) {
                    this.textReplyController.text = text;
                  },
                  controller: this.textReplyController),
              HtmlWidget(getHtmlReply(record), webView: true, webViewJs: false)
            ]),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Đóng", style: TextStyle(color: Colors.black))),
              FlatButton(
                  onPressed: () {
                    var text = this
                        .textReplyController
                        .value
                        .text
                        .replaceAll('\n', '<br/>');
                    this.textReplyController.clear();
                    if (text.isNotEmpty) {
                      text =
                          "<p><span style='font-family: Arial; font-size: 12pt;'>" +
                              text +
                              "</span></p>" +
                              getHtmlReply(record);
                      FetchService.workProjectSendMessage('', text);
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Gửi", style: TextStyle(color: Colors.black)))
            ],
          );
        });
  }

  _getRightChat(WorkProjectMessage record) {
    var messageBody = Container(
        constraints: BoxConstraints(maxWidth: this.maxWidthChat),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              HtmlWidget(record.message, webView: true, webViewJs: false),
              Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Text(record.getTimeInChat(),
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)))
            ]));

    List<Widget> widgets = [];
    var message = GestureDetector(
        child: Stack(children: <Widget>[
          messageBody,
          Positioned(
              right: 0, bottom: 0, child: CustomPaint(painter: Triangle())),
        ]),
        onTap: () {
          showReplyDialog(record);
        });
    widgets.add(Padding(padding: const EdgeInsets.all(6.0), child: message));
    widgets.add(SizedBox(width: 2, height: 1));
    widgets.add(_getAvatar(record));
    widgets.add(SizedBox(width: 5, height: 1));
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widgets);
  }

  _getAvatar(WorkProjectMessage record) {
    Account user = AppCache.getUserById(record.userId);
    if (user != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
      );
    }
    return CircleAvatar(backgroundColor: Colors.white);
  }

  changeBackground(ImageSource imageSource) async {
    this._imagePicker.getImage(source: imageSource).then((pickedImage) async {
      if (pickedImage == null) return;
      Directory dir = await getApplicationDocumentsDirectory();
      String path = "${dir.path}/Background/CongViec";
      await AppHelpers.createFolder(path);
      path += '/' + AppCache.currentWorkProject.id;
      await File(pickedImage.path).copy(path).then((file) {
        setState(() {
          this._background = Image.file(file).image;
        });
      });
    });
  }

  updateFileUpload(String messageId) {
    for (int i = this.listRecord.length - 1; i > 0; i--) {
      if (this.listRecord[i].id == messageId) {
        this.listRecord[i].files = this.filesAttachment[messageId];
        if (this.mounted) setState(() {});
        break;
      }
    }
  }

  attachImageVideo(bool isVideo, ImageSource fromSource) async {
    PickedFile pickedFile;
    if (isVideo) {
      pickedFile = await this._imagePicker.getVideo(source: fromSource);
    } else {
      pickedFile = await this._imagePicker.getImage(source: fromSource);
    }
    if (pickedFile == null) return;
    FetchService.workProjectSendMessage('', '').then((messageId) async {
      if (messageId != null) {
        this.filesAttachment[messageId] = <FileAttachment>[];
        FileAttachment file = FileAttachment.empty();
        file.fileName = pickedFile.path.split("/").last;
        file.mimeType = '';
        file.url = '';
        file.localPath = pickedFile.path;
        file.isDownloading = true;
        file.extension = file.fileName.split(".").last;
        file.progressing = 'Đang upload file ......';
        file.bytes = (await pickedFile.readAsBytes()).buffer.asUint8List();
        this.filesAttachment[messageId].add(file);
        this.updateFileUpload(messageId);
        await FetchService.fileUploadBytes(
                "CongViec",
                AppCache.currentWorkProject.id + '/' + messageId,
                file.fileName,
                file.bytes,
                0)
            .then((int value) {
          if (value > -1) {
            file.url = FetchService.getDomainLink() +
                '/Upload/CongViec/' +
                AppCache.currentWorkProject.id +
                '/' +
                messageId +
                '/' +
                file.fileName;
            file.isDownloading = false;
            file.progressing = '';
            this.updateFileUpload(messageId);
          }
        });
      }
    });
  }

  attachImages() async {
    MultiImagePicker.pickImages(
            maxImages: 50,
            enableCamera: true,
            cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"))
        .then((images) async {
      if (images == null || images.length == 0) return;
      FetchService.workProjectSendMessage('', '').then((messageId) async {
        if (messageId != null) {
          this.filesAttachment[messageId] = <FileAttachment>[];
          for (var image in images) {
            FileAttachment file = FileAttachment.empty();
            file.fileName = image.name;
            file.mimeType = '';
            file.url = '';
            file.localPath = '';
            file.isDownloading = true;
            file.extension = image.name.split(".").last;
            file.progressing = 'Đang upload file ......';
            file.bytes = (await image.getByteData()).buffer.asUint8List();
            this.filesAttachment[messageId].add(file);
            this.updateFileUpload(messageId);
            await FetchService.fileUploadBytes(
                    "CongViec",
                    AppCache.currentWorkProject.id + '/' + messageId,
                    file.fileName,
                    file.bytes,
                    this.filesAttachment[messageId].length - 1)
                .then((int value) {
              if (value > -1) {
                file.url = FetchService.getDomainLink() +
                    '/Upload/CongViec/' +
                    AppCache.currentWorkProject.id +
                    '/' +
                    messageId +
                    '/' +
                    file.fileName;
                file.isDownloading = false;
                file.progressing = '';
                this.updateFileUpload(messageId);
              }
            });
          }
        }
      });
    });
  }

  attachFileOptions() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              title: Text("Upload hình ảnh, video, files",
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
                      attachImages();
                    },
                    child: Text("Chọn nhiều ảnh từ Gallery")),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      attachImageVideo(true, ImageSource.gallery);
                    },
                    child: Text("Chọn video từ Gallery")),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      attachImageVideo(false, ImageSource.camera);
                    },
                    child: Text("Chụp ảnh từ Camera")),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      attachImageVideo(true, ImageSource.camera);
                    },
                    child: Text("Quay video từ Camera")),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      attachFiles();
                    },
                    child: Text("Chọn từ trình quản lý files",
                        style: TextStyle(color: Colors.red)))
              ]);
        });
  }

  attachFiles() async {
    FilePicker.getMultiFilePath().then((file) {
      if (file == null || file.entries.length == 0) return;
      FetchService.workProjectSendMessage('', '').then((messageId) async {
        if (messageId != null) {
          this.filesAttachment[messageId] = <FileAttachment>[];
          for (var item in file.entries) {
            FileAttachment file = FileAttachment.empty();
            file.fileName = item.key;
            file.mimeType = '';
            file.url = '';
            file.localPath = item.value;
            file.isDownloading = true;
            file.extension = file.fileName.split(".").last;
            file.progressing = 'Đang upload file ......';
            this.filesAttachment[messageId].add(file);
            this.updateFileUpload(messageId);
            await FetchService.fileUpload(
                    "CongViec",
                    AppCache.currentWorkProject.id + '/' + messageId,
                    item.key,
                    File(item.value))
                .then((bool value) {
              setState(() {
                file.url = FetchService.getDomainLink() +
                    '/Upload/CongViec/' +
                    AppCache.currentWorkProject.id +
                    '/' +
                    messageId +
                    '/' +
                    file.fileName;
                file.isDownloading = false;
                file.progressing = '';
                this.updateFileUpload(messageId);
              });
            });
          }
        }
      });
    });
  }

  sendMessage() {
    setState(() {
      enableButton = false;
    });
    var text = this.textEditingController.value.text.replaceAll('\n', '<br/>');
    this.textEditingController.clear();
    if (text.isNotEmpty) {
      FetchService.workProjectSendMessage('', text);
    }
  }

  Future<bool> onBackClick() async {
    if (widget.isFromFormList == true ||
        HomePage.globalKey.currentState != null) {
      Navigator.pop(context);
    } else {
      if (widget.formName == null) {
        AppHelpers.navigatorToHome(context, IndexTabHome.WorkProject);
      } else {
        switch (widget.formName) {
          case 'VBDE':
          case 'VBDI':
          case 'VBNO':
            AppCache.currentDocumentDetail = DocumentDetail(widget.objId);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DocumentDetailPage(kind: widget.formName)));
            break;
          default:
            AppHelpers.navigatorToHome(context, IndexTabHome.WorkProject);
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    this.maxWidthChat = MediaQuery.of(context).size.width * 0.8;

    return WillPopScope(
        onWillPop: () => onBackClick(),
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                backgroundColor: AppCache.colorApp,
                automaticallyImplyLeading: false,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => onBackClick()),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        FetchService.workProjectGetButtonActions()
                            .then((List<String> results) {
                          List<Widget> widgetsAction = [];
                          for (int i = 0; i < results.length; i++) {
                            widgetsAction.add(CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  performAction(results[i]);
                                },
                                child: Text(results[i])));
                          }
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return CupertinoActionSheet(
                                    title: Text("Chọn hành động",
                                        style: TextStyle(color: Colors.black)),
                                    // message: Text("Chọn hành động"),
                                    cancelButton: CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Đóng")),
                                    actions: widgetsAction);
                              });
                        });
                      })
                ],
                title: Text(
                  AppCache.currentWorkProject.title ?? '',
                  style: new TextStyle(fontSize: 16.0, color: Colors.white),
                )),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: this._background,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: this.listRecord == null
                        ? Center(
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.white))
                        : _layoutForm()))));
  }

  void performAction(String result) {
    switch (result) {
      case 'Tình trạng xử lý':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => WorkProjectStatusPage()));
        break;
      // case 'Xem đánh giá': break;
      case 'Chuyển giao':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => WorkProjectForwardPage()));
        break;
      case 'Thêm người xử lý':
        Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => WorkProjectAddImplementer()));
        break;
      case 'Thêm người xem':
        Navigator.push(this.context,
            MaterialPageRoute(builder: (context) => WorkProjectAddSpectator()));
        break;
      case 'Đánh dấu đã xử lý':
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text('Đánh dấu đã xử lý công việc'),
                  content: Text('Bạn có chắc chắn muốn thực hiện ?'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Không',
                            style: TextStyle(color: Colors.black))),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          FetchService.doneWorkProject().then((result) {
                            AppHelpers.alertDialogClose(
                                context,
                                'Đánh dấu đã xử lý công việc',
                                result
                                    ? 'THÀNH CÔNG !!!'
                                    : 'KHÔNG THÀNH CÔNG. Vui lòng thử lại.',
                                result);
                          });
                        },
                        child:
                            Text('Có', style: TextStyle(color: Colors.green)))
                  ]);
            });
        break;
      case 'Nhập kết quả':
        Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => WorkProjectInputResultPage()));
        break;
      case 'Đề xuất kết thúc':
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text('Đề xuất kết thúc công việc'),
                  content: Text('Bạn có chắc chắn muốn thực hiện ?'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Không',
                            style: TextStyle(color: Colors.black))),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          FetchService.proposeFinishWorkProject()
                              .then((result) {
                            AppHelpers.alertDialogClose(
                                context,
                                'Đề xuất kết thúc công việc',
                                result
                                    ? 'THÀNH CÔNG !!!'
                                    : 'KHÔNG THÀNH CÔNG. Vui lòng thử lại.',
                                result);
                          });
                        },
                        child:
                            Text('Có', style: TextStyle(color: Colors.green)))
                  ]);
            });
        break;
      case 'Kết thúc công việc':
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text('Kết thúc công việc'),
                  content: Text('Bạn có chắc chắn muốn thực hiện ?'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Không',
                            style: TextStyle(color: Colors.black))),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          FetchService.finishWorkProject().then((result) {
                            AppHelpers.alertDialogClose(
                                context,
                                'Kết thúc công việc',
                                result
                                    ? 'THÀNH CÔNG !!!'
                                    : 'KHÔNG THÀNH CÔNG. Vui lòng thử lại.',
                                result);
                          });
                        },
                        child:
                            Text('Có', style: TextStyle(color: Colors.green)))
                  ]);
            });
        break;
      case 'Xóa công việc':
        delete();
        break;
      case 'Không nhắc mới':
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text('Bỏ nhắc mới công việc'),
                  content: Text('Bạn có chắc chắn muốn thực hiện ?'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Không',
                            style: TextStyle(color: Colors.black))),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          FetchService.workProjectRemoveNewRemind()
                              .then((result) {
                            AppHelpers.alertDialogClose(
                                context,
                                'Bỏ nhắc mới công việc',
                                result
                                    ? 'THÀNH CÔNG !!!'
                                    : 'KHÔNG THÀNH CÔNG. Vui lòng thử lại.',
                                result);
                          });
                        },
                        child:
                            Text('Có', style: TextStyle(color: Colors.green)))
                  ]);
            });
        break;
      case 'Nhắc mới':
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                  title: Text('Nhắc mới công việc'),
                  content: Text('Bạn có chắc chắn muốn thực hiện ?'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Không',
                            style: TextStyle(color: Colors.black))),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          FetchService.workProjectRemindNew().then((result) {
                            AppHelpers.alertDialogClose(
                                context,
                                'Nhắc mới công việc',
                                result
                                    ? 'THÀNH CÔNG !!!'
                                    : 'KHÔNG THÀNH CÔNG. Vui lòng thử lại.',
                                result);
                          });
                        },
                        child:
                            Text('Có', style: TextStyle(color: Colors.green)))
                  ]);
            });

        break;
      case 'Tạo công việc con':
        WorkProject newWorkProject = WorkProject(null);
        newWorkProject.parentId = AppCache.currentWorkProject.id;
        newWorkProject.title = AppCache.currentWorkProject.title;
        newWorkProject.content = AppCache.currentWorkProject.content;
        newWorkProject.isEdited = 1;

        AppCache.currentWorkProject = newWorkProject;

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkProjectCreateStep1Page()));
        break;
      case 'Thay đổi người chịu trách nhiệm chính':
        AppCache.currentWorkProject.userXuLys =
            AppCache.getUsersByIds(AppCache.currentWorkProject.nguoiXuLys);
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                  title: Text("Thay đổi người chịu trách nhiệm chính",
                      style: TextStyle(color: Colors.black)),
                  cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Đóng")),
                  actions: getSheetNguoiXuLys());
            });
        break;
      case 'Gia hạn công việc':
        Navigator.push(this.context,
            MaterialPageRoute(builder: (context) => WorkProjectAdjournPage()));
        break;
      case 'Xem chi tiết':
        AppCache.currentWorkProject.isEdited = 0;
        AppCache.currentWorkProject.userXuLys =
            AppCache.getUsersByIds(AppCache.currentWorkProject.nguoiXuLys);
        AppCache.currentWorkProject.userDuocXems =
            AppCache.getUsersByIds(AppCache.currentWorkProject.nguoiDuocXems);

        if (AppCache.currentWorkProject.fileDinhKems != null &&
            AppCache.currentWorkProject.fileDinhKems.length > 0) {
          AppCache.currentWorkProject.files = AppCache
              .currentWorkProject.fileDinhKems
              .map((p) => FileAttachment(p))
              .toList();
        }
        Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => WorkProjectCreateStep4Page()));

        break;
      case 'Thay đổi hình nền':
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                title: Text("Thay đổi hình nền",
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
                        AppHelpers.deleteFile(
                            'Background/CongViec/${AppCache.currentWorkProject.id}');
                        setState(() {
                          this._background = AppCache.backgroundChatDefault;
                        });
                      },
                      child: Text("Sử dụng hình mặc định")),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                        changeBackground(ImageSource.gallery);
                      },
                      child: Text("Chọn hình nền")),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                        changeBackground(ImageSource.camera);
                      },
                      child:
                          Text("Chụp Ảnh", style: TextStyle(color: Colors.red)))
                ],
              );
            });
        break;
      default:
        AppHelpers.alertDialogClose(context, '// TODO', '', false);
        break;
    }
  }

  getSheetNguoiXuLys() {
    List<Widget> result = [];
    List<Account> users =
        AppCache.getUsersByIds(AppCache.currentWorkProject.nguoiXuLys);
    for (var i = 0; i < users.length; i++) {
      result.add(CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            AppCache.currentWorkProject.nguoiChinh = users[i].userId;
            FetchService.workProjectChangeMainPeople(users[i].userId)
                .then((result) {
              AppHelpers.alertDialogClose(
                  context,
                  'Thay đổi người chịu trách nhiệm chính',
                  result
                      ? 'THÀNH CÔNG !!!'
                      : 'KHÔNG THÀNH CÔNG. Vui lòng thử lại.',
                  result);
            });
          },
          child: Text(users[i].fullName)));
    }
    return result;
  }

  void delete() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
              title: Text(AppCache.currentWorkProject.title),
              content: Text('Bạn có chắc chắn muốn XÓA công việc này ?'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Không", style: TextStyle(color: Colors.blue))),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FetchService.deleteWorkProject().then((result) {
                        if (result == true) {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text('Xóa công việc'),
                                  content: Text('THÀNH CÔNG !!!'),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).popUntil(
                                              ModalRoute.withName("/HomePage"));
                                          HomePage.globalKey.currentState
                                              .setFromDashboard(
                                                  IndexTabHome.WorkProject);
                                          WorkProjectPage.globalKey.currentState
                                              .loadData();
                                        },
                                        child: Text("Đóng",
                                            style:
                                                TextStyle(color: Colors.blue)))
                                  ],
                                );
                              });
                        } else {
                          AppHelpers.alertDialogClose(context, 'Xóa công việc',
                              'KHÔNG THÀNH CÔNG. Vui lòng thử lại.', true);
                        }
                      });
                    },
                    child: Text("Xóa", style: TextStyle(color: Colors.red)))
              ]);
        });
  }
}

class WorkProjectChatPage extends StatefulWidget {
  WorkProjectChatPage({this.formName, this.objId, this.isFromFormList = false});

  final String formName;
  final String objId;
  final bool isFromFormList;

  @override
  State<StatefulWidget> createState() {
    return WorkProjectChatPageState();
  }
}
