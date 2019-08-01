import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/views/directory/widgets/directory_appbar.dart';
import 'package:file_browser/views/directory/widgets/entity_view.dart';
import 'package:flutter/material.dart';

class DirectoryView extends StatelessWidget {
  final String title;
  DirectoryView({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DirectoryBloc>(
      bloc: DirectoryBloc(),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: PreferredSize(
            preferredSize: const Size(double.infinity, kToolbarHeight),
            child: DirectoryAppBar(title)),
        body: Builder(builder: (context) {
          return Center(child: EntityView());
        }),
      ),
    );
  }
}
