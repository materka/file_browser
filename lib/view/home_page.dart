import 'package:file_browser/contract/home_contract.dart';
import 'package:file_browser/file_adapter.dart';
import 'package:file_browser/presenter/home_presenter.dart';
import 'package:file_browser/widget/file_tile.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:community_material_icon/community_material_icon.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum OverFlowAction { showHiddenFiles }

class _MyHomePageState extends State<MyHomePage> implements HomeView {
  Presenter _presenter;
  BuildContext _scaffoldContext;
  Set<FileAdapter> _files = Set();
  Set<FileAdapter> _selectedFiles = Set();
  Mode _mode;
  bool _showHiddenFiles = false;

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
    init();
  }

  void init() async {
    await _presenter.init();
  }

  Future requestPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _presenter.onNavigateBack,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          appBar: AppBar(
            title: Text(widget.title),
            actions: availableActions(),
            leading: _mode == Mode.selection ? CloseButton() : null,
          ),
          body: Builder(builder: (context) {
            _scaffoldContext = context;
            return Center(
              child: _files.length > 0
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      padding: new EdgeInsets.all(6.0),
                      itemCount: _files.length,
                      itemBuilder: (BuildContext context, int index) {
                        FileAdapter file = _files.elementAt(index);
                        return Container(
                            alignment: FractionalOffset.center,
                            margin: EdgeInsets.only(bottom: 6.0),
                            padding: EdgeInsets.all(6.0),
                            child: FileTile(
                                file: file,
                                selectable: _mode == Mode.selection,
                                isSelected: _selectedFiles.contains(file),
                                onLongPress: () => _presenter
                                    .onChangeMode(Mode.selection, file: file),
                                onTap: () => _presenter.onFileAction(
                                    FileAction.select, Set.from([file]))));
                      },
                    )
                  : Text(
                      'Empty folder!',
                      style: TextStyle(color: Colors.white),
                    ),
            );
          }),
        ));
  }

  List<Widget> availableActions() {
    List<Widget> actions = List();
    if (_mode == Mode.selection) {
      IconButton multiSelect = IconButton(
          icon: _selectedFiles.length == _files.length
              ? Icon(CommunityMaterialIcons.checkbox_multiple_blank_outline)
              : Icon(CommunityMaterialIcons.checkbox_multiple_marked_outline),
          onPressed: () => _presenter.onFileAction(FileAction.select,
              _selectedFiles.length == _files.length ? null : _files));
      IconButton delete = IconButton(
        icon: Icon(CommunityMaterialIcons.trash_can),
        onPressed: () {
          _askYesOrNo('Selected items will be deleted.').then((value) => value
              ? _presenter.onFileAction(FileAction.delete, _selectedFiles)
              : null);
        },
      );
      actions.add(multiSelect);
      actions.add(delete);
    }

    PopupMenuButton overflowMenu = PopupMenuButton<OverFlowAction>(
      onSelected: (OverFlowAction result) {
        switch (result) {
          case OverFlowAction.showHiddenFiles:
            _showHiddenFiles = !_showHiddenFiles;
            _presenter.includeHiddenFiles(_showHiddenFiles);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OverFlowAction>>[
            CheckedPopupMenuItem<OverFlowAction>(
              checked: _showHiddenFiles,
              value: OverFlowAction.showHiddenFiles,
              child: const Text('Show hidden files'),
            ),
          ],
    );
    actions.add(overflowMenu);
    return actions;
  }

  @override
  void showMessage(String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  @override
  void showFiles(Set<FileAdapter> files, Mode mode) {
    setState(() {
      _mode = mode;
      _files = files;
    });
  }

  @override
  void selectFiles(Set<FileAdapter> files) {
    setState(() {
      _selectedFiles.clear();
      _selectedFiles.addAll(files);
    });
  }

  @override
  Future<bool> exit() {
    return _askYesOrNo('The app will quit.') ?? false;
  }

  Future<bool> _askYesOrNo(String title) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
            title: Text(title),
            content: Text('Are you sure?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
    );
  }
}
