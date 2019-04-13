import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/directory_mode.dart';
import 'package:file_browser/file_action.dart';
import 'package:file_browser/widgets/file_appbar.dart';
import 'package:file_browser/widgets/file_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DirectoryView extends StatefulWidget {
  DirectoryView({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DirectoryViewState createState() => _DirectoryViewState();
}

class _DirectoryViewState extends State<DirectoryView> {
  BuildContext _scaffoldContext;
  DirectoryBloc _bloc = DirectoryBloc();

  @override
  void initState() {
    PermissionHandler()
        .requestPermissions([PermissionGroup.storage])
        .then((Map value) =>
            value[PermissionGroup.storage] == PermissionStatus.granted)
        .then((granted) {
          if (granted) {
          } else {}
        });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DirectoryBloc>(
      bloc: _bloc,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: PreferredSize(
            preferredSize: const Size(double.infinity, kToolbarHeight),
            child: FileAppBar()
        ),
        body: Builder(builder: (context) {
          return Center(child: FileView());
        }),
      ),
    );
  }

  void showMessage(String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }
}
