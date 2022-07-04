import 'dart:convert';
import 'package:onlineoffice_flutter/models/models_ext.dart';

class LichTuan {
  String lichTuanId = '';
  String ngaytao = '';
  String nguoiDangKy = '';
  String chutri = '';
  String thoigian = '';
  String thoigianbatdau = '';
  String tgbatdau = '';
  String thoigianketthuc = '';
  String tgketthuc = '';
  String noidung = '';
  String pheduyet = '';
  String nguoiPheduyet = '';
  String ngaypheduyet = '';
  String chuanbi = '';
  String khachmoi = '';
  String diadiem = '';
  String ghichu = '';
  String thanhphan = '';
  String hopkhan = '';
  String huy = '';
  String ngayhuy = '';
  String nguoihuy = '';
  String fullName = '';

  List<String> nguoiThamGias = [];

  List<String> buttons = [];

  List<String> fileDinhKems = [];

  List<FileAttachment> files = [];

  LichTuan();

  LichTuan.fromJson(Map<String, dynamic> json) {
    lichTuanId = json['lich_tuan_id'];
    ngaytao = json['ngaytao'];
    nguoiDangKy = json['nguoi_dang_ky'];
    chutri = json['chutri'];
    thoigian = json['thoigian'];
    thoigianbatdau = json['thoigianbatdau'];
    tgbatdau = json['tgbatdau'];
    thoigianketthuc = json['thoigianketthuc'];
    tgketthuc = json['tgketthuc'];
    noidung = json['noidung'];
    pheduyet = json['pheduyet'];
    nguoiPheduyet = json['nguoi_pheduyet'];
    ngaypheduyet = json['NGAY_PHEDUYET'];
    chuanbi = json['chuanbi'];
    khachmoi = json['khachmoi'];
    diadiem = json['diadiem'];
    ghichu = json['ghichu'];
    thanhphan = json['thanhphan'];
    hopkhan = json['hopkhan'];
    huy = json['huy'];
    ngayhuy = json['ngayhuy'];
    nguoihuy = json['nguoihuy'];
    fullName = json['full_name'];
    nguoiThamGias = json['nguoixulys'].cast<String>();
    buttons = json['buttons'].cast<String>();
    fileDinhKems = json['filedinhkems'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lich_tuan_id'] = this.lichTuanId;
    data['ngaytao'] = this.ngaytao;
    data['nguoi_dang_ky'] = this.nguoiDangKy;
    data['chutri'] = this.chutri;
    data['thoigianbatdau'] = this.thoigianbatdau;
    data['tgbatdau'] = this.tgbatdau;
    data['thoigianketthuc'] = this.thoigianketthuc;
    data['tgketthuc'] = this.tgketthuc;
    if (this.noidung != null && this.noidung.isNotEmpty) {
      data['noidung'] = this.noidung.replaceAll('\n', '<br/>');
    }
    data['pheduyet'] = this.pheduyet;
    data['nguoi_pheduyet'] = this.nguoiPheduyet;
    data['NGAY_PHEDUYET'] = this.ngaypheduyet;
    data['chuanbi'] = this.chuanbi;
    data['khachmoi'] = this.khachmoi;
    data['diadiem'] = this.diadiem;
    data['ghichu'] = this.ghichu;
    data['thanhphan'] = this.thanhphan;
    data['hopkhan'] = this.hopkhan;
    data['huy'] = this.huy;
    data['ngayhuy'] = this.ngayhuy;
    data['nguoihuy'] = this.nguoihuy;
    data['full_name'] = this.fullName;
    data['nguoixulys'] = this.nguoiThamGias;
    data['buttons'] = this.buttons;
    data['filedinhkems'] = this.fileDinhKems;
    return data;
  }

  static List<LichTuan> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<LichTuan>((json) => LichTuan.fromJson(json)).toList();
  }
}

class CalendarDay {
  String weekOfDay;
  String day;
  List<CalendarDetail> details;

  CalendarDay(this.weekOfDay, this.day, this.details);

  CalendarDay.fromJson(Map<String, dynamic> json) {
    weekOfDay = json['Thu'];
    day = json['Ngay'];
    details = (json['Data'] as List)
        ?.map((e) => e == null
            ? null
            : CalendarDetail.fromJson(e as Map<String, dynamic>))
        ?.toList();
  }

  static List<CalendarDay> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<CalendarDay>((json) => CalendarDay.fromJson(json))
        .toList();
  }
}

class CalendarDetail {
  String id;
  String title;
  String mainPeople;
  String members;
  String content;
  String address;
  String start;
  String end;
  String status;
  bool checked;

  CalendarDetail(this.id, this.title, this.mainPeople, this.members,
      this.content, this.address, this.start, this.end, this.status);

  CalendarDetail.fromJson(Map<String, dynamic> json) {
    id = json['LichTuanId'];
    title = json['NoiDung'];
    mainPeople = json['ChuTri'];
    members = json['ThanhPhan'];
    content = json['GhiChu'];
    address = json['DiaDiem'];
    start = json['GioBatDau'];
    end = json['GioKetThuc'];
    status = json['PheDuyet'];
    checked = false;
  }
}
