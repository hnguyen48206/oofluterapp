library globals;

import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:onlineoffice_flutter/models/announcement_model.dart';
import 'package:onlineoffice_flutter/models/calendar_week_model.dart';
import 'package:onlineoffice_flutter/models/discuss_work_model.dart';
import 'package:onlineoffice_flutter/models/document_model.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/signature_model.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:onlineoffice_flutter/models/work_project_model.dart';
import 'package:onlineoffice_flutter/models/report_daily_model.dart';

class AppCache {
  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  static String webviewLastURL = '';
  static bool isCreatedFromDocs = false;
  static List<int> badges = <int>[0, 0, 0, 0, 0, 0, 0, 0, 0];

  static Map<String, dynamic> messageNotify;

  static const ImageProvider<dynamic> backgroundChatDefault =
      AssetImage("images/background_chat.jpeg");

  static Account currentUser = Account();

  static String tabIndexDocumentList = 'VBDE';

  static String htmlReply =
      "<table style='border-collapse: collapse; border-style: solid; border-width: 1px;' border='1' cellspacing='0' cellpadding='6' bgcolor='#E7DFCE'><tbody><tr><td style='border: 1px inset;'><div>Trích dẫn từ : <strong>{0}</strong></div><div>{1}</div></td></tr></tbody></table>";

  static int tabIndexWorkList = 1;

  static String imei = '';

  static String tokenFCM = '';

  static LichTuan currentCalendar = LichTuan();

  static ReportDaily currentReportDaily = ReportDaily(null, '', '');

  static Signature currentSignature = Signature(null);

  static Announcement currentAnnouncement = Announcement(null);

  static DiscussWork currentDiscussWork = DiscussWork(null);

  static WorkProject currentWorkProject = WorkProject(null);

  static DocumentDetail currentDocumentDetail = DocumentDetail(null);

  static Document currentDocument = Document(null);

  static List<IdText> listParentReport = [];
  static List<IdText> listChildrenReport = [];

  static List<Role> listRole = <Role>[];

  static List<Account> allUser = <Account>[];

  static List<GroupUser> allGroupUser = <GroupUser>[];

  static List<CategoryDb> allProject = <CategoryDb>[];

  static List<CategoryDb> allDocumentSource = <CategoryDb>[];

  static List<CategoryDb> allDocumentDirectories = <CategoryDb>[];

  static List<Account> getUsersByIds(List<String> listId) {
    if (listId == null) return <Account>[];
    return allUser.where((i) => listId.contains(i.userId)).toList();
  }

  static int getIndexCurrentUser() {
    int length = allUser.length;
    String id = currentUser.userId;
    for (int i = 0; i < length; i++) {
      if (allUser[i].userId == id) return i;
    }
    return -1;
  }

  static Account getUserById(String userId) {
    var query = allUser.where((i) => i.userId == userId);
    if (query.length > 0) return query.first;
    return null;
  }

  static String getAvatarUrl(String userId) {
    var query = allUser.where((i) => i.userId == userId);
    if (query.length > 0) return query.first.avatar;
    return 'https://oo.onlineoffice.vn/api/icons/user_icon.png';
  }

  static String getFullNameById(String userId) {
    var query = allUser.where((i) => i.userId == userId);
    if (query.length > 0) return query.first.fullName;
    return '';
  }

  static String getHtmlReply(String userId, String message) {
    String html = AppCache.htmlReply
        .replaceFirst("{0}", AppCache.getFullNameById(userId));
    if (message.trim().startsWith('<'))
      html = html.replaceFirst("{1}", message);
    else
      html = html.replaceFirst("{1}", "<p>" + message + "</p>");
    return html;
  }

  static String getGroupReportName(String parentId, String childrenId) {
    if (parentId.isEmpty) return 'Tất cả báo cáo';
    String result = listParentReport.where((i) => i.id == parentId).first.text;
    if (childrenId.isNotEmpty)
      result += ' (' +
          listChildrenReport.where((i) => i.id == childrenId).first.text +
          ')';
    return result;
  }

  static String getCategoryNameById(List<CategoryDb> listCategory, String id) {
    var query = listCategory.where((i) => i.id == id);
    if (query.length > 0) return query.first.name;
    return '';
  }

  static String getGroupNameById(String groupId) {
    var query = allGroupUser.where((i) => i.groupId == groupId);
    if (query.length > 0) return query.first.groupName;
    if (groupId == 'All') return 'Tất cả';
    return '';
  }

  static List<String> extsImage = [
    "png",
    "jpg",
    "jpeg",
    "tiff",
    "heif",
    "heic"
  ];

  static DateFormat datetimeFormat = DateFormat("dd-MM-yyyy HH:mm");

  static DateFormat timeFormat = DateFormat("HH:mm");

  static DateFormat dateVnFormat = DateFormat("dd-MM-yyyy");

  static List<String> datetimeFormatArray = [
    dd,
    '-',
    mm,
    '-',
    yyyy,
    ' ',
    HH,
    ':',
    nn
  ];

  static List<String> dateVnFormatArray = [dd, '-', mm, '-', yyyy];

  static Color colorApp = Colors.blueAccent;

  static double paddingCard = 10.0;

  static double textScaleFactor = 1.0;

  static Future<File> getFileFromURL(url) async {
    final http.Response responseData = await http.get(url);
    var arr = url.path.split('/');

    Uint8List uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var downloadDir = null;
    if (Platform.isIOS == true)
      downloadDir = await getDownloadsDirectory();
    else
      // downloadDir = await getExternalStorageDirectory();
      downloadDir = await DownloadsPath.downloadsDirectory();
    File file = await File('${downloadDir.path}/${arr[arr.length - 1]}')
        .writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    Fluttertoast.showToast(
        msg: 'Tải file ${arr[arr.length - 1]} hoàn tất',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightBlue,
        textColor: Colors.white,
        fontSize: 16.0);
    try {
      OpenFile.open('${downloadDir.path}/${arr[arr.length - 1]}');
    } catch (e) {
      print(e);
    }
    return file;
  }

  static String toLowerCaseNonAccentVietnamese(String str) {
    str = str.toLowerCase();

    var arr1 = [
      "á",
      "à",
      "ả",
      "ã",
      "ạ",
      "â",
      "ấ",
      "ầ",
      "ẩ",
      "ẫ",
      "ậ",
      "ă",
      "ắ",
      "ằ",
      "ẳ",
      "ẵ",
      "ặ",
      "đ",
      "é",
      "è",
      "ẻ",
      "ẽ",
      "ẹ",
      "ê",
      "ế",
      "ề",
      "ể",
      "ễ",
      "ệ",
      "í",
      "ì",
      "ỉ",
      "ĩ",
      "ị",
      "ó",
      "ò",
      "ỏ",
      "õ",
      "ọ",
      "ô",
      "ố",
      "ồ",
      "ổ",
      "ỗ",
      "ộ",
      "ơ",
      "ớ",
      "ờ",
      "ở",
      "ỡ",
      "ợ",
      "ú",
      "ù",
      "ủ",
      "ũ",
      "ụ",
      "ư",
      "ứ",
      "ừ",
      "ử",
      "ữ",
      "ự",
      "ý",
      "ỳ",
      "ỷ",
      "ỹ",
      "ỵ"
    ];
    var arr2 = [
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "a",
      "d",
      "e",
      "e",
      "e",
      "e",
      "e",
      "e",
      "e",
      "e",
      "e",
      "e",
      "e",
      "i",
      "i",
      "i",
      "i",
      "i",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "o",
      "u",
      "u",
      "u",
      "u",
      "u",
      "u",
      "u",
      "u",
      "u",
      "u",
      "u",
      "y",
      "y",
      "y",
      "y",
      "y"
    ];
    for (int i = 0; i < arr1.length; i++) {
      str = str.replaceAll("ẫ", '');
    }
    return str;
  }
}
