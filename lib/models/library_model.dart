import 'dart:convert';

import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class Library {
  String id;
  // String categoryId = '';
  String datePublish = '';
  String time;
  int countView = 0;
  String title = '';
  String content = '';
  String creator = '';
  List<String> fileDinhKems = [];
  List<FileAttachment> files = [];
  int tick;

  // Library(this.id, this.categoryId);
  Library(this.id);

  Library.fromJsonList(Map<String, dynamic> json) {
    id = json['IDTULIEU'];
    title = json['MASO'];
    content = json['NOIDUNG'];
    creator = json['NGUOITAO'];
    datePublish = json['ThoiGianBanHanh'];
    time = json['Time'];
    tick = json['Tick'];
    countView = json['CountView'];
  }

  Library.fromJsonDetail(Map<String, dynamic> json) {
    id = json['IDTULIEU'];
    title = json['MASO'];
    content = json['NOIDUNG'];
    creator = json['NGUOITAO'];
    datePublish = json['ThoiGianBanHanh'];
    time = json['Time'];
    tick = json['Tick'];
    countView = json['CountView'];
    fileDinhKems = json['FileDinhKems'].cast<String>();
  }

  static List<Library> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Library>((json) => Library.fromJsonList(json)).toList();
  }

  String getTimeInChat() {
    return ObjectHelper.timeToTextChat(time);
  }
}
