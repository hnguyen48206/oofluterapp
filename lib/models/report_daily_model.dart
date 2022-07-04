import 'dart:convert';

import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class ReportDaily {
  String id;
  String childrenId = '';
  String parentId = '';
  String title = '';
  String time;
  int countView = 0;
  String content = '';
  String creator = '';
  List<Account> users = [];
  List<String> fileDinhKems = [];
  List<FileAttachment> files = [];
  List<ViewerStatus> viewerStatus = [];
  int tick;

  ReportDaily(this.id, this.childrenId, this.parentId);

  ReportDaily.fromJsonList(Map<String, dynamic> json) {
    id = json['IDBC'];
    title = json['TENBC'];
    creator = json['NGUOITAO'];
    time = json['Time'];
    tick = json['Tick'];
    countView = json['CountView'];
  }

  ReportDaily.fromJsonDetail(Map<String, dynamic> json) {
    id = json['IDBC'];
    childrenId = json['IDMUC'];
    parentId = json['LOAIBC'];
    title = json['TENBC'];
    content = json['NOIDUNG'];
    creator = json['NGUOITAO'];
    time = json['Time'];
    countView = json['CountView'];
    fileDinhKems = json['FileDinhKems'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IDBC'] = this.id;
    data['TENBC'] = this.title;
    if (this.content != null && this.content.isNotEmpty) {
      data['NOIDUNG'] = this.content.replaceAll('\n', '<br/>');
    }
    data['NGUOITAO'] = this.creator;
    data['IDMUC'] = this.childrenId;
    data['LOAIBC'] = int.parse(this.parentId);
    return data;
  }

  static List<ReportDaily> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<ReportDaily>((json) => ReportDaily.fromJsonList(json))
        .toList();
  }

  String getTimeInChat() {
    return ObjectHelper.timeToTextChat(time);
  }

  String getTitleAction() {
    return this.id == null ? "Tạo báo cáo" : "Chỉnh sửa báo cáo";
  }
}
