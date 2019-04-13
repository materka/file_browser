import 'dart:async';
import 'dart:io';

import 'package:file_browser/bloc/bloc_provider.dart';
import 'package:file_browser/directory_mode.dart';
import 'package:file_browser/file_action.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryBloc extends BlocBase {
  String directoryRoot;

  DirectoryBloc() {
    getExternalStorageDirectory().then((directory) {
      directoryRoot = directory.path;
      open(directory);
    });
  }

  BehaviorSubject<DirectoryViewModelState> _stateSink = BehaviorSubject();

  DirectoryViewModelState get _currentState => _stateSink.stream.value;

  Observable<DirectoryViewModelState> get state => _stateSink.stream;

  FileSystemEntity currentFile;

  void open(FileSystemEntity file) {
    DirectoryViewModelState state = DirectoryViewModelState.copy(_currentState);
    FileSystemEntity.isDirectory(file.path).then((bool isDirectory) {
      if (isDirectory) {
        try {
          Directory(file.path).list().toList().then((value) {
            currentFile = file;
            state.files = value.toSet();
            state.isDirectoryRoot = (file.path == directoryRoot);
            _stateSink.add(state);
          });
        } catch (Exception) {
          // Access denied
        }
      } else {
        try {
          OpenFile.open(file.path);
        } catch (Exception) {
          // Sink error
        }
      }
    });
  }

  void onToggleMode(DirectoryMode mode) {
    DirectoryViewModelState state = DirectoryViewModelState.copy(_currentState);
    state.mode = mode;
    if (mode == DirectoryMode.navigation) {
      state.selectedFiles = {};
    }
    _stateSink.sink.add(state);
  }

  void onFileAction(FileAction action, Set<FileSystemEntity> files) {
    switch (action) {
      case FileAction.toggleHidden:
        toggleHiddenFiles().then((hidden) {
          open(currentFile);
        });
        break;
      case FileAction.delete:
        //_state.mode = DirectoryMode.navigation;
        //_stateSink.sink.add(_state);
        break;
      case FileAction.open:
        if (_currentState.mode == DirectoryMode.navigation) {
          assert(
              files.length == 1, 'Can not open more than one file at a time');
          open(files.first);
        } else {
          onFileAction(FileAction.select, files);
        }
        break;
      case FileAction.select:
        DirectoryViewModelState state;
        state = DirectoryViewModelState.copy(_currentState);
        state.mode = DirectoryMode.selection;
        if (files.isEmpty) {
          state.selectedFiles.clear();
        } else {
          state.selectedFiles.addAll(files);
        }
        _stateSink.sink.add(state);
        break;
      default:
        break;
    }
  }

  Future<void> toggleHiddenFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool('showHiddenFiles') ?? false;
    prefs.setBool('showHiddenFiles', !value);
  }

  void dispose() {
    _stateSink.close();
  }
}

class DirectoryViewModelState {
  Set<FileSystemEntity> files = {};
  Set<FileSystemEntity> selectedFiles = {};
  DirectoryMode mode = DirectoryMode.navigation;
  bool showHiddenFiles = false;
  bool isDirectoryRoot = true;

  static DirectoryViewModelState copy(DirectoryViewModelState state) {
    DirectoryViewModelState newState = DirectoryViewModelState();
    if (state != null) {
      newState.files = state.files;
      newState.selectedFiles = state.selectedFiles;
      newState.mode = state.mode;
      newState.showHiddenFiles = state.showHiddenFiles;
      newState.isDirectoryRoot = state.isDirectoryRoot;
    }
    return newState;
  }
}
