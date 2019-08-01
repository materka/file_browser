import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/bloc/directory_bloc.dart';
import 'package:file_browser/views/directory/widgets/entity_tile.dart';
import 'package:flutter/material.dart';

class EntityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DirectoryBloc _bloc = BlocProvider.of(context);
    return StreamBuilder(
        initialData: DirectoryViewModelState(),
        stream: _bloc.state,
        builder: (BuildContext context,
            AsyncSnapshot<DirectoryViewModelState> snapshot) {
          DirectoryViewModelState state = snapshot.data;
          return state.entities.isEmpty
              ? Text('Empty folder!')
              : ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: new EdgeInsets.all(6.0),
                  itemCount: state.entities.length,
                  itemBuilder: (BuildContext context, int index) {
                    DirectoryViewEntity entity =
                        state.entities.elementAt(index);
                    return Container(
                        alignment: FractionalOffset.center,
                        margin: EdgeInsets.only(bottom: 6.0),
                        padding: EdgeInsets.all(6.0),
                        child: EntityTile(entity));
                  },
                );
        });
  }
}
