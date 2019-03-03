import 'package:file_browser/contract/home_contract.dart';
import 'package:file_browser/file_adapter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

enum Mode { navigation, selection }
enum FileAction { delete, select }

class HomePresenter implements Presenter {
  HomeView _view;
  FileAdapter _base;
  bool _includeHidden = false;
  FileAdapter _currentDirectory;
  Set<FileAdapter> _selectedFiles = Set();
  Mode _mode = Mode.navigation;

  HomePresenter(this._view);

  Future init() async {
    String path = (await getExternalStorageDirectory()).path;
    _base = _currentDirectory = FileAdapter(path);
    _reload();
  }

  void _openFile(FileAdapter file) async {
    if (file.isDirectory) {
      _currentDirectory = file;
    } else {
      try {
        await OpenFile.open(file.path);
      } catch (Exception) {
        _view.showMessage("Can not open file.");
      }
    }
  }

  _reload() {
    List<FileAdapter> files =
        _currentDirectory.getContent(_includeHidden).toList();
    files.sort((a, b) => a.compareTo(b));
    _view.showFiles(files.toSet(), _mode);
    if (_mode == Mode.selection) {
      _view.selectFiles(_selectedFiles);
    }
  }

  void includeHiddenFiles(bool show) {
    _includeHidden = show;
    _reload();
  }

  void onFileAction(FileAction action, Set<FileAdapter> files) {
    switch (action) {
      case FileAction.select:
        if (_mode == Mode.navigation) {
          assert(
              files.length == 1, "Can not open multiple files simultanously.");
          _openFile(files.first);
        } else {
          if (files == null) {
            _selectedFiles.clear();
          } else if (files.length ==
              _currentDirectory.getContent(_includeHidden).length) {
            _selectedFiles.addAll(files);
          } else {
            files.forEach((file) {
              if (_selectedFiles.contains(file)) {
                _selectedFiles.remove(file);
              } else {
                _selectedFiles.add(file);
              }
            });
          }
        }
        break;
      case FileAction.delete:
        files.forEach((f) => f.delete());
        _mode = Mode.navigation;
        break;
    }
    _reload();
  }

  @override
  void onChangeMode(Mode newMode, {FileAdapter file}) {
    _selectedFiles.clear();
    _mode = newMode;
    if (file != null && _mode == Mode.selection) {
      onFileAction(FileAction.select, Set.from([file]));
    } else {
      _reload();
    }
  }

  @override
  Future<bool> onNavigateBack() {
    if (_mode == Mode.selection) {
      onChangeMode(Mode.navigation);
      return Future.value(false);
    } else if (_currentDirectory != _base) {
      onFileAction(FileAction.select, Set.from([_currentDirectory.parent]));
      return Future.value(false);
    } else {
      return _view.exit();
    }
  }
}
