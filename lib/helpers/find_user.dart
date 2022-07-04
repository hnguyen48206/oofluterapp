import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/announcement/announcement_create_step2.dart';
import 'package:onlineoffice_flutter/calendar/calendar_create_step3.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_create_step2.dart';
import 'package:onlineoffice_flutter/document/document_create_step4.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/models/user_group_model.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:onlineoffice_flutter/work_project/work_project_add_implementer.dart';
import 'package:onlineoffice_flutter/work_project/work_project_add_spectator.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step2.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step3.dart';
import 'package:onlineoffice_flutter/work_project/work_project_forward.dart';

class FindUserPageState extends State<FindUserPage> {
  // String title = "Chọn Người Liên Quan";

  List<Account> listUser = AppCache.allUser;
  SearchBar searchBar;
  TextEditingController searchController;

  void submitSearch(String text) {
    // this.searchController.text = text;
    if (text.isEmpty) {
      setState(() {
        listUser = AppCache.allUser;
      });
    } else {
      text = text.toLowerCase();
      setState(() {
        listUser = AppCache.allUser
            .where((p) =>
                p.fullName.toLowerCase().contains(text) ||
                ObjectHelper.convertToUnSign(p.fullName.toLowerCase())
                    .contains(text))
            .toList();
      });
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: true,
        title: new Text(
            this.searchController.text.isEmpty
                ? 'Tìm theo tên ...'
                : this.searchController.text,
            style: TextStyle(color: Colors.white)),
        actions: [searchBar.getSearchAction(context)]);
  }

  @override
  void initState() {
    super.initState();
    this.searchController = new TextEditingController(text: '');
    this.searchBar = new SearchBar(
        inBar: false,
        // colorBackButton: false,
        controller: this.searchController,
        hintText: 'Tìm theo tên ...',
        setState: setState,
        onSubmitted: submitSearch,
        onChanged: submitSearch,
        onCleared: () {
          submitSearch('');
        },
        clearOnSubmit: false,
        buildDefaultAppBar: buildAppBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: Container(
          child: ListView.separated(
              itemCount: this.listUser.length + 2,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.black),
              itemBuilder: (context, index) {
                if (index < this.listUser.length) {
                  return getLayoutUser(this.listUser[index]);
                } else {
                  return ListTile();
                }
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
    if (widget.kindAction == KindAction.WorkProjectNguoiDuocXem) {
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

class FindUserPage extends StatefulWidget {
  final KindAction kindAction;

  FindUserPage({this.kindAction});

  @override
  State<StatefulWidget> createState() {
    return FindUserPageState();
  }
}
