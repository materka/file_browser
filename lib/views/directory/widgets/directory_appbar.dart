import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/directory_mode_type.dart';
import 'package:file_browser/file_action_type.dart';
import 'package:file_browser/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DirectoryAppBar extends StatelessWidget {
  DirectoryBloc _bloc;
  final String title;
  BuildContext _context;

  DirectoryAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    _context = context;
    _bloc = BlocProvider.of(context);
    return StreamBuilder(
        initialData: DirectoryViewModelState(),
        stream: _bloc.state,
        builder: (BuildContext context,
            AsyncSnapshot<DirectoryViewModelState> snapshot) {
          return AppBar(
              title: Text(this.title),
              leading: snapshot.data.mode == DirectoryModeType.selection
                  ? IconButton(
                      icon: Icon(CommunityMaterialIcons.close),
                      onPressed: () =>
                          _bloc.onToggleMode(DirectoryModeType.navigation),
                    )
                  : !snapshot.data.isRoot
                      ? IconButton(
                          icon: Icon(CommunityMaterialIcons.arrow_left),
                          onPressed: () => _bloc.ascend(),
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
        () => _bloc.onFileAction(FileActionType.select, state.entities));
  }

  Widget _actionDeSelectAll(DirectoryViewModelState state) {
    return _actionBuilder(CommunityMaterialIcons.checkbox_multiple_marked,
        () => _bloc.onFileAction(FileActionType.select, {}));
  }

  Widget _actionDelete(DirectoryViewModelState state) {
    return _actionBuilder(
        CommunityMaterialIcons.trash_can,
        () => _askYesOrNo('Selected items will be deleted.').then((ok) => ok
            ? _bloc.onFileAction(FileActionType.delete, state.entities)
            : null));
  }

  Widget _actionOverFlow(DirectoryViewModelState state) {
    return PopupMenuButton<Widget>(
      onSelected: (action) => Navigator.push(
              _context, MaterialPageRoute(builder: (context) => action))
          .then((value) => _bloc.refresh()),
      itemBuilder: (context) => <PopupMenuEntry<Widget>>[
            PopupMenuItem<Widget>(
              value: SettingsView(),
              child: const Text('Settings'),
            )
          ],
    );
  }

  List<Widget> _availableActions(DirectoryViewModelState state) {
    List<Widget> actions = [];
    if (state.mode == DirectoryModeType.selection) {
      actions.add(_actionSelectAll(state));
      actions.add(_actionDeSelectAll(state));
      actions.add(_actionDelete(state));
    }
    actions.add(_actionOverFlow(state));
    return actions;
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
