import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:onlineoffice_flutter/helpers/image_url_viewer.dart';
import 'package:onlineoffice_flutter/helpers/triangle_chat_layout.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onlineoffice_flutter/report_daily/report_daily_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/comment_model.dart';

class ReportDailyDetailPageState extends State<ReportDailyDetailPage> {
  int sharedValue = 0;

  final Map<int, Widget> segmentButtons = const <int, Widget>{
    0: Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold)),
    1: Text('Phản hồi', style: TextStyle(fontWeight: FontWeight.bold)),
    2: Text('Thành viên', style: TextStyle(fontWeight: FontWeight.bold))
  };

  ScrollController _scrollController;
  TextEditingController textEditingController;
  TextEditingController textReplyController;
  ImagePicker _imagePicker = ImagePicker();

  List<Comment> listComment = [];
  List<FileAttachment> files = <FileAttachment>[];
  Map<String, List<FileAttachment>> filesAttachment =
      Map<String, List<FileAttachment>>();

  bool enableButton = false;
  double maxWidthChat = 0;
  double maxWidthAttachFile = 0;

  @override
  void initState() {
    this.textEditingController = TextEditingController();
    this.textReplyController = TextEditingController();
    this._scrollController = ScrollController(initialScrollOffset: 9999999);
    super.initState();
    this._loadData();
  }

  _loadData() async {
    FetchService.reportDailyGetDetail().then((bool status) {
      if (status && this.mounted) {
        setState(() {
          if (AppCache.currentReportDaily.fileDinhKems != null &&
              AppCache.currentReportDaily.fileDinhKems.length > 0) {
            AppCache.currentReportDaily.files = AppCache
                .currentReportDaily.fileDinhKems
                .map((p) => FileAttachment(p))
                .toList();
          }
        });
        this._loadComment();
        FetchService.reportDailyGetViewerStatus(
                AppCache.currentReportDaily.childrenId)
            .then((bool status) {});
      }
    });
  }

  _loadComment() {
    FetchService.commentGetListMessage('BC', AppCache.currentReportDaily.id, 0)
        .then((List<Comment> items) {
      int maxTick = 0;
      if (items.length > 0) {
        maxTick = items.map((p) => p.tick).reduce(max);
      }
      Future.delayed(Duration(seconds: 1)).then((value) {
        if (this.mounted) {
          setState(() {});
          loadNewData(maxTick);
        }
      });
      this.listComment = items;
    });
  }

  loadNewData(int maxTick) {
    Future.delayed(Duration(seconds: 1)).then((value) async {
      List<Comment> items = await FetchService.commentGetListMessage(
          'BC', AppCache.currentReportDaily.id, maxTick);
      if (items.length > 0) {
        var newItems = items.where((p) => !this.listComment.contains(p));
        if (newItems.length > 0) {
          maxTick = newItems.map((p) => p.tick).reduce(max);
          for (var item in newItems) {
            if (this.filesAttachment.keys.contains(item.id)) {
              item.files = this.filesAttachment[item.id];
            }
          }
          this.listComment.addAll(newItems);
          if (this.mounted) {
            setState(() {});
            scrollMessageToEnd();
          }
        }
      }
      loadNewData(maxTick);
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

  _setBodyForm() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(5.0),
        child: Column(children: <Widget>[
          ListTile(
              title: Text(
                  AppCache.getGroupReportName(
                      AppCache.currentReportDaily.parentId,
                      AppCache.currentReportDaily.childrenId),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0))),
          ListTile(
              title: Text(AppCache.currentReportDaily.title,
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: 20.0))),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.0),
              child: CupertinoSegmentedControl<int>(
                  children: segmentButtons,
                  onValueChanged: (int val) {
                    setState(() {
                      this.sharedValue = val;
                    });
                  },
                  groupValue: this.sharedValue)),
          getDetail()
        ]));
  }

  Widget getDetail() {
    if (this.sharedValue == 0) {
      return Expanded(
          child: ListView.separated(
              itemCount: AppCache.currentReportDaily.files.length + 1,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SingleChildScrollView(
                      child: HtmlWidget(AppCache.currentReportDaily.content,
                          webView: true, webViewJs: false));
                }
                FileAttachment item =
                    AppCache.currentReportDaily.files[index - 1];
                return Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                    ),
                    child: ListTile(
                        leading: item.isDownloading
                            ? CircularProgressIndicator()
                            : null,
                        title: Text(
                          item.fileName,
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: item.progressing.isEmpty
                            ? null
                            : Text(item.progressing),
                        trailing: item.isDownloading
                            ? null
                            : IconButton(
                                icon: Icon(Icons.remove_red_eye,
                                    color: Colors.green),
                                onPressed: () {
                                  if (item.localPath.isEmpty) {
                                    this.downloadFile(item, "BaoCao",
                                        AppCache.currentReportDaily.id);
                                  } else {
                                    AppHelpers.openFile(item, this.context);
                                  }
                                })));
              }));
    }
    if (this.sharedValue == 1) {
      return getLayoutComments();
    }
    if (this.sharedValue == 2) {
      return Expanded(
          child: ListView.separated(
        itemCount: AppCache.currentReportDaily.viewerStatus.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.grey),
        itemBuilder: (context, index) {
          ViewerStatus record = AppCache.currentReportDaily.viewerStatus[index];
          return ListTile(
            leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(AppCache.getAvatarUrl(record.userId))),
            title: Text(record.getFullName()),
            // subtitle: Text(
            //     record.countView == 0
            //         ? 'Chưa xem lần nào'
            //         : 'Xem ${record.countView} lần, lần cuối: ${record.getTimeInChat()}',
            //     style: TextStyle(
            //         fontStyle: FontStyle.italic, color: Colors.grey))
          );
        },
      ));
    }
    return Center(child: CircularProgressIndicator());
  }

  getLayoutComments() {
    return Expanded(
        child: Column(children: <Widget>[
      Expanded(
          child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AppCache.backgroundChatDefault,
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                  child:
                      (this.listComment == null || this.listComment.length == 0)
                          ? Text('Không có nhật ký',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0))
                          : getListView()))),
      Divider(height: 2.0),
      getTextInput()
    ]));
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

  attachImageVideo(bool isVideo, ImageSource fromSource) async {
    PickedFile pickedFile;
    if (isVideo) {
      pickedFile = await this._imagePicker.getVideo(source: fromSource);
    } else {
      pickedFile = await this._imagePicker.getImage(source: fromSource);
    }
    if (pickedFile == null) return;
    FetchService.commentInsertMessage('BC', AppCache.currentReportDaily.id, '')
        .then((messageId) async {
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
        if (this.mounted) {
          this.filesAttachment[messageId].add(file);
          updateFileUpload(messageId);
        }
        await FetchService.fileUploadBytes(
                "FileComment", 'BC/' + messageId, file.fileName, file.bytes, 0)
            .then((int value) {
          if (value > -1) {
            file.url = FetchService.getDomainLink() +
                '/Upload/FileComment/' +
                'BC/' +
                messageId +
                '/' +
                file.fileName;
            file.isDownloading = false;
            file.progressing = '';
            updateFileUpload(messageId);
          }
        });
      }
    });
  }

  attachFiles() async {
    FilePicker.getMultiFilePath().then((files) {
      if (files == null || files.entries.length == 0) return;
      FetchService.commentInsertMessage(
              'BC', AppCache.currentReportDaily.id, '')
          .then((messageId) async {
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

            await FetchService.fileUpload("FileComment", 'BC/' + messageId,
                    item.key, File(item.value))
                .then((bool value) {
              setState(() {
                file.url = FetchService.getDomainLink() +
                    '/Upload/FileComment/' +
                    'BC/' +
                    messageId +
                    '/' +
                    file.fileName;
                file.isDownloading = false;
                file.progressing = '';
              });
            });
          }
        }
      });
    });
  }

  attachImages() async {
    MultiImagePicker.pickImages(
            maxImages: 50,
            enableCamera: true,
            cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"))
        .then((images) async {
      if (images == null || images.length == 0) return;
      FetchService.commentInsertMessage(
              'BC', AppCache.currentReportDaily.id, '')
          .then((messageId) async {
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
            if (this.mounted) {
              this.filesAttachment[messageId].add(file);
              updateFileUpload(messageId);
            }
            await FetchService.fileUploadBytes(
                    "FileComment",
                    'BC/' + messageId,
                    file.fileName,
                    file.bytes,
                    this.filesAttachment[messageId].length - 1)
                .then((int value) {
              if (value > -1) {
                file.url = FetchService.getDomainLink() +
                    '/Upload/FileComment/' +
                    'BC/' +
                    messageId +
                    '/' +
                    file.fileName;
                file.isDownloading = false;
                file.progressing = '';
                updateFileUpload(messageId);
              }
            });
          }
        }
      });
    });
  }

  updateFileUpload(String messageId) {
    for (int i = this.listComment.length - 1; i > 0; i--) {
      if (this.listComment[i].id == messageId) {
        setState(() {
          this.listComment[i].files = this.filesAttachment[messageId];
        });
        break;
      }
    }
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

  sendMessage() {
    setState(() {
      enableButton = false;
    });
    var text = textEditingController.value.text.replaceAll('\n', '<br/>');
    textEditingController.clear();
    if (text.isNotEmpty) {
      FetchService.commentInsertMessage(
          'BC', AppCache.currentReportDaily.id, text);
    }
  }

  Widget getListView() {
    return ListView.separated(
        // controller: this._scrollController,
        itemCount: this.listComment.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: 2.0),
        itemBuilder: (BuildContext context, int index) {
          var record = this.listComment[index];
          if (record.files.length == 0) {
            if (record.userId == AppCache.currentUser.userId)
              return _getRightChat(record);
            return _getLeftChat(record);
          } else {
            List<Widget> widgets = [];
            if (record.message.isEmpty) {
              widgets.addAll(_buildItemFile(this.listComment[index]));
            } else {
              widgets.add(record.userId == AppCache.currentUser.userId
                  ? _getRightChat(record)
                  : _getLeftChat(record));
              widgets.addAll(_buildItemFile(this.listComment[index]));
            }
            return Column(
                crossAxisAlignment: record.userId == AppCache.currentUser.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: widgets);
          }
        });
  }

  getWidgetFileDownload(FileAttachment item, String messageId) {
    return Container(
        constraints: BoxConstraints(maxWidth: this.maxWidthAttachFile),
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: new ListTile(
            leading: item.isDownloading ? CircularProgressIndicator() : null,
            title: new Text(
              item.fileName,
              style: new TextStyle(color: Colors.black),
            ),
            subtitle: item.progressing.isEmpty ? null : Text(item.progressing),
            trailing: item.isDownloading
                ? (item.url.isEmpty
                    ? Icon(Icons.file_upload, color: Colors.green)
                    : null)
                : IconButton(
                    icon: Icon(Icons.remove_red_eye, color: Colors.green),
                    onPressed: () {
                      if (item.localPath.isEmpty) {
                        this.downloadFile(item, 'BaoCao',
                            AppCache.currentReportDaily.id + '/' + messageId);
                      } else {
                        AppHelpers.openFile(item, this.context);
                      }
                    })));
  }

  _buildItemFile(Comment record) {
    List<Widget> _widgetFiles = <Widget>[];
    for (FileAttachment item in record.files) {
      if (item.isDownloading) {
        _widgetFiles.add(getWidgetFileDownload(item, record.id));
        continue;
      }
      if (AppCache.extsImage
          .contains(item.extension.toLowerCase())) // check file is image
      {
        _widgetFiles.add(InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => item.bytes == null
                          ? ImageUrlViewerPage(
                              fileName: item.fileName, urlImage: item.url)
                          : ImageUrlViewerPage(
                              fileName: item.fileName,
                              urlImage: item.fileName,
                              bytes: item.bytes)));
            },
            child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                child: item.bytes != null
                    ? Image(
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                        image: Image.memory(item.bytes).image)
                    : item.localPath.isNotEmpty
                        ? Image(
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                            image: Image.file(File(item.localPath)).image)
                        : Image.network(
                            item.url,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                            cacheWidth: 200,
                            cacheHeight: 200,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                          ))));
      } else {
        _widgetFiles.add(getWidgetFileDownload(item, record.id));
      }
    }
    return _widgetFiles;
  }

  _getLeftChat(Comment record) {
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
    widgets.add(CircleAvatar(
        backgroundImage: NetworkImage(AppCache.getAvatarUrl(record.userId))));
    widgets.add(SizedBox(width: 2, height: 1));
    widgets.add(Padding(padding: const EdgeInsets.all(6.0), child: message));
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widgets);
  }

  void showReplyDialog(Comment record) {
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
              HtmlWidget(AppCache.getHtmlReply(record.userId, record.message),
                  webView: true, webViewJs: false)
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
                              AppCache.getHtmlReply(
                                  record.userId, record.message);
                      FetchService.commentInsertMessage(
                          'BC', AppCache.currentReportDaily.id, text);
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Gửi", style: TextStyle(color: Colors.black)))
            ],
          );
        });
  }

  _getRightChat(Comment record) {
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
              right: 0, bottom: 0, child: CustomPaint(painter: Triangle())),
        ]),
        onTap: () {
          showReplyDialog(record);
        });
    widgets.add(Padding(padding: const EdgeInsets.all(6.0), child: message));
    widgets.add(SizedBox(width: 2, height: 1));
    widgets.add(CircleAvatar(
        backgroundImage: NetworkImage(AppCache.getAvatarUrl(record.userId))));
    widgets.add(SizedBox(width: 5, height: 1));
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widgets);
  }

  Future<void> downloadFile(
      FileAttachment file, String module, String id) async {
    Dio dio = Dio();
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      file.localPath = "${dir.path}/$module";
      await AppHelpers.createFolder(file.localPath);
      file.localPath += "/$id";
      await AppHelpers.createFolder(file.localPath);
      file.localPath += "/${file.fileName}";
      dio.download(file.url, file.localPath, onReceiveProgress: (rec, total) {
        setState(() {
          file.isDownloading = true;
          String mbRec = (rec / 1048576).toStringAsFixed(1);
          String mbTotal = (total / 1048576).toStringAsFixed(1);
          file.progressing =
              "Đang tải file.....$mbRec/$mbTotal MB (${(rec / total * 100).toStringAsFixed(0)}%)";
        });
      }).then((val) {
        setState(() {
          file.isDownloading = false;
          file.progressing = '';
        });
        AppHelpers.openFile(file, this.context);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> onBackClick() async {
    if (widget.isFromFormList == true) {
      Navigator.pop(context);
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ReportDailyPage()));
    }
	return false;
  }

  @override
  Widget build(BuildContext context) {
    this.maxWidthChat = MediaQuery.of(context).size.width * 0.8;
    this.maxWidthAttachFile = MediaQuery.of(context).size.width * 0.8;
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
                title: Text('Chi tiết báo cáo')),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: _setBodyForm())));
  }
}

class ReportDailyDetailPage extends StatefulWidget {
  ReportDailyDetailPage({this.isFromFormList = false});

  final bool isFromFormList;

  @override
  State<StatefulWidget> createState() {
    return ReportDailyDetailPageState();
  }
}
