import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dashboard.dart';
import 'package:onlineoffice_flutter/dashboard_web.dart';
import 'package:onlineoffice_flutter/document/document_list.dart';
import 'package:onlineoffice_flutter/helpers/app_helpers.dart';
import 'package:onlineoffice_flutter/helpers/web_tab_viewer.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/calendar/calendar_list.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/menu.dart';
import 'package:onlineoffice_flutter/work_project/work_project_list.dart';
import 'package:onlineoffice_flutter/discuss_work/discuss_work_list.dart';

class HomePage extends StatefulWidget {
  static GlobalKey<HomePageState> globalKey = GlobalKey();
  HomePage({this.startTabIndex = IndexTabHome.Dashboard, Key key})
      : super(key: globalKey);
  final IndexTabHome startTabIndex;

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    this.tabController = new TabController(
        vsync: this, initialIndex: widget.startTabIndex.index, length: 6);
    this.tabController.addListener(_setActiveTabIndex);
    super.initState();
    AppHelpers.loadBadgeNumber();
  }

  void _setActiveTabIndex() {
    AppHelpers.loadBadgeNumber();
    setState(() {});
  }

  void refreshState() {
    setState(() {});
  }

  void setFromDashboard(IndexTabHome indexTab) {
    if (this.tabController.index != indexTab.index)
      setState(() {
        this.tabController.index = indexTab.index;
      });
  }

  @override
  void dispose() {
    this.tabController.dispose();
    super.dispose();
  }

  String getLinkWeb(String module) {
    String rootUrl = FetchService.getDomainLink() + '/';
    if (module == 'Dashboard') {
      return rootUrl +
          'Dashboard.aspx?token=' +
          AppCache.tokenFCM +
          '&v=' +
          DateTime.now().millisecond.toString();
    }
    String link = rootUrl +
        "Index_Mobile.aspx?U=" +
        AppCache.currentUser.userName +
        "&P=" +
        AppCache.currentUser.password +
        "&L=" +
        module;
    return link;
  }

  getTitleAppBar() {
    switch (IndexTabHome.values[this.tabController.index]) {
      case IndexTabHome.Dashboard:
        return 'Dashboard';
      case IndexTabHome.CalendarWeek:
        return 'Lịch Tuần';
      case IndexTabHome.WorkProject:
        return 'Công Việc';
      case IndexTabHome.DiscussWork:
        return 'Trao Đổi Công Việc';
      case IndexTabHome.Document:
        return 'Văn Bản';
      case IndexTabHome.More:
        return 'Tính Năng Khác';
      default:
        return 'Tính Năng Khác';
    }
  }

  Widget getTabIcon(IndexBadgeApp enumBadgeApp, IconData iconData) {
    int _badge = 0;
    if (enumBadgeApp != null) {
      _badge = AppCache.badges[enumBadgeApp.index];
    } else {
      if (AppCache.currentUser.modulesActive.contains('TrinhKy')) {
        _badge += AppCache.badges[IndexBadgeApp.Signature.index];
      }
      if (AppCache.currentUser.modulesActive.contains('ThongBao')) {
        _badge += AppCache.badges[IndexBadgeApp.Announcement.index];
      }
      if (AppCache.currentUser.modulesActive.contains('BaoCao')) {
        _badge += AppCache.badges[IndexBadgeApp.ReportDaily.index];
      }
      if (AppCache.currentUser.modulesActive.contains('ThuVien')) {
        _badge += AppCache.badges[IndexBadgeApp.Library.index];
      }
    }
    if (_badge == 0) {
      return Icon(iconData, color: Colors.white, size: 30.0);
    }
    return Stack(children: <Widget>[
      Icon(iconData, color: Colors.white, size: 30.0),
      Positioned(
          right: 0,
          child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _badge.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return new Future(() => false);
        },
        child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                title: new Text(getTitleAppBar(),
                    style: TextStyle(color: Colors.white))),
            bottomNavigationBar: new Material(
                color: Colors.blueGrey,
                child: new TabBar(
                    controller: tabController,
                    indicatorColor: Colors.green,
                    indicatorWeight: 5.0,
                    tabs: <Tab>[
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              clipBehavior: Clip.none,
                              child: Text('Dashboard',
                                  style: TextStyle(color: Colors.white))),
                          icon: Icon(Icons.dashboard,
                              color: Colors.white, size: 30.0)),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              clipBehavior: Clip.none,
                              child: Text('L.Tuần',
                                  style: TextStyle(color: Colors.white))),
                          icon: getTabIcon(
                              IndexBadgeApp.Calendar, Icons.calendar_today)),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              clipBehavior: Clip.none,
                              child: Text('C.Việc',
                                  style: TextStyle(color: Colors.white))),
                          icon: getTabIcon(
                              IndexBadgeApp.WorkProject, Icons.work)),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              clipBehavior: Clip.none,
                              child: Text('T.Đổi',
                                  style: TextStyle(color: Colors.white))),
                          icon: getTabIcon(
                              IndexBadgeApp.DiscussWork, Icons.chat)),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              clipBehavior: Clip.none,
                              child: Text('V.Bản',
                                  style: TextStyle(color: Colors.white))),
                          icon:
                              getTabIcon(IndexBadgeApp.Document, Icons.folder)),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              clipBehavior: Clip.none,
                              child: Text('Thêm',
                                  style: TextStyle(color: Colors.white))),
                          icon: getTabIcon(null, Icons.apps))
                    ])),
            body: new TabBarView(controller: tabController, children: <Widget>[
              AppCache.currentUser.modulesActive.contains('Dashboard')
                  ? DashboardPage()
                  : DashboardWebPage(),
              AppCache.currentUser.modulesActive.contains('LichTuan')
                  ? new CalendarPage()
                  : AppCache.currentUser.userId.isEmpty
                      ? Container()
                      : new WebTabViewerPage(
                          title: 'Lịch Tuần', link: getLinkWeb('LichTuan')),
              AppCache.currentUser.modulesActive.contains('CongViec')
                  ? new WorkProjectPage()
                  : AppCache.currentUser.userId.isEmpty
                      ? Container()
                      : new WebTabViewerPage(
                          title: 'Công Việc', link: getLinkWeb('CongViec')),
              AppCache.currentUser.modulesActive.contains('TraoDoiCV')
                  ? new DiscussWorkPage()
                  : AppCache.currentUser.userId.isEmpty
                      ? Container()
                      : new WebTabViewerPage(
                          title: 'Trao Đổi CV', link: getLinkWeb('TraoDoiCV')),
              AppCache.currentUser.modulesActive.contains('VanBan')
                  ? new DocumentPage()
                  : AppCache.currentUser.userId.isEmpty
                      ? Container()
                      : new WebTabViewerPage(
                          title: 'Văn Bản', link: getLinkWeb('VanBan')),
              new MenuPage()
            ])));
  }
}
