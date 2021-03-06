import 'dart:convert';

class GroupUser {
  String groupId;
  String groupName;
  String avatar;
  bool checked;
  List<GroupUser> children;
  List<Account> listUser;

  GroupUser({this.groupId, this.groupName, this.children, this.listUser});

  GroupUser.fromJson(Map<String, dynamic> json) {
    groupId = json['GroupId'];
    groupName = json['GroupName'];
    avatar = json['Avatar'];
    checked = false;
    children = <GroupUser>[];
    listUser = <Account>[];

    if (json['Children'] != null) {
      json['Children'].forEach((v) {
        children.add(new GroupUser.fromJson(v));
      });
    }

    if (json['ListUser'] != null) {
      json['ListUser'].forEach((v) {
        listUser.add(new Account.fromJson(v));
      });
    }
  }

  static List<GroupUser> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<GroupUser>((json) => GroupUser.fromJson(json)).toList();
  }
}

class Role {
  String roleId;
  String roleName;

  Role({this.roleId, this.roleName});

  Role.fromJson(Map<String, dynamic> json) {
    roleId = json['Right_ID'];
    roleName = json['Right_Name'];
  }

  static List<Role> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Role>((json) => Role.fromJson(json)).toList();
  }
}

class Account {
  String userId = '';
  String userName;
  String password;
  String fullName;
  String avatar;
  String picture;
  String groupId = '';
  String roleName = '';
  String birthDay = '';
  String email = '';
  String phone = '';
  String lastLogin = '';
  List<String> modulesActive = [];
  bool checked = false;
  bool isOldVersion = false;
  String error;

  Account();

  Account.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    userName = json['UserName'];
    if (json['Password'] != null) {
      password = json['Password'];
    }
    fullName = json['FullName'];
    avatar = json['Avatar'];
    if (json['Picture'] != null) {
      picture = json['Picture'];
    } else {
      picture = avatar;
    }
    if (json['GroupId'] != null) {
      groupId = json['GroupId'];
    }
    if (json['RoleName'] != null) {
      roleName = json['RoleName'];
    }
    if (json['BirthDay'] != null) {
      birthDay = json['BirthDay'];
    }
    if (json['Email'] != null) {
      email = json['Email'];
    }
    if (json['Phone'] != null) {
      phone = json['Phone'];
    }
    if (json['ModulesActive'] != null) {
      modulesActive = json['ModulesActive'].toString().split(';');
    }
    if (json['IsOldVersion'] != null) {
      isOldVersion = json['IsOldVersion'];
    } else {
      isOldVersion = false;
    }
    checked = false;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserId'] = userId;
    data['UserName'] = userName;
    data['Password'] = password;
    data['FullName'] = fullName;
    data['Avatar'] = avatar;
    data['Picture'] = picture;
    data['GroupId'] = groupId;
    data['RoleName'] = roleName;
    data['BirthDay'] = birthDay;
    data['Email'] = email;
    data['Phone'] = phone;
    data['ModulesActive'] = modulesActive.join(';');
    data['IsOldVersion'] = isOldVersion;
    return data;
  }

  static List<Account> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Account>((json) => Account.fromJson(json)).toList();
  }
}
