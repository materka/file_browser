import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/directory_mode.dart';
import 'package:file_browser/file_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FileAppBar extends StatelessWidget {
  DirectoryBloc _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of(context);
    return StreamBuilder(
        initialData: DirectoryViewModelState(),
        stream: _bloc.state,
        builder: (BuildContext context,
            AsyncSnapshot<DirectoryViewModelState> snapshot) {
          return AppBar(
              leading: snapshot.data.mode == DirectoryMode.selection
                  ? IconButton(
                      icon: Icon(CommunityMaterialIcons.close),
                      onPressed: () =>
                          _bloc.onToggleMode(DirectoryMode.navigation),
                    )
                  : !snapshot.data.isDirectoryRoot
                      ? IconButton(
                          icon: Icon(CommunityMaterialIcons.arrow_left),
                          onPressed: () => _bloc.open(_bloc.currentFile.parent),
                        )
                      : Container(),
              actions: _availableActions(snapshot.data));
        });
  }

  Widget _actionBuilder(IconData iconData, VoidCallback onPressed) {
    return IconButton(icon: Icon(iconData), onPressed: onPressed);
  }

  Widget _actionSelectAll(DirectoryViewModelState state) {
    return _actionBuilder(
        CommunityMaterialIcons.checkbox_multiple_marked_outline,
        () => _bloc.onFileAction(FileAction.select, state.files));
  }

  Widget _actionDeSelectAll(DirectoryViewModelState state) {
    return _actionBuilder(CommunityMaterialIcons.checkbox_multiple_marked,
        () => _bloc.onFileAction(FileAction.select, {}));
  }

  Widget _actionDelete(DirectoryViewModelState state) {
    return _actionBuilder(
        CommunityMaterialIcons.trash_can,
        () => _askYesOrNo('Selected items will be deleted.').then((ok) => ok
            ? _bloc.onFileAction(FileAction.delete, state.selectedFiles)
            : null));
  }

  Widget _actionOverFlow(DirectoryViewModelState state) {
    return PopupMenuButton<FileAction>(
      onSelected: (action) => _bloc.onFileAction(action, {}),
      itemBuilder: (context) => <PopupMenuEntry<FileAction>>[
            CheckedPopupMenuItem<FileAction>(
              checked: state.showHiddenFiles,
              value: FileAction.toggleHidden,
              child: const Text('Show hidden files'),
            )
          ],
    );
  }

  List<Widget> _availableActions(DirectoryViewModelState state) {
    List<Widget> actions = [];
    if (state.mode == DirectoryMode.selection) {
      actions.add(_actionSelectAll(state));
      actions.add(_actionDeSelectAll(state));
      actions.add(_actionDelete(state));
    }
    actions.add(_actionOverFlow(state));
    return actions;
  }

  @override
  Future<bool> exit() {
    return _askYesOrNo('The app will quit.') ?? false;
  }

  Future<bool> _askYesOrNo(String title) {
    return showDialog(
      context: null,
      builder: (context) => new AlertDialog(
            title: Text(title),
            content: Text('Are you sure?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
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
