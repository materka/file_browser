import 'dart:io';

import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/directory_mode_type.dart';
import 'package:file_browser/file_action_type.dart';
import 'package:file_browser/loggable.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryBloc extends BlocBase with Loggable {
  String _root;
  DirectoryViewEntity _currentEntity;

  BehaviorSubject<DirectoryViewModelState> _stateSink = BehaviorSubject();
  BehaviorSubject<DirectoryModeType> _mode = BehaviorSubject();
  Observable<DirectoryModeType> get onMode => _mode.stream;

  DirectoryViewModelState get _currentState => _stateSink.stream.value;

  Observable<DirectoryViewModelState> get state => _stateSink.stream;

  DirectoryBloc() {
    getExternalStorageDirectory().then((directory) {
      this._root = directory.path;
      descend(DirectoryViewEntity(directory));
    });
  }

  void refresh() {
    descend(this._currentEntity);
  }

  void ascend() {
    if (_currentEntity.fileSystemEntity.path != this._root) {
      descend(DirectoryViewEntity(_currentEntity.fileSystemEntity.parent));
    }
  }

  void descend(DirectoryViewEntity entity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DirectoryViewModelState state = DirectoryViewModelState();
    state.isRoot = entity.fileSystemEntity.path == this._root;
    if (entity.isDirectory) {
      bool showHiddenFiles = prefs.getBool("showHiddenFiles") ?? false;
      Directory(entity.fileSystemEntity.path)
          .list()
          .map((entity) => DirectoryViewEntity(entity))
          .where(
              (entity) => showHiddenFiles ? true : !entity.name.startsWith("."))
          .toList()
          .then((entities) {
        this._currentEntity = entity;
        state.entities = entities.toSet();
        this._stateSink.add(state);
      }).catchError((ex) => e("Failed to open directory", ex));
    } else {
      OpenFile.open(entity.fileSystemEntity.path)
          .catchError((ex) => e("Failed to open directory", ex));
    }
  }

  void onToggleMode(DirectoryModeType mode) {
    DirectoryViewModelState state = DirectoryViewModelState.copy(_currentState);
    state.mode = mode;
    if (mode == DirectoryModeType.navigation) {
      state.entities.forEach((f) => f.isSelected = false);
    }
    _stateSink.sink.add(state);
  }

  void onFileAction(FileActionType action, Set<DirectoryViewEntity> entities) {
    switch (action) {
      case FileActionType.delete:
        //_state.mode = DirectoryMode.navigation;
        //_stateSink.sink.add(_state);
        break;
      case FileActionType.open:
        if (_currentState.mode == DirectoryModeType.navigation) {
          assert(entities.length == 1,
              'Can not open more than one file at a time');
          descend(entities.first);
        } else {
          onFileAction(FileActionType.select, entities);
        }
        break;
      case FileActionType.select:
        DirectoryViewModelState state =
            DirectoryViewModelState.copy(_currentState);
        state.mode = DirectoryModeType.selection;
        if (entities.isEmpty) {
          state.entities.forEach((f) => f.isSelected = false);
        } else {
          state.entities
              .intersection(entities)
              .forEach((f) => f.isSelected = true);
        }
        _stateSink.sink.add(state);
        break;
      default:
        break;
    }
  }

  void dispose() {
    _stateSink.close();
  }
}

class DirectoryViewEntity {
  bool isSelected;
  final FileSystemEntity fileSystemEntity;

  DirectoryViewEntity(this.fileSystemEntity, {this.isSelected = false});

  String get name => fileSystemEntity.path.substring(
      fileSystemEntity.path.lastIndexOf('/') + 1, fileSystemEntity.path.length);

  String get format => fileSystemEntity.path.substring(
      fileSystemEntity.path.lastIndexOf('.') + 1, fileSystemEntity.path.length);

  bool get isDirectory =>
      FileSystemEntity.isDirectorySync(fileSystemEntity.path);

  int get size => fileSystemEntity.statSync().size;

  int get contentSize =>
      isDirectory ? Directory(fileSystemEntity.path).listSync().length : 0;
}

class DirectoryViewModelState {
  Set<DirectoryViewEntity> entities;
  DirectoryModeType mode;
  bool isRoot;

  DirectoryViewModelState(
      {this.entities = const {},
      this.mode = DirectoryModeType.navigation,
      this.isRoot = true});

  static DirectoryViewModelState copy(DirectoryViewModelState state) {
    DirectoryViewModelState copy = DirectoryViewModelState(
        entities: state.entities, mode: state.mode, isRoot: state.isRoot);
    return copy;
  }
}
