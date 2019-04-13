import 'dart:io';

import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/widgets/file_tile.dart';
import 'package:flutter/material.dart';

class FileView extends StatelessWidget {
  DirectoryBloc _bloc;
  Widget emptyView = Text('Empty folder!');

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of(context);
    return StreamBuilder(
        initialData: DirectoryViewModelState(),
        stream: _bloc.state,
        builder: (BuildContext context,
            AsyncSnapshot<DirectoryViewModelState> snapshot) {
          DirectoryViewModelState state = snapshot.data;
          return state.files.isEmpty
              ? emptyView
              : ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: new EdgeInsets.all(6.0),
                  itemCount: state.files.length,
                  itemBuilder: (BuildContext context, int index) {
                    FileSystemEntity file = state.files.elementAt(index);
                    return Container(
                        alignment: FractionalOffset.center,
                        margin: EdgeInsets.only(bottom: 6.0),
                        padding: EdgeInsets.all(6.0),
                        child: FileTile(file));
                  },
                );
        });
  }
}
