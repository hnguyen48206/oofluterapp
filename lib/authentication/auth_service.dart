import 'dart:async';
import 'dart:convert';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> login(
      String imei, String os, String username, String password) async {
    AppCache.currentUser = await FetchService.login(
        username, password, AppCache.tokenFCM, imei, os);

    if (AppCache.currentUser.error == null) {
      store(
          username,
          password,
          FetchService.linkService,
          AppCache.currentUser.isWebAPPv2,
          AppCache.currentUser.webAPPv2LoginToken);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    if (AppCache.currentUser.isOldVersion) {
      await FetchService.deleteTokenOld();
    } else {
      await FetchService.deleteTokenNew();
    }
    AppCache.currentUser = Account();
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('password');
  }

  Future<void> store(
      String username, String password, String url, bool isWebAPPv2,
      [String webAPPv2LoginToken]) async {
    AppCache.currentUser.password = password;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
    prefs.setString('url', url);
    if (AppCache.currentUser.userId.isNotEmpty)
      prefs.setString('accountOO', json.encode(AppCache.currentUser.toJson()));
    if (isWebAPPv2) prefs.setBool('isWebAPPv2', isWebAPPv2);
    if (webAPPv2LoginToken != '')
      prefs.setString('webAPPv2LoginToken', webAPPv2LoginToken);

    return;
  }

  Future<void> changePass(String password) async {
    AppCache.currentUser.password = password;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
    return;
  }

  Future<void> reset() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('username', null);
    prefs.setString('password', null);
    prefs.setString('url', null);
    prefs.setString('accountOO', null);
    return;
  }

  Future<bool> avaliable() async {
    var prefs = await SharedPreferences.getInstance();
    bool stayLoggedin = prefs.getBool('stayLoggedIn');
    if (stayLoggedin == null) stayLoggedin = true;
    prefs.setBool('stayLoggedIn', stayLoggedin);
    return stayLoggedin;
  }
}
