import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/directory_mode.dart';
import 'package:file_browser/file_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kilobyte/kilobyte.dart';

typedef FileSelected = void Function(FileSystemEntity file);
typedef FileDeselected = void Function(FileSystemEntity file);

class FileTile extends StatelessWidget {
  final FileSystemEntity file;

  bool isSelected = false;

  bool get _isDirectory => FileSystemEntity.isDirectorySync(file.path);

  String get _fileFormat =>
      file.path.substring(file.path.lastIndexOf('.') + 1, file.path.length);

  int get _fileSize => file.statSync().size;

  DirectoryBloc _bloc;

  FileTile(this.file);

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of(context);
    return StreamBuilder(
        initialData: DirectoryViewModelState(),
        stream: _bloc.state,
        builder: (BuildContext context,
            AsyncSnapshot<DirectoryViewModelState> snapshot) {
          return snapshot.data.mode == DirectoryMode.selection
              ? _selectableTile(snapshot.data)
              : _regularTile();
        });
  }

  Widget _regularTile() {
    return ListTile(
        onLongPress: () =>
            _bloc.onFileAction(FileAction.select, {file}),
        onTap: () => _bloc.onFileAction(FileAction.open, {file}),
        leading: _getLeading(),
        title: _getTitle(),
        subtitle: _getSubtitle());
  }

  Widget _selectableTile(DirectoryViewModelState state) {
    bool isSelected = state.selectedFiles.contains(file);
    return CheckboxListTile(
        value: isSelected,
        title: _getTitle(),
        subtitle: _getSubtitle(),
        secondary: _getLeading(),
        selected: isSelected,
        onChanged: (value) =>
            _bloc.onFileAction(FileAction.select, {file}));
  }

  Widget _getTitle() {
    return Text(
        file.path.substring(file.path.lastIndexOf('/') + 1, file.path.length),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
  }

  Widget _getSubtitle() {
    String text = !_isDirectory && _fileSize != null
        ? Size(bytes: _fileSize).toString()
        : "${Directory(file.path).listSync().length} items";
    return Text(text, style: TextStyle(color: Colors.white));
  }

  Widget _getLeading() {
    return Container(
      padding: EdgeInsets.only(right: 12.0),
      decoration: new BoxDecoration(
          border: new Border(
              right: new BorderSide(width: 1.0, color: Colors.white24))),
      child: _getIcon(),
    );
  }

  Icon _getIcon() {
    if (_isDirectory) {
      return Icon(CommunityMaterialIcons.folder, color: Colors.yellow);
    }
    IconData icon;
    switch (_fileFormat) {
      case 'pdf':
        icon = CommunityMaterialIcons.file_pdf;
        break;
      case 'zip':
        icon = CommunityMaterialIcons.zip_box;
        break;
      case 'apk':
        icon = CommunityMaterialIcons.android;
        break;
      default:
        icon = CommunityMaterialIcons.file;
    }
    return Icon(icon, color: Colors.white);
  }
}
