import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/globals.dart';

class ObjectHelper {
  static DateTime dateVnToDateTime(String text) {
    if (text == null || text.isEmpty) return DateTime.now();
    var arr = text.split('-');
    try {
      return DateTime.parse(arr[2] + arr[1] + arr[0]);
    } catch (e) {
      return DateTime.now();
    }
  }

  static String timeToTextChat(String textTime) {
    if (textTime == null || textTime.isEmpty) return '';

    var now = new DateTime.now();
    var date = DateTime.parse(textTime); // yyyyMMdd HH:mm:ss
    var diff = now.difference(date);
    var time = '';
    if (diff.inSeconds < 0) {
      time = '1 giây trước';
    } else if (diff.inSeconds + 1 < 60) {
      time = '${diff.inSeconds + 1} giây trước';
    } else {
      if (diff.inMinutes < 60) {
        time = '${diff.inMinutes} phút trước';
      } else {
        if (diff.inHours < 24) {
          time =
              '${diff.inHours} giờ trước, ' + AppCache.timeFormat.format(date);
        } else {
          if (diff.inDays == 1) {
            time = 'Hôm qua, ' + AppCache.timeFormat.format(date);
          } else {
            time = AppCache.datetimeFormat.format(date);
          }
        }
      }
    }
    return time;
  }

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static String removeHTML(String text) {
    return text.replaceAll(new RegExp("<.*?>|&.*?;"), '');
  }

  static String toBase64(String text) {
    var bytes = utf8.encode(text);
    var result = base64UrlEncode(bytes);
    return result;
  }

  static String convertToUnSign(String str) {
    List<String> signs = <String>[];
    signs.add("aeouidy");
    signs.add("áàạảãâấầậẩẫăắằặẳẵ");
    signs.add("éèẹẻẽêếềệểễ");
    signs.add("óòọỏõôốồộổỗơớờợởỡ");
    signs.add("úùụủũưứừựửữ");
    signs.add("íìịỉĩ");
    signs.add("đ");
    signs.add("ýỳỵỷỹ");
    for (int i = 1; i < signs.length; i++) {
      for (int j = 0; j < signs[i].length; j++) {
        str = str.replaceAll(signs[i][j], signs[0][i - 1]);
      }
    }
    return str;
  }
}
