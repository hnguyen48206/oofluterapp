import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/announcement/announcement_create_step2.dart';
import 'package:onlineoffice_flutter/calendar/calendar_create_step3.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_create_step2.dart';
import 'package:onlineoffice_flutter/document/document_create_step4.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:onlineoffice_flutter/work_project/work_project_add_implementer.dart';
import 'package:onlineoffice_flutter/work_project/work_project_add_spectator.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step2.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step3.dart';
import 'package:onlineoffice_flutter/work_project/work_project_forward.dart';

class GroupUserListPageState extends State<GroupUserListPage> {
  String title = "Chọn Bộ Phận - Phòng Ban";
  String groupId;

  List<GroupUser> listGroup = AppCache.allGroupUser;
  List<Account> listUser = <Account>[];

  reloadByGroupId(String groupId) {
    setState(() {
      this.groupId = groupId;
      if (groupId == null) {
        this.title = "Chọn Bộ Phận - Phòng Ban";
        this.listGroup = AppCache.allGroupUser;
      } else {
        GroupUser group =
            this.listGroup.singleWhere((i) => i.groupId == groupId);
        this.title = group.groupName;
        this.listGroup = group.children;
        this.listUser = group.listUser;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // this.context = context;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppCache.colorApp,
          title: new Center(
            child: new Text(
              this.title,
              style: new TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          )),
      body: Container(
          child: ListView.separated(
              itemCount: this.listGroup.length + this.listUser.length,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.black),
              itemBuilder: (context, index) {
                if (index < this.listGroup.length) {
                  return getLayoutGroup(this.listGroup[index]);
                }
                return getLayoutUser(
                    this.listUser[index - this.listGroup.length]);
              })),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          recallAction();
        },
        child: Icon(Icons.send, color: Colors.white),
      ),
    );
  }

  recallAction() {
    if (widget.kindAction == KindAction.WeekCalendar) {
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => CalendarCreateStep3Page()));
      return;
    }
    if (widget.kindAction == KindAction.DiscussWork) {
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => DiscussWorkCreateStep2Page()));
      return;
    }
    if (widget.kindAction == KindAction.Announcement) {
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => AnnouncementCreateStep2Page()));
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiXuLy) {
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => WorkProjectCreateStep2Page()));
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiXuLyAdditional) {
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => WorkProjectAddImplementer()));
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiDuocXem) {
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => WorkProjectCreateStep3Page()));
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiDuocXemAdditional) {
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => WorkProjectAddSpectator()));
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiChuyenTiep) {
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => WorkProjectForwardPage()));
      return;
    }
    if (widget.kindAction == KindAction.DocumentNguoiDuocXem) {
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => DocumentCreateStep4Page()));
      return;
    }
  }

  Widget getLayoutGroup(GroupUser group) {
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(group.avatar),
        ),
        title: Text(group.groupName),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          this.reloadByGroupId(group.groupId);
        });
  }

  setChecked(bool isChecked, Account user) {
    if (widget.kindAction == KindAction.WeekCalendar) {
      if (isChecked == true) {
        if (AppCache.currentCalendar.nguoiThamGias.contains(user.userId) ==
            false) {
          AppCache.currentCalendar.nguoiThamGias.add(user.userId);
        }
      } else {
        if (AppCache.currentCalendar.nguoiThamGias.contains(user.userId) ==
            true) {
          AppCache.currentCalendar.nguoiThamGias.remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.DiscussWork) {
      if (isChecked == true) {
        if (AppCache.currentDiscussWork.nguoiThamGias.contains(user.userId) ==
            false) {
          AppCache.currentDiscussWork.nguoiThamGias.add(user.userId);
        }
      } else {
        if (AppCache.currentDiscussWork.nguoiThamGias.contains(user.userId) ==
            true) {
          AppCache.currentDiscussWork.nguoiThamGias.remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.Announcement) {
      if (isChecked == true) {
        if (AppCache.currentAnnouncement.nguoiDuocXems.contains(user.userId) ==
            false) {
          AppCache.currentAnnouncement.nguoiDuocXems.add(user.userId);
        }
      } else {
        if (AppCache.currentAnnouncement.nguoiDuocXems.contains(user.userId) ==
            true) {
          AppCache.currentAnnouncement.nguoiDuocXems.remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiXuLy) {
      if (isChecked == true) {
        if (AppCache.currentWorkProject.nguoiXuLys.contains(user.userId) ==
            false) {
          AppCache.currentWorkProject.nguoiXuLys.add(user.userId);
        }
      } else {
        if (AppCache.currentWorkProject.nguoiXuLys.contains(user.userId) ==
            true) {
          AppCache.currentWorkProject.nguoiXuLys.remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiXuLyAdditional) {
      if (isChecked == true) {
        if (AppCache.currentWorkProject.nguoiXuLysAdditional
                .contains(user.userId) ==
            false) {
          AppCache.currentWorkProject.nguoiXuLysAdditional.add(user.userId);
        }
      } else {
        if (AppCache.currentWorkProject.nguoiXuLysAdditional
                .contains(user.userId) ==
            true) {
          AppCache.currentWorkProject.nguoiXuLysAdditional.remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiDuocXem) {
      if (isChecked == true) {
        if (AppCache.currentWorkProject.nguoiDuocXems.contains(user.userId) ==
            false) {
          AppCache.currentWorkProject.nguoiDuocXems.add(user.userId);
        }
      } else {
        if (AppCache.currentWorkProject.nguoiDuocXems.contains(user.userId) ==
            true) {
          AppCache.currentWorkProject.nguoiDuocXems.remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiDuocXemAdditional) {
      if (isChecked == true) {
        if (AppCache.currentWorkProject.nguoiDuocXemsAdditional
                .contains(user.userId) ==
            false) {
          AppCache.currentWorkProject.nguoiDuocXemsAdditional.add(user.userId);
        }
      } else {
        if (AppCache.currentWorkProject.nguoiDuocXemsAdditional
                .contains(user.userId) ==
            true) {
          AppCache.currentWorkProject.nguoiDuocXemsAdditional
              .remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiChuyenTiep) {
      if (isChecked == true) {
        if (AppCache.currentWorkProject.nguoiChuyenTieps
                .contains(user.userId) ==
            false) {
          AppCache.currentWorkProject.nguoiChuyenTieps.add(user.userId);
        }
      } else {
        if (AppCache.currentWorkProject.nguoiChuyenTieps
                .contains(user.userId) ==
            true) {
          AppCache.currentWorkProject.nguoiChuyenTieps.remove(user.userId);
        }
      }
      return;
    }
    if (widget.kindAction == KindAction.DocumentNguoiDuocXem) {
      if (isChecked == true) {
        if (AppCache.currentDocument.nguoiDuocXems.contains(user.userId) ==
            false) {
          AppCache.currentDocument.nguoiDuocXems.add(user.userId);
        }
      } else {
        if (AppCache.currentDocument.nguoiDuocXems.contains(user.userId) ==
            true) {
          AppCache.currentDocument.nguoiDuocXems.remove(user.userId);
        }
      }
      return;
    }
  }

  Widget getLayoutUser(Account user) {
    if (widget.kindAction == KindAction.WeekCalendar) {
      user.checked =
          AppCache.currentCalendar.nguoiThamGias.contains(user.userId);
    }
    if (widget.kindAction == KindAction.DiscussWork) {
      user.checked =
          AppCache.currentDiscussWork.nguoiThamGias.contains(user.userId);
    }
    if (widget.kindAction == KindAction.Announcement) {
      user.checked =
          AppCache.currentAnnouncement.nguoiDuocXems.contains(user.userId);
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiXuLy) {
      user.checked =
          AppCache.currentWorkProject.nguoiXuLys.contains(user.userId);
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiXuLyAdditional) {
      user.checked = AppCache.currentWorkProject.nguoiXuLysAdditional
          .contains(user.userId);
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiDuocXem) {
      user.checked =
          AppCache.currentWorkProject.nguoiDuocXems.contains(user.userId);
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiDuocXemAdditional) {
      user.checked = AppCache.currentWorkProject.nguoiDuocXemsAdditional
          .contains(user.userId);
    }
    if (widget.kindAction == KindAction.WorkProjectNguoiChuyenTiep) {
      user.checked =
          AppCache.currentWorkProject.nguoiChuyenTieps.contains(user.userId);
    }
    if (widget.kindAction == KindAction.DocumentNguoiDuocXem) {
      user.checked =
          AppCache.currentDocument.nguoiDuocXems.contains(user.userId);
    }
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatar),
        ),
        title: Text(user.fullName),
        trailing: Checkbox(
          value: user.checked,
          tristate: true,
          activeColor: Colors.blue,
          checkColor: Colors.lightBlueAccent,
          onChanged: (val) {
            setState(() {
              setChecked(val, user);
            });
          },
        )
        // , onTap: () {}
        );
  }
}

class GroupUserListPage extends StatefulWidget {
  final KindAction kindAction;

  GroupUserListPage({this.kindAction});

  @override
  State<StatefulWidget> createState() {
    return GroupUserListPageState();
  }
}
