import 'package:file_browser/file_adapter.dart';
import 'package:file_browser/presenter/home_presenter.dart';

abstract class HomeView {
  void showMessage(String message);
  void showFiles(Set<FileAdapter> files, Mode mode);
  void selectFiles(Set<FileAdapter> files);
  Future<bool> exit();
}

abstract class Presenter {
  Future init();
  void onFileAction(FileAction action, Set<FileAdapter> files);
  void onChangeMode(Mode newMode, {FileAdapter file});
  void onNavigateBack();
  void includeHiddenFiles(bool include);
}
