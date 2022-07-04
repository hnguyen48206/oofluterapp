import 'dart:convert';

import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class DiscussWork {
  String id;
  String title = '';
  String subTitle;
  bool hasNewMessage;
  String countMessage = '0';
  int tick;

  String content = '';
  String creator = '';
  int isEdited = 0;
  List<String> nguoiThamGias = <String>[];
  List<Account> users = <Account>[];
  List<String> fileDinhKems = <String>[];
  List<FileAttachment> files = <FileAttachment>[];

  DiscussWork(this.id);

  DiscussWork.fromJsonList(Map<String, dynamic> json) {
    id = json['IDTD'];
    title = json['CHUDE'];
    subTitle = json['SubTitle'];
    tick = json['Tick'];
    hasNewMessage = false;
    creator = json['NGUOITAO'];
  }

  DiscussWork.fromJsonDetail(Map<String, dynamic> json) {
    id = json['IDTD'];
    title = json['CHUDE'];
    content = json['NOIDUNG'];
    nguoiThamGias = json['nguoiThamGias'].cast<String>();
    isEdited = json['isEdited'];
    fileDinhKems = json['fileDinhKems'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IDTD'] = this.id;
    data['CHUDE'] = this.title;
    if (this.content != null && this.content.isNotEmpty) {
      data['NOIDUNG'] = this.content.replaceAll('\n', '<br/>');
    }
    data['NGUOITAO'] = this.creator;
    data['nguoiThamGias'] = this.nguoiThamGias;
    return data;
  }

  static List<DiscussWork> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<DiscussWork>((json) => DiscussWork.fromJsonList(json))
        .toList();
  }
}

class DiscussWorkMessage {
  String id;
  String message;
  String userId;
  int tick;
  String time;
  List<FileAttachment> files;

  DiscussWorkMessage(
      this.id, this.message, this.userId, this.tick, this.time, this.files);

  DiscussWorkMessage.fromJson(Map<String, dynamic> json) {
    id = json['IDNOIDUNG'];
    message = json['Message'];
    userId = json['NGUOITAO'];
    tick = json['Tick'];
    time = json['Time'];
    List<String> filedinhkems = json['Files'].cast<String>();
    files = filedinhkems.map((p) => FileAttachment(p)).toList();
  }

  static List<DiscussWorkMessage> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<DiscussWorkMessage>((json) => DiscussWorkMessage.fromJson(json))
        .toList();
  }

  String getTimeInChat() {
    return ObjectHelper.timeToTextChat(time);
  }
}
