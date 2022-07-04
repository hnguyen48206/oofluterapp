import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/dal/services.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:onlineoffice_flutter/home.dart';
import 'package:onlineoffice_flutter/main.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardPageState();
  }
}

class DashboardPageState extends State<DashboardPage> {
  List<int> counts;
  @override
  void initState() {
    // counts = [0, 1, 2000, 3, 4000, 5, 6];
    super.initState();
    FetchService.dashboardGetCount().then((List<int> result) {
      if (result != null && result.length > 0) {
        this.counts = result;
        if (this.mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 500,
      child: Column(
        children: <Widget>[
          // TextButton(
          //   style: ButtonStyle(
          //     foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          //   ),
          //   onPressed: () {
          //     notificationPlugin.showNotification('Test Push', 'abc xyz',
          //         json.encode({'Usrname': 'tom', 'Password': 'pass@123'}));
          //   },
          //   child: Text('TextButton'),
          // ),
          ListTile(
              leading: Icon(Icons.work, color: Colors.blueGrey),
              title: Text('Công việc', style: TextStyle(fontSize: 20))),
          Flexible(
            child: Row(
              children: <Widget>[
                _buildStatCard('Được giao', 0, '#00c0ef', 0),
                _buildStatCard('Chuyển giao', 1, '#f39c12', 0)
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                _buildStatCard('Được xem', 2, '#d2d6de', 8.0),
                _buildStatCard('Đã kết thúc', 3, '#00a65a', 8.0)
              ],
            ),
          ),
          SizedBox(height: 20.0),
          ListTile(
              leading: Icon(Icons.folder, color: Colors.blueGrey),
              title: Text('Văn bản', style: TextStyle(fontSize: 20))),
          Flexible(
            child: Row(
              children: <Widget>[
                _buildStatCard('Đến', 4, '#00c0ef', 0),
                _buildStatCard('Đi', 5, '#00a65a', 0),
                _buildStatCard('Nội bộ', 6, '#f39c12', 0)
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String title, int index, String hexColor, double top) {
    return Expanded(
        child: InkWell(
            onTap: () {
              switch (index) {
                case 0:
                  AppCache.tabIndexWorkList = 1;
                  HomePage.globalKey.currentState
                      .setFromDashboard(IndexTabHome.WorkProject);
                  break;
                case 1:
                  AppCache.tabIndexWorkList = 2;
                  HomePage.globalKey.currentState
                      .setFromDashboard(IndexTabHome.WorkProject);
                  break;
                case 2:
                  AppCache.tabIndexWorkList = 3;
                  HomePage.globalKey.currentState
                      .setFromDashboard(IndexTabHome.WorkProject);
                  break;
                case 3:
                  AppCache.tabIndexWorkList = 4;
                  HomePage.globalKey.currentState
                      .setFromDashboard(IndexTabHome.WorkProject);
                  break;
                case 4:
                  AppCache.tabIndexDocumentList = 'VBDE';
                  HomePage.globalKey.currentState
                      .setFromDashboard(IndexTabHome.Document);
                  break;
                case 5:
                  AppCache.tabIndexDocumentList = 'VBDI';
                  HomePage.globalKey.currentState
                      .setFromDashboard(IndexTabHome.Document);
                  break;
                case 6:
                  AppCache.tabIndexDocumentList = 'VBNO';
                  HomePage.globalKey.currentState
                      .setFromDashboard(IndexTabHome.Document);
                  break;
                default:
              }
            },
            // behavior: HitTestBehavior.translucent,
            child: Container(
                margin: EdgeInsets.fromLTRB(8.0, top, 8.0, 8.0),
                decoration: BoxDecoration(
                    color: ObjectHelper.getColorFromHex(hexColor),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      this.counts == null
                          ? CircularProgressIndicator()
                          : Text(this.counts[index].toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: (index < 4) ? 45.0 : 35.0,
                                  fontWeight: FontWeight.bold)),
                      SizedBox(height: (index < 4) ? 5.0 : 15.0),
                      Text(title, style: TextStyle(color: Colors.black))
                    ]))));
  }
}
