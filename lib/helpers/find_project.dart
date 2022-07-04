import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlineoffice_flutter/dal/enums.dart';
import 'package:onlineoffice_flutter/dal/object_helper.dart';
import 'package:onlineoffice_flutter/document/document_create_step1.dart';
import 'package:onlineoffice_flutter/globals.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:onlineoffice_flutter/models/models_ext.dart';
import 'package:onlineoffice_flutter/work_project/work_project_create_step1.dart';

class FindCategoryPageState extends State<FindCategoryPage> {
  List<CategoryDb> listProject = [];
  SearchBar searchBar;
  TextEditingController searchController;

  void submitSearch(String text) {
    // this.searchController.text = text;
    if (text.isEmpty) {
      setState(() {
        this.listProject = widget.listCategory;
      });
    } else {
      text = text.toLowerCase();
      setState(() {
        this.listProject = widget.listCategory
            .where((p) =>
                p.name.toLowerCase().contains(text) ||
                ObjectHelper.convertToUnSign(p.name.toLowerCase())
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
    this.listProject = widget.listCategory;
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
        buildDefaultAppBar: buildAppBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: searchBar.build(context),
        body: Container(
            child: ListView.separated(
                itemCount: this.listProject.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.black),
                itemBuilder: (context, index) {
                  return getLayoutUser(this.listProject[index]);
                })),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            recallAction();
          },
          child: Icon(Icons.send, color: Colors.white),
        ));
  }

  recallAction() {
    if (widget.kindAction == KindAction.Project) {
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => WorkProjectCreateStep1Page()));
      return;
    }
    if (widget.kindAction == KindAction.DocumentSource) {
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => DocumentCreateStep1Page()));
      return;
    }
    if (widget.kindAction == KindAction.DocumentDirectories) {
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => DocumentCreateStep1Page()));
      return;
    }
  }

  setChecked(bool isChecked, CategoryDb project) {
    if (widget.kindAction == KindAction.Project) {
      if (isChecked == true) {
        AppCache.currentWorkProject.msda = project.id;
      } else {
        AppCache.currentWorkProject.msda = '';
      }
      return;
    }
    if (widget.kindAction == KindAction.DocumentSource) {
      if (isChecked == true) {
        AppCache.currentDocument.nguonVanBan = int.parse(project.id);
      } else {
        AppCache.currentDocument.nguonVanBan = 0;
      }
      return;
    }
    if (widget.kindAction == KindAction.DocumentDirectories) {
      if (isChecked == true) {
        AppCache.currentDocument.loaiVanBan = int.parse(project.id);
      } else {
        AppCache.currentDocument.loaiVanBan = 0;
      }
      return;
    }
  }

  Widget getLayoutUser(CategoryDb category) {
    if (widget.kindAction == KindAction.Project) {
      category.checked = AppCache.currentWorkProject.msda == category.id;
    }
    if (widget.kindAction == KindAction.DocumentSource) {
      category.checked =
          AppCache.currentDocument.nguonVanBan == int.parse(category.id);
    }
    if (widget.kindAction == KindAction.DocumentDirectories) {
      category.checked =
          AppCache.currentDocument.loaiVanBan == int.parse(category.id);
    }
    return ListTile(
        title: Text(category.name),
        trailing: Checkbox(
          value: category.checked,
          tristate: true,
          activeColor: Colors.blue,
          checkColor: Colors.lightBlueAccent,
          onChanged: (val) {
            setState(() {
              setChecked(val, category);
            });
          },
        )
        // , onTap: () {}
        );
  }
}

class FindCategoryPage extends StatefulWidget {
  FindCategoryPage({this.kindAction, this.listCategory});
  final KindAction kindAction;
  final List<CategoryDb> listCategory;

  @override
  State<StatefulWidget> createState() {
    return FindCategoryPageState();
  }
}
