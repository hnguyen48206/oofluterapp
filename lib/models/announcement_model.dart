import 'dart:convert';

import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class Announcement {
  String id;
  String title = '';
  String khanCap = '0';
  String ngayTao = '';
  String chk = '1';
  bool hasNewMessage;
  String countMessage = '0';
  int tick;

  String content = '';
  String creator = '';
  List<String> nguoiDuocXems = [];
  List<Account> users = [];
  List<String> fileDinhKems = [];
  List<FileAttachment> files = [];
  List<ViewerStatus> viewerStatus = [];
  List<String> buttons;

  Announcement(this.id);

  Announcement.fromJsonList(Map<String, dynamic> json) {
    id = json['MS_THONGBAO'];
    title = json['CHUDE'];
    khanCap = json['KHANCAP'];
    ngayTao = json['NgayTao'];
    tick = json['Tick'];
    hasNewMessage = false;
    creator = json['NGUOI_TAO'];
  }

  Announcement.fromJsonDetail(Map<String, dynamic> json) {
    id = json['MS_THONGBAO'];
    title = json['CHUDE'];
    content = json['NOIDUNG'];
    khanCap = json['KHANCAP'];
    chk = json['CHK'];
    nguoiDuocXems = json['nguoiDuocXems'].cast<String>();
    buttons = json['buttons'].cast<String>();
    fileDinhKems = json['fileDinhKems'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MS_THONGBAO'] = this.id;
    data['CHUDE'] = this.title;
    if (this.content != null && this.content.isNotEmpty) {
      data['NOIDUNG'] = this.content.replaceAll('\n', '<br/>');
    }
    data['KHANCAP'] = this.khanCap;
    data['CHK'] = this.chk;
    data['NGUOI_TAO'] = this.creator;
    data['nguoiDuocXems'] = this.nguoiDuocXems;
    return data;
  }

  bool isUrgent() {
    return this.khanCap == '1';
  }

  bool isCheckAll() {
    return this.chk == '2';
  }

  String getTitleAction() {
    return this.id == null ? "Tạo thông báo" : "Chỉnh sửa thông báo";
  }

  static List<Announcement> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<Announcement>((json) => Announcement.fromJsonList(json))
        .toList();
  }
}
