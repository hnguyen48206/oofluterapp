import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:onlineoffice_flutter/globals.dart';
import 'package:http/http.dart' as http;
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/models/announcement_model.dart';
import 'package:onlineoffice_flutter/models/calendar_week_model.dart';
import 'package:onlineoffice_flutter/models/discuss_work_model.dart';
import 'package:onlineoffice_flutter/models/document_model.dart';
import 'package:onlineoffice_flutter/models/library_model.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/report_daily_model.dart';
import 'package:onlineoffice_flutter/models/signature_model.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:onlineoffice_flutter/models/work_project_model.dart';
import 'package:onlineoffice_flutter/models/comment_model.dart';
import 'package:intl/intl.dart';

class FetchService {
  static const Duration durationTimeout = Duration(seconds: 30);

  static String linkService = 'https://api.onlineoffice.vn/api/api/';

  static Map<String, String> body = Map();

  static Future<void> setAllRole(String userId) async {
    String url = linkService + 'user/roles';
    try {
      body.clear();
      body['user_id'] = userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.listRole = Role.parseJson(response.body);
      }
    } on Exception {}
  }

  static Future<void> setAllUser() async {
    String url = linkService + 'user/list';
    try {
      final response = await http.post(Uri.parse(url)).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.allUser = Account.parseJson(response.body);
      }
    } on Exception {}
  }

  static Future<bool> setAllProject() async {
    String url = linkService + 'congviec/listproject';
    try {
      final response = await http.post(Uri.parse(url)).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.allProject = CategoryDb.parseJson(response.body);
        return true;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  static Future<void> setAllGroupUser() async {
    String url = linkService + 'user/listgroupuser';
    try {
      final response = await http.post(Uri.parse(url)).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.allGroupUser = GroupUser.parseJson(response.body);
      }
    } on Exception {}
  }

  static Future<void> deleteTokenNew() async {
    String url = linkService + 'user/logout';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['imei'] = AppCache.imei;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        // print('Delete Token OK');
      } else {
        // print('Delete Token Error');
      }
    } on Exception {
      // print('Delete Token Throw Exception');
    }
  }

  static Future<void> deleteTokenOld() async {
    String userId = AppCache.currentUser.userId;
    String imei = AppCache.imei;
    String envelope =
        "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><delete_device_token xmlns='http://onlineoffice.vn/'><User_ID>$userId</User_ID><IMEI>$imei</IMEI></delete_device_token></soap12:Body></soap12:Envelope>";
    String domainName = getDomainLink();
    try {
      // http.Response response =
      await http.post(Uri.parse(domainName + '/wsOOPush.asmx'),
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://onlineoffice.vn/delete_device_token",
            "Host":
                domainName.replaceAll('https://', '').replaceAll('http://', '')
          },
          body: envelope);
      // if (response.statusCode != 200) {
      //   print('deleteTokenDeviceSoap ERROR');
      // }
    } on Exception {}
  }

  static String getDomainLink() {
    if (linkService.contains('api/api') == true) {
      return linkService.replaceFirst('/api/api/', '');
    }
    return linkService.replaceFirst('/appmobile/api/', '');
  }

  static String getLinkMobileLogin() {
    if (linkService.contains('/api/api/') == true) {
      return linkService.replaceAll('api/api/', 'Index_Mobile.aspx?U=') +
          AppCache.currentUser.userName +
          "&P=" +
          AppCache.currentUser.password;
    }
    return linkService.replaceAll('appmobile/api/', 'Index_Mobile.aspx?U=') +
        AppCache.currentUser.userName +
        "&P=" +
        AppCache.currentUser.password;
  }

  static Future<Account> login(
      String user, String pass, String token, String imei, String os) async {
    String url = linkService + 'user/login';
    Account result = Account();
    http.Response response;
    try {
      body.clear();
      body['username'] = user;
      body['password'] =
          md5.convert(utf8.encode(user.toLowerCase() + "oO" + pass)).toString();
      body['token'] = token ?? "";
      body['imei'] = imei;
      body['os'] = os;
      response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
    } on TimeoutException {
      result.error = "Không có kết nối.";
      return result;
    } on SocketException {
      result.error = "Không có kết nối.";
      return result;
    } on Exception {
      result.error = "Đăng nhập không thành công.";
      return result;
    }
    if (response.statusCode == 200) {
      result = Account.fromJson(json.decode(response.body));
      result.isOldVersion = false;
      result.password = pass;
      setAllRole(result.userId);
      setAllUser();
      setAllGroupUser();
      setListCategoryReport(result.userId);
      return result;
    } else {
      if (linkService.contains('api/api') == true) {
        linkService = linkService.replaceFirst('/api/api/', '/appmobile/api/');
        result = await login(user, pass, token, imei, os);
      }
      if (response.statusCode == 302 ||
          response.statusCode == 404 ||
          response.statusCode == 503) {
        result = await loginWS(user, pass, token, imei, os);
      } else {
        result.error = json.decode(response.body)['Message'];
      }
      return result;
    }
  }

  static Future<Account> loginWS(
      String user, String pass, String token, String imei, String os) async {
    Account result = Account();
    String domainName = getDomainLink();
    String envelope =
        "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><LoginWS xmlns='http://onlineoffice.vn/'><sUser>$user</sUser><sPass>$pass</sPass></LoginWS></soap12:Body></soap12:Envelope>";
    http.Response response =
        await http.post(Uri.parse(domainName + '/wsoo.asmx'),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
              "SOAPAction": "http://onlineoffice.vn/LoginWS",
              "Host": domainName
                  .replaceAll('https://', '')
                  .replaceAll('http://', '')
            },
            body: envelope);
    if (response.statusCode == 200) {
      if (response.body.contains('<LoginWSResult />')) {
        result.error = "Đăng nhập KHÔNG THÀNH CÔNG.";
      } else {
        result.isOldVersion = true;
        result.userName = user;
        result.password = pass;
        String json = response.body
            .split('<LoginWSResult>')[1]
            .split('</LoginWSResult>')[0];
        List<String> arrObj = json
            .replaceAll('{"LOGIN" : [{', '')
            .replaceAll('}]}', '')
            .split(',');
        for (var item in arrObj) {
          if (item.contains('User_ID')) {
            result.userId = item.split('"')[3];
            continue;
          }
          if (item.contains('Full_Name')) {
            result.fullName = item.split('"')[3];
            continue;
          }
        }
        addTokenDeviceSoap(domainName, result.userId, token, imei, os);
      }
    } else {
      result.error = "Không có kết nối.";
    }
    return result;
  }

  static Future<void> addTokenDeviceSoap(String domainName, String userId,
      String token, String imei, String os) async {
    String envelope =
        "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><add_device_token xmlns='http://onlineoffice.vn/'><DeviceTokenID>$token</DeviceTokenID><User_ID>$userId</User_ID><OS_Name>$os</OS_Name><IMEI>$imei</IMEI></add_device_token></soap12:Body></soap12:Envelope>";
    try {
      http.Response response =
          await http.post(Uri.parse(domainName + '/wsOOPush.asmx'),
              headers: {
                "Content-Type": "text/xml; charset=utf-8",
                "SOAPAction": "http://onlineoffice.vn/add_device_token",
                "Host": domainName
                    .replaceAll('https://', '')
                    .replaceAll('http://', '')
              },
              body: envelope);
      if (response.statusCode != 200) {
        print('addTokenDeviceSoap ERROR');
      }
    } on Exception {}
  }

  static Future<bool> fileUpload(
      String module, String objectId, String fileName, File file) async {
    String url = linkService + 'file/upload';
    try {
      body.clear();
      body["module"] = module;
      body["object_id"] = objectId;
      body["file_name"] = fileName;
      body["data"] = base64Encode(await file.readAsBytes());
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      print('Upload file OK');
      return response.statusCode == 200;
    } on Exception {
      print('Upload file Fail');
      return false;
    }
  }

  static Future<int> fileUploadBytes(String module, String objectId,
      String fileName, List<int> bytes, int index) async {
    String url = linkService + 'file/upload';
    try {
      body.clear();
      body["module"] = module;
      body["object_id"] = objectId;
      body["file_name"] = fileName;
      body["data"] = base64Encode(bytes);
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200 ? index : -1;
    } on Exception {
      return -1;
    }
  }

  static Future<bool> fileDelete(
      String module, String objectId, List<String> filesName) async {
    String url = linkService + 'file/delete';
    try {
      body.clear();
      body["module"] = module;
      body["object_id"] = objectId;
      body["files_name"] = filesName.join('?');
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> calendarWeekInsertUpdate() async {
    String url = linkService + 'lichtuan/save';
    try {
      if (AppCache.currentCalendar.lichTuanId == null ||
          AppCache.currentCalendar.lichTuanId.isEmpty) {
        AppCache.currentCalendar.nguoiDangKy = AppCache.currentUser.userId;
      }
      AppCache.currentCalendar.fullName = AppCache.currentUser.fullName;
      String jsonText = jsonEncode(AppCache.currentCalendar.toJson());
      body.clear();
      body["data"] = ObjectHelper.toBase64(jsonText);
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentCalendar.lichTuanId = response.body.replaceAll('"', '');
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> workProjectInsertUpdate() async {
    String url = linkService + 'congviec/save';
    try {
      if (AppCache.currentWorkProject.id == null ||
          AppCache.currentWorkProject.id.isEmpty) {
        AppCache.currentWorkProject.creator = AppCache.currentUser.userId;
      }
      var jsonOriginal = AppCache.currentWorkProject.toJson();
      if (AppCache.isCreatedFromDocs)
        jsonOriginal['msvb'] = AppCache.currentDocumentDetail.id;

      String jsonText = jsonEncode(jsonOriginal);
      body.clear();
      body["data"] = ObjectHelper.toBase64(jsonText);

      Map<String, String> check = Map();
      check = body;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentWorkProject.id = response.body.replaceAll('"', '');
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<int> accountChangeInfo(
      String birthDay, String email, String phone) async {
    String url = linkService + 'user/update';
    try {
      body.clear();
      body["user_id"] = AppCache.currentUser.userId;
      body["birth_day"] = birthDay;
      body["email"] = email;
      body["phone"] = phone;

      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentUser.birthDay = birthDay;
        AppCache.currentUser.email = email;
        AppCache.currentUser.phone = phone;
        int i = AppCache.getIndexCurrentUser();
        AppCache.allUser[i].birthDay = birthDay;
        AppCache.allUser[i].email = email;
        AppCache.allUser[i].phone = phone;
        return i;
      } else {
        return -1;
      }
    } on Exception {
      return -1;
    }
  }

  static Future<bool> accountChangePass(String pass) async {
    String url = linkService + 'user/move';
    try {
      body.clear();
      body["user_id"] = AppCache.currentUser.userId;
      body["data"] = pass;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> documentInsertUpdate() async {
    String url = linkService + 'vanban/save';
    try {
      // if (AppCache.currentDocument.luuHoSo.isEmpty) {
      // AppCache.currentDocument.luuHoSo = AppCache.currentUser.;
      // }
      if (AppCache.currentDocument.nguoiTao.isEmpty) {
        AppCache.currentDocument.nguoiTao = AppCache.currentUser.userId;
      }
      String jsonText = jsonEncode(AppCache.currentDocument.toJson());
      body.clear();
      body["data"] = ObjectHelper.toBase64(jsonText);
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentDocument.id = response.body.replaceAll('"', '');
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> workProjectInputResult(
      String workId, String content, String dateComplete) async {
    String url = linkService + 'congviec/inputresult';
    try {
      body.clear();
      body["work_id"] = workId;
      body["user_id"] = AppCache.currentUser.userId;
      body["content"] = content;
      if (dateComplete == "" || dateComplete == null)
        dateComplete = DateFormat('dd/MM/yyyy').format(new DateTime.now());
      body["date_complete"] = dateComplete;
      print(body);
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> workProjectForward(
      List<String> userForwardIds, String content) async {
    String url = linkService + 'congviec/forward';
    try {
      body.clear();
      body["work_id"] = AppCache.currentWorkProject.id;
      body["user_id"] = AppCache.currentUser.userId;
      body["user_forward_ids"] = userForwardIds.join(';');
      body["content"] = content;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> workProjectAdjourn(
      String workId, String dateComplete) async {
    String url = linkService + 'congviec/adjourn';
    try {
      body.clear();
      body["work_id"] = workId;
      body["user_id"] = AppCache.currentUser.userId;
      body["date_complete"] = dateComplete;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> workProjectAddImplementer() async {
    String url = linkService + 'congviec/addimplementer';
    try {
      body.clear();
      body["work_id"] = AppCache.currentWorkProject.id;
      body["user_id"] = AppCache.currentUser.userId;
      body["implementer_ids"] =
          AppCache.currentWorkProject.nguoiXuLysAdditional.join(';');
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentWorkProject.nguoiXuLys
            .addAll(AppCache.currentWorkProject.nguoiXuLysAdditional);
        AppCache.currentWorkProject.nguoiXuLysAdditional.clear();
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> workProjectAddSpectator() async {
    String url = linkService + 'congviec/addspectator';
    try {
      body.clear();
      body["work_id"] = AppCache.currentWorkProject.id;
      body["user_id"] = AppCache.currentUser.userId;
      body["spectator_ids"] =
          AppCache.currentWorkProject.nguoiDuocXemsAdditional.join(';');
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentWorkProject.nguoiDuocXems
            .addAll(AppCache.currentWorkProject.nguoiDuocXemsAdditional);
        AppCache.currentWorkProject.nguoiDuocXemsAdditional.clear();
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<String> calendarSaigonCoopPDF() async {
    String url = linkService + 'lichtuan/SaigonCoopPDF';
    try {
      body.clear();
      body["user_id"] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static Future<String> userGetLastLogin(String userId) async {
    String url = linkService + 'user/lastlogin';
    try {
      body.clear();
      body["user_id"] = userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        var arr = response.body.replaceAll('"', '').split('!@');
        return arr[0] + ObjectHelper.timeToTextChat(arr[1]);
      }
      return '';
    } on Exception {
      return '';
    }
  }

  static Future<bool> approveCalendar(String lichTuanIds) async {
    String url = linkService + 'lichtuan/approve';
    try {
      body.clear();
      body["ids"] = lichTuanIds;
      body["user_id"] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> cancelCalendar(String lichTuanId, String noiDung) async {
    String url = linkService + 'lichtuan/cancel';
    try {
      body.clear();
      body["id"] = lichTuanId;
      body["noi_dung"] = noiDung;
      body["user_id"] = AppCache.currentUser.userId;
      body["full_name"] = AppCache.currentUser.fullName;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> deleteCalendar(String lichTuanId, String noiDung) async {
    String url = linkService + 'lichtuan/delete';
    try {
      body.clear();
      body["id"] = lichTuanId;
      body["noi_dung"] = noiDung;
      body["user_id"] = AppCache.currentUser.userId;
      body["full_name"] = AppCache.currentUser.fullName;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<List<CalendarDay>> lichTuanHomNay() async {
    String url = linkService + 'lichtuan/homnay';
    try {
      final response = await http.get(Uri.parse(url)).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return CalendarDay.parseJson(response.body);
      } else {
        return <CalendarDay>[];
      }
    } on Exception {
      return <CalendarDay>[];
    }
  }

  static Future<List<CalendarDay>> lichTuanNgayMai() async {
    String url = linkService + 'lichtuan/ngaymai';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        return CalendarDay.parseJson(response.body);
      } else {
        return <CalendarDay>[];
      }
    } on Exception {
      return <CalendarDay>[];
    }
  }

  static Future<List<CalendarDay>> lichTuan(String date) async {
    String url = linkService + 'lichtuan/duocduyet?ngay=' + date;
    try {
      final response = await http.get(Uri.parse(url)).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return CalendarDay.parseJson(response.body);
      } else {
        return <CalendarDay>[];
      }
    } on Exception {
      return <CalendarDay>[];
    }
  }

  static Future<List<CalendarDay>> lichTuanChuaDuyet(String date) async {
    String url = linkService + 'lichtuan/chuaduyet?ngay=' + date;
    try {
      final response = await http.get(Uri.parse(url)).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return CalendarDay.parseJson(response.body);
      } else {
        return <CalendarDay>[];
      }
    } on Exception {
      return <CalendarDay>[];
    }
  }

  static Future<List<CalendarDay>> lichCaNhan(
      String fromDate, String toDate) async {
    String url = linkService +
        'lichcanhan/lietke?nguoitaoid=' +
        AppCache.currentUser.userId +
        '&ngaybatdau=' +
        fromDate +
        '&ngayketthuc=' +
        toDate;
    try {
      final response = await http.get(Uri.parse(url)).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return CalendarDay.parseJson(response.body);
      } else {
        return <CalendarDay>[];
      }
    } on Exception {
      return <CalendarDay>[];
    }
  }

  static Future<LichTuan> getLichTuanChiTiet(String lichTuanId) async {
    String url = linkService + 'lichtuan/detail';
    try {
      body.clear();
      body['lich_tuan_id'] = lichTuanId;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return LichTuan.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }

  static Future<List<DiscussWork>> disscusWorkGetList(
      String textSearch, int tick) async {
    String url = linkService + 'traodoi/list';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['text'] = textSearch;
      body['tick'] = tick.toString();

      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return DiscussWork.parseJson(response.body);
      } else {
        return <DiscussWork>[];
      }
    } on Exception {
      return <DiscussWork>[];
    }
  }

  static Future<List<ReportDaily>> getListReportDaily(
      String parentId, String childrenId, String textSearch, int tick) async {
    String url = linkService + 'baocaodinhky/list';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['parent_id'] = parentId;
      body['children_id'] = childrenId;
      body['text'] = textSearch;
      body['tick'] = tick.toString();

      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return ReportDaily.parseJson(response.body);
      } else {
        return <ReportDaily>[];
      }
    } on Exception {
      return <ReportDaily>[];
    }
  }

  static void setListCategoryReport(String userId) async {
    String url = linkService + 'baocaodinhky/listcategory';
    try {
      body.clear();
      body['user_id'] = userId;

      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        List<IdText> items = IdText.parseJson(response.body);
        AppCache.listParentReport =
            items.where((e) => e.parentId.isEmpty).toList();
        AppCache.listChildrenReport =
            items.where((e) => e.parentId.isNotEmpty).toList();
      }
    } on Exception {}
  }

  static Future<List<Announcement>> announcementGetList(
      String textSearch, int tick) async {
    String url = linkService + 'thongbao/list';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['text'] = textSearch;
      body['tick'] = tick.toString();

      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return Announcement.parseJson(response.body);
      } else {
        return <Announcement>[];
      }
    } on Exception {
      return <Announcement>[];
    }
  }

  static Future<List<String>> workProjectGetButtonActions() async {
    String url = linkService + 'congviec/actionsdetail';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return json.decode(response.body).cast<String>();
      } else {
        return <String>[];
      }
    } on Exception {
      return <String>[];
    }
  }

  static Future<List<int>> getCountNewDocument(Map<String, int> count) async {
    String url = linkService + 'vanban/CountNewByKind';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['count_VB'] = count['VBDE'].toString() +
          '-' +
          count['VBDI'].toString() +
          '-' +
          count['VBNO'].toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return json.decode(response.body).cast<int>();
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }

  static Future<bool> documentGetSource() async {
    String url = linkService + 'vanban/treesourcedocument';
    try {
      body.clear();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.allDocumentSource = CategoryDb.parseJson(response.body);
        return true;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  static Future<bool> documentGetDirectories() async {
    String url = linkService + 'vanban/treedirectories';
    try {
      body.clear();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.allDocumentDirectories = CategoryDb.parseJson(response.body);
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<String> documentGetNewOrderNumber(String kieuVB) async {
    String url = linkService + 'vanban/newordernumber';
    try {
      body.clear();
      body['kieuVB'] = kieuVB;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      } else {
        return "1";
      }
    } on Exception {
      return "1";
    }
  }

  static Future<List<Document>> documentGetList(
      String kind, String textSearch, int tick) async {
    String url = linkService + 'vanban/list';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['kind'] = kind;
      body['text'] = textSearch == null ? '' : textSearch.trim();
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return Document.parseJson(response.body);
      } else {
        return <Document>[];
      }
    } on Exception {
      return <Document>[];
    }
  }

  static Future<bool> documentInfo(String kind, int action) async {
    String url = linkService + 'vanban/detail';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['document_id'] = AppCache.currentDocumentDetail.id;
      body['kind'] = kind;
      body['action'] = action.toString();

      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        if (response.body == '[]') return true;
        if (action == 0) {
          List<String> arrImage = json.decode(response.body).cast<String>();
          AppCache.currentDocumentDetail.workProjectId = arrImage[0];
          arrImage.removeAt(0);
          AppCache.currentDocumentDetail.files =
              arrImage.map((p) => FileAttachment(p)).toList();
        }
        if (action == 1) {
          AppCache.currentDocumentDetail.infos =
              json.decode(response.body).cast<String>();
        }
        if (action == 2) {
          AppCache.currentDocumentDetail.viewerStatus =
              ViewerStatus.parseJson(response.body);
        }
        return true;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  static Future<List<WorkProject>> workProjectGetList(
      int kind, String textSearch, int tick) async {
    String url = linkService + 'congviec/list';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['kind'] = kind.toString();
      body['text'] = textSearch == null ? '' : textSearch.trim();
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return WorkProject.parseJson(response.body);
      } else {
        return <WorkProject>[];
      }
    } on Exception {
      return <WorkProject>[];
    }
  }

  static Future<List<ViewerStatus>> workProjectStatusGetList(int status) async {
    String url = linkService + 'congviec/status';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['status'] = status.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return ViewerStatus.parseJson(response.body);
      } else {
        return <ViewerStatus>[];
      }
    } on Exception {
      return <ViewerStatus>[];
    }
  }

  static Future<List<DiscussWorkMessage>> disscusWorkGetListMessage(
      int tick) async {
    String url = linkService + 'traodoi/messages';
    try {
      body.clear();
      body['discusswork_id'] = AppCache.currentDiscussWork.id;
      body['user_id'] = AppCache.currentUser.userId;
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return DiscussWorkMessage.parseJson(response.body);
      } else {
        return <DiscussWorkMessage>[];
      }
    } on Exception {
      return <DiscussWorkMessage>[];
    }
  }

  static Future<List<Comment>> commentGetListMessage(
      String kindComment, String fromId, int tick) async {
    String url = linkService + 'app/getcomments';
    try {
      body.clear();
      body['loai_comment'] = kindComment;
      body['from_id'] = fromId;
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return Comment.parseJson(response.body);
      } else {
        return <Comment>[];
      }
    } on Exception {
      return <Comment>[];
    }
  }

  static Future<List<WorkProjectMessage>> workProjectGetListMessage(
      int tick) async {
    String url = linkService + 'congviec/messages';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return WorkProjectMessage.parseJson(response.body);
      } else {
        return <WorkProjectMessage>[];
      }
    } on Exception {
      return <WorkProjectMessage>[];
    }
  }

  static Future<List<SignatureMessage>> signatureGetListMessage(
      int tick) async {
    String url = linkService + 'trinhky/messages';
    try {
      body.clear();
      body['trinhky_id'] = AppCache.currentSignature.id;
      body['user_id'] = AppCache.currentUser.userId;
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return SignatureMessage.parseJson(response.body);
      } else {
        return <SignatureMessage>[];
      }
    } on Exception {
      return <SignatureMessage>[];
    }
  }

  static Future<List<DiscussWorkMessage>> disscusWorkGetNewMessages(
      int maxTick) async {
    String url = linkService + 'traodoi/detailbytime';
    try {
      body.clear();
      body['discusswork_id'] = AppCache.currentDiscussWork.id;
      body['user_id'] = AppCache.currentUser.userId;
      body['tick'] = maxTick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return DiscussWorkMessage.parseJson(response.body);
      } else {
        return <DiscussWorkMessage>[];
      }
    } on Exception {
      return <DiscussWorkMessage>[];
    }
  }

  static Future<List<WorkProjectMessage>> workProjectGetNewMessage(
      int maxTick) async {
    if (AppCache.currentWorkProject.id == null) return <WorkProjectMessage>[];
    String url = linkService + 'congviec/detailbytime';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      body['tick'] = maxTick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return WorkProjectMessage.parseJson(response.body);
      } else {
        return <WorkProjectMessage>[];
      }
    } on Exception {
      return <WorkProjectMessage>[];
    }
  }

  static Future<List<Object>> checkExistNewMessage(
      String objectId, String kind, int index) async {
    List<Object> results = [];
    results.add(index);
    String url = linkService + 'app/CheckNewMessage';
    try {
      body.clear();
      body["object_id"] = objectId;
      body["kind"] = kind;
      body["user_id"] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        results.add(response.body.replaceAll('"', ''));
      }
    } on Exception {}
    return results;
  }

  static Future<String> commentInsertMessage(
      String kindComment, String fromId, String noiDung) async {
    String url = linkService + 'app/insertcomment';
    try {
      body.clear();
      body["from_id"] = fromId;
      body["loai_comment"] = kindComment;
      body["noi_dung"] = noiDung;
      body["user_id"] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static Future<String> discussWorkSendMessage(
      String chuDe, String noiDung) async {
    String url = linkService + 'traodoi/addmessage';
    try {
      body.clear();
      body["discusswork_id"] = AppCache.currentDiscussWork.id;
      body["chude"] = chuDe;
      body["noidung"] = noiDung;
      body["user_id"] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static Future<String> workProjectSendMessage(
      String chuDe, String noiDung) async {
    String url = linkService + 'congviec/addmessage';
    try {
      body.clear();
      body["work_id"] = AppCache.currentWorkProject.id;
      body["chude"] = chuDe;
      body["noidung"] = noiDung;
      body["user_id"] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static Future<String> signatureSendMessage(
      String chuDe, String noiDung) async {
    String url = linkService + 'trinhky/addmessage';
    try {
      body.clear();
      body["trinhky_id"] = AppCache.currentSignature.id;
      body["chude"] = chuDe;
      body["noidung"] = noiDung;
      body["user_id"] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static Future<String> discussWorkSave() async {
    String url = linkService + 'traodoi/save';
    try {
      AppCache.currentDiscussWork.creator = AppCache.currentUser.userId;
      String jsonText = jsonEncode(AppCache.currentDiscussWork);
      body.clear();
      body["data"] = ObjectHelper.toBase64(jsonText);
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      } else {
        return '';
      }
    } on Exception {
      return '';
    }
  }

  static Future<String> announcementSave() async {
    String url = linkService + 'thongbao/save';
    try {
      AppCache.currentAnnouncement.creator = AppCache.currentUser.userId;
      String jsonText = jsonEncode(AppCache.currentAnnouncement);
      body.clear();
      body["data"] = ObjectHelper.toBase64(jsonText);
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      } else {
        return '';
      }
    } on Exception {
      return '';
    }
  }

  static Future<String> reportDailySave() async {
    String url = linkService + 'baocaodinhky/save';
    try {
      AppCache.currentReportDaily.creator = AppCache.currentUser.userId;
      String jsonText = jsonEncode(AppCache.currentReportDaily);
      body.clear();
      body["data"] = ObjectHelper.toBase64(jsonText);
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', '');
      } else {
        return '';
      }
    } on Exception {
      return '';
    }
  }

  static Future<WorkProject> workProjectGetById(String id) async {
    String url = linkService + 'congviec/detail';
    try {
      body.clear();
      body['work_id'] = id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return WorkProject.fromJsonDetail(json.decode(response.body));
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }

  static Future<String> checkIfDocsIsWorkProject(String id) async {
    String url = linkService + 'VanBan/IsGeneratedToTask';
    try {
      body.clear();
      body['msvb'] = id;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result.IsFound)
          return result.mscv;
        else
          return null;
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }

  static Future<bool> announcementGetDetail() async {
    String url = linkService + 'thongbao/detail';
    try {
      body.clear();
      body['announcement_id'] = AppCache.currentAnnouncement.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentAnnouncement =
            Announcement.fromJsonDetail(json.decode(response.body));
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> signatureGetDetail() async {
    String url = linkService + 'trinhky/detail';
    try {
      body.clear();
      body['trinhky_id'] = AppCache.currentSignature.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentSignature =
            Signature.fromJsonDetail(json.decode(response.body));
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> reportDailyGetDetail() async {
    String url = linkService + 'baocaodinhky/detail';
    try {
      body.clear();
      body['report_id'] = AppCache.currentReportDaily.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentReportDaily =
            ReportDaily.fromJsonDetail(json.decode(response.body));
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> signatureGetViewerStatus() async {
    String url = linkService + 'trinhky/viewerstatus';
    try {
      body.clear();
      body['trinhky_id'] = AppCache.currentSignature.id;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentSignature.viewerStatus =
            ViewerStatus.parseJson(response.body);
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> announcementGetViewerStatus() async {
    String url = linkService + 'thongbao/viewerstatus';
    try {
      body.clear();
      body['announcement_id'] = AppCache.currentAnnouncement.id;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentAnnouncement.viewerStatus =
            ViewerStatus.parseJson(response.body);
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> reportDailyGetViewerStatus(String childrenId) async {
    String url = linkService + 'baocaodinhky/viewerstatus';
    try {
      body.clear();
      body['muc_bao_cao_id'] = childrenId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        AppCache.currentReportDaily.viewerStatus =
            ViewerStatus.parseJson(response.body);
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<List<Signature>> signatureGetList(
      String textSearch, int tick) async {
    String url = linkService + 'trinhky/list';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['text'] = textSearch;
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return Signature.parseJson(response.body);
      } else {
        return [];
      }
    } on Exception {
      return [];
    }
  }

  static Future<List<int>> signatureGetCountMessage(
      String signatureId, int index) async {
    String url = linkService + 'trinhky/countmessage';
    try {
      body.clear();
      body['trinhky_id'] = signatureId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return [index, int.parse(response.body)];
      } else {
        return [];
      }
    } on Exception {
      return [];
    }
  }

  static Future<bool> signatureFinish() async {
    String url = linkService + 'trinhky/finish';
    try {
      body.clear();
      body['trinhky_id'] = AppCache.currentSignature.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<List<Library>> libraryGetList(
      String folderId, String textSearch, int tick) async {
    String url = linkService + 'thuvien/list';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['folder_id'] = folderId;
      body['text'] = textSearch;
      body['tick'] = tick.toString();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return Library.parseJson(response.body);
      } else {
        return [];
      }
    } on Exception {
      return [];
    }
  }

  static Future<Library> libraryGetDetailById(String id) async {
    String url = linkService + 'thuvien/detail';
    try {
      body.clear();
      body['thuvien_id'] = id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return Library.fromJsonDetail(json.decode(response.body));
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }

  static Future<List<IdText>> libraryGetFolders() async {
    String url = linkService + 'thuvien/listfolder';
    try {
      body.clear();
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return IdText.parseJson(response.body);
      } else {
        return [];
      }
    } on Exception {
      return [];
    }
  }

  static Future<DiscussWork> getDiscussWorkById(String id) async {
    String url = linkService + 'traodoi/detail';
    try {
      body.clear();
      body['discuss_work_id'] = id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return DiscussWork.fromJsonDetail(json.decode(response.body));
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }

  static Future<bool> deleteDiscussWork(String id) async {
    if (id == null || id.isEmpty) return true;
    String url = linkService + 'traodoi/delete';
    try {
      body.clear();
      body['discusswork_id'] = id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> deleteAnnouncement(String id) async {
    if (id == null || id.isEmpty) return true;
    String url = linkService + 'thongbao/delete';
    try {
      body.clear();
      body['announcement_id'] = id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> workProjectChangeMainPeople(String mainPeopleId) async {
    String url = linkService + 'congviec/changemainpeople';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      body['main_people_id'] = mainPeopleId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> doneWorkProject() async {
    String url = linkService + 'congviec/done';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> proposeFinishWorkProject() async {
    String url = linkService + 'congviec/proposefinish';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> finishWorkProject() async {
    String url = linkService + 'congviec/finish';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<bool> deleteWorkProject() async {
    String url = linkService + 'congviec/delete';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static workProjectRemindNew() async {
    String url = linkService + 'congviec/remindnew';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static workProjectRemoveNewRemind() async {
    String url = linkService + 'congviec/removeremindnew';
    try {
      body.clear();
      body['work_id'] = AppCache.currentWorkProject.id;
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  // static Future<List<int>> getBadgeNumberTab() async {
  //   String url = linkService + 'app/getcountnew';
  //   try {
  //     body.clear();
  //     body['user_id'] = AppCache.currentUser.userId;
  //     final response =
  //         await http.post(url, body: body).timeout(durationTimeout);
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body).cast<int>();
  //     }
  //     return null;
  //   } on Exception {
  //     return null;
  //   }
  // }

  static Future<List<int>> getBadgeNumberApp() async {
    String url = linkService + 'app/getcountnew';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return json.decode(response.body).cast<int>();
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static Future<List<int>> workProjectGetCountNew(Iterable<int> counts) async {
    String url = linkService + 'congviec/CountNewByKind';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      body['count_Work'] = counts.join('-');
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return json.decode(response.body).cast<int>();
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }

  static Future<List<int>> dashboardGetCount() async {
    String url = linkService + 'app/CountDashboard';
    try {
      body.clear();
      body['user_id'] = AppCache.currentUser.userId;
      final response =
          await http.post(Uri.parse(url), body: body).timeout(durationTimeout);
      if (response.statusCode == 200) {
        return json.decode(response.body).cast<int>();
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }
}
