import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/directory_mode_type.dart';
import 'package:file_browser/file_action_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kilobyte/kilobyte.dart';

class EntityTile extends StatelessWidget {
  final DirectoryViewEntity entity;

  EntityTile(this.entity);

  @override
  Widget build(BuildContext context) {
    DirectoryBloc bloc = BlocProvider.of(context);
    bloc.onMode.doOnData(switchMode);
    return StreamBuilder(
        initialData: DirectoryViewModelState(),
        stream: bloc.state,
        builder: (BuildContext context,
            AsyncSnapshot<DirectoryViewModelState> snapshot) {
          return snapshot.data.mode == DirectoryModeType.selection
              ? CheckboxListTile(
                  title: _getTitle(),
                  subtitle: _getSubtitle(),
                  secondary: _getLeading(),
                  selected: entity.isSelected,
                  value: entity.isSelected,
                  onChanged: (value) =>
                      bloc.onFileAction(FileActionType.select, {entity}))
              : ListTile(
                  title: _getTitle(),
                  subtitle: _getSubtitle(),
                  leading: _getLeading(),
                  onLongPress: () =>
                      bloc.onFileAction(FileActionType.select, {entity}),
                  onTap: () =>
                      bloc.onFileAction(FileActionType.open, {entity}));
        });
  }

  void switchMode(DirectoryModeType type) {
    
  }

  Widget _getTitle() {
    return Text(entity.name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
  }

  Widget _getSubtitle() {
    String text = !entity.isDirectory
        ? Size(bytes: entity.size ?? 0).toString()
        : "${entity.contentSize} items";
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
    if (entity.isDirectory) {
      return Icon(CommunityMaterialIcons.folder, color: Colors.yellow);
    }
    IconData icon;
    switch (entity.format) {
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
