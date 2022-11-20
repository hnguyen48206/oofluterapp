import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_create_step1.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_create_step3.dart';
import 'package:onlineoffice_flutter/helpers/image_viewer.dart';
import 'package:onlineoffice_flutter/helpers/triangle_chat_layout.dart';
import 'package:onlineoffice_flutter/models/discuss_work_model.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class DiscussWorkChatPageState extends State<DiscussWorkChatPage> {
  ScrollController _scrollController;

  TextEditingController textEditingController;
  TextEditingController textReplyController;

  ImageProvider<dynamic> _background;
  ImagePicker _imagePicker = ImagePicker();

  List<DiscussWorkMessage> listRecord;
  List<FileAttachment> files = <FileAttachment>[];
  Map<String, List<FileAttachment>> filesAttachment =
      Map<String, List<FileAttachment>>();
  bool enableButton = false;

  double maxWidthChat = 0;
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
          '${dir.path}/Background/TraoDoiCV/${AppCache.currentDiscussWork.id}';
      File(imgBackground).exists().then((isExist) {
        if (this.mounted && isExist) {
          setState(() {
            this._background = Image.file(File(imgBackground)).image;
          });
        }
      });
      this.modulePath =
          "${dir.path}/TraoDoiCV/${AppCache.currentDiscussWork.id}/";
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
    FetchService.disscusWorkGetListMessage(0)
        .then((List<DiscussWorkMessage> items) async {
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
        this.loadNewMessage(maxTick);
        if (this.mounted) {
          setState(() {});
        }
      });
    });
  }

  setDownloadImage(List<DiscussWorkMessage> items) async {
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
    FetchService.disscusWorkGetListMessage(this.minTick)
        .then((List<DiscussWorkMessage> items) async {
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
      List<DiscussWorkMessage> items =
          await FetchService.disscusWorkGetNewMessages(maxTick);
      if (items.length > 0) {
        List<DiscussWorkMessage> newItems =
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
    Future.delayed(Duration(milliseconds: 1000), () {
      this._scrollController.animateTo(
          (this._scrollController.position.maxScrollExtent ?? 0.0) + 100.0,
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

  _layoutItemFile(DiscussWorkMessage record) {
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

  _getLeftChat(DiscussWorkMessage record) {
    var messageBody = Container(
        constraints: BoxConstraints(maxWidth: this.maxWidthChat),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(5, 1, 0, 0),
                  child: Text(AppCache.getFullNameById(record.userId),
                      style: TextStyle(color: Colors.blue))),
              HtmlWidget(record.message, webView: true, webViewJs: false),
              Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
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

  getHtmlReply(DiscussWorkMessage record) {
    String html = AppCache.htmlReply
        .replaceFirst("{0}", AppCache.getFullNameById(record.userId));
    if (record.message.trim().startsWith('<'))
      html = html.replaceFirst("{1}", record.message);
    else
      html = html.replaceFirst("{1}", "<p>" + record.message + "</p>");
    return html;
  }

  void showReplyDialog(DiscussWorkMessage record) {
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
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Đóng", style: TextStyle(color: Colors.black))),
              ElevatedButton(
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
                      FetchService.discussWorkSendMessage('', text);
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Gửi", style: TextStyle(color: Colors.black)))
            ],
          );
        });
  }

  _getRightChat(DiscussWorkMessage record) {
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

  _getAvatar(DiscussWorkMessage record) {
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
      String path = "${dir.path}/Background/TraoDoiCV";
      await AppHelpers.createFolder(path);
      path += '/' + AppCache.currentDiscussWork.id;
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
    FetchService.discussWorkSendMessage('', '').then((messageId) async {
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
                "TraoDoiCV",
                AppCache.currentDiscussWork.id + '/' + messageId,
                file.fileName,
                file.bytes,
                0)
            .then((int value) {
          if (value > -1) {
            file.url = FetchService.getDomainLink() +
                '/Upload/TraoDoiCV/' +
                AppCache.currentDiscussWork.id +
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
      FetchService.discussWorkSendMessage('', '').then((messageId) async {
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
                    "TraoDoiCV",
                    AppCache.currentDiscussWork.id + '/' + messageId,
                    file.fileName,
                    file.bytes,
                    this.filesAttachment[messageId].length - 1)
                .then((int value) {
              if (value > -1) {
                file.url = FetchService.getDomainLink() +
                    '/Upload/TraoDoiCV/' +
                    AppCache.currentDiscussWork.id +
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
    FilePicker.getMultiFilePath().then((files) {
      if (files == null || files.entries.length == 0) return;
      FetchService.discussWorkSendMessage('', '').then((messageId) async {
        if (messageId != null) {
          this.filesAttachment[messageId] = <FileAttachment>[];
          for (var item in files.entries) {
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
                    "TraoDoiCV",
                    AppCache.currentDiscussWork.id + '/' + messageId,
                    item.key,
                    File(item.value))
                .then((bool value) {
              setState(() {
                file.url = FetchService.getDomainLink() +
                    '/Upload/TraoDoiCV/' +
                    AppCache.currentDiscussWork.id +
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
    var text = textEditingController.value.text.replaceAll('\n', '<br/>');
    textEditingController.clear();
    if (text.isNotEmpty) {
      FetchService.discussWorkSendMessage('', text);
    }
  }

  Future<bool> onBackClick() async {
    AppHelpers.navigatorToHome(context, IndexTabHome.DiscussWork);
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
                      icon: Icon(Icons.image),
                      onPressed: () {
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
                                            'Background/TraoDoiCV/${AppCache.currentDiscussWork.id}');
                                        setState(() {
                                          this._background =
                                              AppCache.backgroundChatDefault;
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
                                      child: Text("Chụp Ảnh",
                                          style: TextStyle(color: Colors.red)))
                                ],
                              );
                            });
                      }),
                  IconButton(
                      icon: Icon(Icons.remove_red_eye),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AppCache.currentDiscussWork.creator ==
                                        AppCache.currentUser.userId
                                    ? DiscussWorkCreateStep1Page()
                                    : DiscussWorkCreateStep3Page()));
                      })
                ],
                title: Text(
                  AppCache.currentDiscussWork.title ?? '',
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
}

class DiscussWorkChatPage extends StatefulWidget {
  DiscussWorkChatPage({this.isFromFormList = false});
  final bool isFromFormList;

  @override
  State<StatefulWidget> createState() {
    return DiscussWorkChatPageState();
  }
}
