import 'dart:convert';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';

class CategoryDb {
  String id;
  String name;
  bool checked;

  CategoryDb.fromJsonList(Map<String, dynamic> json) {
    if (json.containsKey('MSDA'))
      id = json['MSDA'];
    else
      id = json['Id'];
    if (json.containsKey('Ten_Du_An'))
      name = json['Ten_Du_An'];
    else
      name = json['Name'];
    checked = false;
  }

  static List<CategoryDb> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<CategoryDb>((json) => CategoryDb.fromJsonList(json))
        .toList();
  }
}

class FileAttachment {
  String fileName;
  String extension;
  String url;
  String localPath;
  String progressing = '';
  String mimeType;
  bool isDownloading = false;
  List<int> bytes;
  int size = 0;
  String icon = '';

  FileAttachment(String text) {
    var arrFile = text.split("?");
    String link = arrFile[0];
    this.mimeType = arrFile[1];
    if (arrFile.length > 2) {
      this.size = int.parse(arrFile[2]);
    }
    if (arrFile.length > 3) {
      this.icon = FetchService.getDomainLink() + "/images/" + arrFile[3];
    }
    // else {
    //   this.icon = FetchService.getDomainLink() + "/images/PDF_Icon.png";
    // }
    var arrText = link.split("/");
    this.fileName = arrText[arrText.length - 1];
    this.url = FetchService.getDomainLink() + "/Upload/" + link;
    var arrStr = this.fileName.split(".");
    this.extension = arrStr[arrStr.length - 1];
    this.isDownloading = false;
    this.progressing = '';
    this.localPath = '';
  }

  bool isLowSize() {
    return this.size < (1048576 * 3); // 3.0 MB
  }

  String getTextSize() {
    if (this.size == 0) return '';
    if (this.size <= 1048576)
      return 'Dung lượng: ${(this.size / 1024).toStringAsFixed(1)} KB';
    return 'Dung lượng: ${(this.size / 1048576).toStringAsFixed(1)} MB';
  }

  FileAttachment.empty();
}

class ViewerStatus {
  String userId;
  int countView;
  String time;

  ViewerStatus(this.userId, this.countView, this.time);

  ViewerStatus.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    countView = json['So_Lan_Xem'];
    time = json['Time'];
  }

  static List<ViewerStatus> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<ViewerStatus>((json) => ViewerStatus.fromJson(json))
        .toList();
  }

  String getFullName() {
    return AppCache.getFullNameById(userId);
  }

  String getTimeInChat() {
    return ObjectHelper.timeToTextChat(time);
  }
}

class TitleValue {
  String title;
  String value;

  TitleValue(this.title, this.value);
}

class IdText {
  String id;
  String text;
  String parentId;

  IdText(this.id, this.text, this.parentId);

  IdText.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    text = json['Text'];
    parentId = json['ParentId'];
  }

  static List<IdText> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<IdText>((json) => IdText.fromJson(json)).toList();
  }
}
