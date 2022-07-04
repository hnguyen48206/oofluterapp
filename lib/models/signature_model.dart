import 'dart:convert';

import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class Signature {
  String id;
  String title = '';
  String ngayTao = '';
  String hexColor = '000000';
  int countMessage = 0;
  int tick;
  bool showFinish = false;
  bool availableSign = false;

  String content = '';
  String creator = '';
  List<String> nguoiDuocXems = [];
  List<Account> users = [];
  List<String> fileDinhKems = [];
  List<FileAttachment> files = [];
  List<ViewerStatus> viewerStatus = [];

  Signature(this.id);

  Signature.fromJsonList(Map<String, dynamic> json) {
    id = json['ID_TrinhKy'];
    title = json['CHUDE'];
    ngayTao = json['TimeCreate'];
    tick = json['Tick'];
    creator = json['NGUOITAO'];
    hexColor = json['HexColor'];
  }

  Signature.fromJsonDetail(Map<String, dynamic> json) {
    id = json['ID_TrinhKy'];
    title = json['CHUDE'];
    content = json['NOIDUNG'];
    showFinish = json['AvailableFinish'];
    availableSign = json['AvailableSign'];
    fileDinhKems = json['FileDinhKems'].cast<String>();
  }

  static List<Signature> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<Signature>((json) => Signature.fromJsonList(json))
        .toList();
  }
}

class SignatureMessage {
  String id;
  String message;
  String userId;
  int tick;
  String time;
  List<FileAttachment> files;

  SignatureMessage(
      this.id, this.message, this.userId, this.tick, this.time, this.files);

  SignatureMessage.fromJson(Map<String, dynamic> json) {
    id = json['IDNOIDUNG'];
    message = json['NOIDUNG'];
    userId = json['NGUOITAO'];
    tick = json['Tick'];
    time = json['Time'];
    List<String> filedinhkems = json['Files'].cast<String>();
    files = filedinhkems.map((p) => FileAttachment(p)).toList();
  }

  static List<SignatureMessage> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<SignatureMessage>((json) => SignatureMessage.fromJson(json))
        .toList();
  }

  String getTimeInChat() {
    return ObjectHelper.timeToTextChat(time);
  }
}
