import 'dart:convert';

import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class WorkProject {
  String id;
  String parentId;
  String title = '';
  String msda = '';
  String nguoiTao = '';
  String nguoiChinh = '';
  String ngayBatDau = '';
  String ngayKetThuc = '';
  bool cvKhanCap = false;
  bool cvCanTheoDoi = false;

  String content = '';
  String creator = '';

  String linkIcon = '';
  String hexColor = '';

  bool hasNewMessage;
  String countMessage = '0';
  int isEdited = 1;
  int tick;
  List<String> nguoiXuLys = <String>[];
  List<String> nguoiDuocXems = <String>[];
  List<String> nguoiXuLysAdditional = <String>[];
  List<String> nguoiDuocXemsAdditional = <String>[];
  List<String> nguoiChuyenTieps = <String>[];
  List<Account> userXuLys = <Account>[];
  List<Account> userDuocXems = <Account>[];
  List<Account> userChuyenTieps = <Account>[];
  List<String> fileDinhKems = <String>[];
  List<FileAttachment> files = <FileAttachment>[];

  WorkProject(this.id);

  WorkProject.fromJsonList(Map<String, dynamic> json) {
    id = json['mscv'];
    title = json['chude'];
    nguoiTao = json['nguoi_tao'];
    ngayBatDau = json['NgayBatDau'];
    ngayKetThuc = json['NgayKetThuc'];
    linkIcon = json['LinkIcon'];
    hexColor = json['HexColor'];
    hasNewMessage = false;
    tick = json['Tick'];
  }

  WorkProject.fromJsonDetail(Map<String, dynamic> json) {
    id = json['mscv'];
    title = json['chude'];
    content = json['noidung'];
    nguoiChinh = json['nguoichinh'];
    ngayBatDau = json['NgayBatDau'];
    ngayKetThuc = json['NgayKetThuc'];
    nguoiXuLys = json['nguoiXuLys'].cast<String>();
    nguoiDuocXems = json['nguoiDuocXems'].cast<String>();
    cvKhanCap = json['cvkhancap'] == '1';
    cvCanTheoDoi = json['cvCanTheoDoi'] == '1';
    msda = json['MSDA'];
    // isEdited = json['isEdited'];
    fileDinhKems = json['fileDinhKems'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mscv'] = this.id;
    data['chude'] = this.title;
    if (this.content != null && this.content.isNotEmpty) {
      data['noidung'] = this.content.replaceAll('\n', '<br/>');
    }
    data['nguoichinh'] = this.nguoiChinh;
    data['nguoi_tao'] = this.creator;
    data['nguoiXuLys'] = this.nguoiXuLys;
    data['nguoiDuocXems'] = this.nguoiDuocXems;
    data['cvkhancap'] = this.cvKhanCap ? '1' : '0';
    data['cvCanTheoDoi'] = this.cvCanTheoDoi ? '1' : '0';
    data['ma_cv_xp'] = this.parentId;
    data['StartDate'] = this.ngayBatDau;
    data['EndDate'] = this.ngayKetThuc;
    data['MSDA'] = this.msda;
    return data;
  }

  static List<WorkProject> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<WorkProject>((json) => WorkProject.fromJsonList(json))
        .toList();
  }
}

class WorkProjectMessage {
  String id;
  String message;
  String userId;
  int tick;
  String time;
  List<FileAttachment> files;

  WorkProjectMessage(
      this.id, this.message, this.userId, this.tick, this.time, this.files);

  WorkProjectMessage.fromJson(Map<String, dynamic> json) {
    id = json['ID_Nhat_Ky'];
    message = json['Message'];
    userId = json['Nguoi_Phan_Hoi'];
    tick = json['Tick'];
    time = json['Time'];
    List<String> filedinhkems = json['Files'].cast<String>();
    files = filedinhkems.map((p) => FileAttachment(p)).toList();
  }

  static List<WorkProjectMessage> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<WorkProjectMessage>((json) => WorkProjectMessage.fromJson(json))
        .toList();
  }

  String getTimeInChat() {
    return ObjectHelper.timeToTextChat(time);
  }
}
