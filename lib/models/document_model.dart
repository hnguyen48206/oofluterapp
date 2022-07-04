import 'dart:convert';

import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

class Document {
  String id = '';
  String soThuTu = '';
  String code;
  String noiGui = '';
  String luuHoSo = '';
  String ngayNhan = '';
  String ngayGui = '';
  String ngayKy = '';
  String noiPhatHanh = '';
  String thoiHanXuLy = '';
  String nguoiXuLy = '';
  String chuDe = '';
  int loaiVanBan = 0;
  int nguonVanBan = 0;
  String nguoiKy = '';
  String noiNhan = '';
  String noiSoanThao = '';
  String tinhTrangXyLy = '';
  String phucVanBanSo = '';
  String trichYeu = '';
  String nguoiTao = '';
  String xuLyVB = '';
  String kieuVB = '';
  String phapLy = '';
  String vbLienThong = '';
  String ghiChu = '';
  String loaiNoiNhan = '';
  int soLuongBan = 0;

  int tick;
  bool hasNewMessage = false;
  List<String> nguoiDuocXems = <String>[];
  List<Account> userDuocXems = <Account>[];
  List<String> fileDinhKems = <String>[];
  List<FileAttachment> files = <FileAttachment>[];

  Document(this.id);

  Document.fromJsonList(Map<String, dynamic> json) {
    id = json['AUTO_ID'];
    code = json['VANBAN_ID'];
    trichYeu = json['TRICH_YEU'];
    ngayGui = json['NgayPhatHanh'];
    nguoiTao = json['NGUOI_TAO'];
    noiNhan = json['NOI_NHAN'];
    noiSoanThao = json['NOI_SOAN_THAO'];
    tick = json['Tick'];
    hasNewMessage = false;
  }

  Document.fromJsonDetail(Map<String, dynamic> json) {
    id = json['AUTO_ID'];
    soThuTu = json['SOTHUTU'];
    code = json['VANBAN_ID'];
    noiGui = json['NOIGUI'];
    luuHoSo = json['LUU_HOSO'];
    ngayNhan = json['NgayNhanText'];
    ngayGui = json['NgayPhatHanh'];
    ngayKy = json['NgayKyText'];
    noiPhatHanh = json['NOI_PHAT_HANH'];
    thoiHanXuLy = json['ThoiHanXuLy'];
    nguoiXuLy = json['NGUOI_XULY'];
    chuDe = json['CHUDE'];
    loaiVanBan = json['LOAIVANBAN'];
    nguonVanBan = json['NGUONVB'];
    nguoiKy = json['NGUOI_KY'];
    noiNhan = json['NOI_NHAN'];
    noiSoanThao = json['NOI_SOAN_THAO'];
    tinhTrangXyLy = json['TINH_TRANG_XU_LY'];
    phucVanBanSo = json['PHUC_VANBAN_SO'];
    trichYeu = json['TRICH_YEU'];
    nguoiTao = json['NGUOI_TAO'];
    xuLyVB = json['XU_LY_VB'];
    kieuVB = json['KIEUVB'];
    phapLy = json['PHAPLY'];
    vbLienThong = json['VB_LIEN_THONG'];
    ghiChu = json['GHI_CHU'];
    loaiNoiNhan = json['Loai_Noi_Nhan'];
    soLuongBan = json['So_Luong_Ban'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AUTO_ID'] = this.id;
    data['SOTHUTU'] = this.soThuTu;
    data['VANBAN_ID'] = this.code;
    data['NOIGUI'] = this.noiGui;
    data['LUU_HOSO'] = this.luuHoSo;
    data['NgayNhanInput'] = this.ngayNhan;
    data['NgayGuiInput'] = this.ngayGui;
    data['NgayKyInput'] = this.ngayKy;
    data['NOI_PHAT_HANH'] = this.noiPhatHanh;
    data['ThoiHanXuLyInput'] = this.thoiHanXuLy;
    data['NGUOI_XULY'] = this.nguoiXuLy;
    data['CHUDE'] = this.chuDe;
    data['LOAIVANBAN'] = this.loaiVanBan;
    data['NGUONVB'] = this.nguonVanBan;
    data['NGUOI_KY'] = this.nguoiKy;
    data['NOI_NHAN'] = this.noiNhan;
    data['NOI_SOAN_THAO'] = this.noiSoanThao;
    // data['TINH_TRANG_XU_LY'] = this.tinhTrangXuLy;
    data['PHUC_VANBAN_SO'] = this.phucVanBanSo;
    data['TRICH_YEU'] = this.trichYeu;
    data['NGUOI_TAO'] = this.nguoiTao;
    data['XU_LY_VB'] = this.xuLyVB;
    data['KIEUVB'] = this.kieuVB;
    data['PHAPLY'] = this.phapLy;
    data['VB_LIEN_THONG'] = this.vbLienThong;
    data['GHI_CHU'] = this.ghiChu;
    data['Loai_Noi_Nhan'] = this.loaiNoiNhan;
    data['So_Luong_Ban'] = this.soLuongBan;
    data['nguoiXems'] = this.nguoiDuocXems;
    return data;
  }

  static List<Document> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Document>((json) => Document.fromJsonList(json)).toList();
  }
}

class DocumentDetail {
  String id;
  List<FileAttachment> files = [];
  List<String> infos = [];
  List<ViewerStatus> viewerStatus = [];
  String workProjectId = '';

  DocumentDetail(this.id);
}
