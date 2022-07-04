import 'dart:convert';

import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class Comment {
  String id;
  String message;
  String userId;
  int tick;
  String time;
  List<FileAttachment> files;

  Comment(this.id, this.message, this.userId, this.tick, this.time, this.files);

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['IDComment'];
    message = json['NOIDUNG'];
    userId = json['NGUOITAO'];
    tick = json['Tick'];
    time = json['Time'];
    List<String> filedinhkems = json['Files'].cast<String>();
    files = filedinhkems.map((p) => FileAttachment(p)).toList();
  }

  static List<Comment> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Comment>((json) => Comment.fromJson(json)).toList();
  }

  String getTimeInChat() {
    return ObjectHelper.timeToTextChat(time);
  }
}
