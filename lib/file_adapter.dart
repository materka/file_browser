import 'dart:io';
import 'package:kilobyte/kilobyte.dart';

class FileAdapter {
  final Directory _directory;
  final String path;
  final String _label;
  final bool isDirectory;

  FileAdapter(this.path, [this._label])
      : _directory = Directory(path),
        isDirectory = FileSystemEntity.isDirectorySync(path);

  String get ext => name.contains('.')
      ? name.substring(name.lastIndexOf('.') + 1, name.length)
      : null;
  String get label => _label ?? name;
  String get name => path.substring(path.lastIndexOf('/') + 1, path.length);
  String get size => _calculateSize();
  bool get hidden => name.startsWith('.') || name.startsWith('__');
  FileAdapter get parent => FileAdapter(_directory.parent.path);

  int compareTo(FileAdapter that) {
    return this.isDirectory
        ? (that.isDirectory ? 0 : -1)
        : (that.isDirectory ? 1 : 0);
  }

  bool operator ==(o) => o is FileAdapter && o.path == path;
  int get hashCode => path.hashCode;

  String _calculateSize() {
    if (!isDirectory) {
      FileStat stat = _directory.statSync();
      return Size(bytes: stat.size).toString();
    }
    return null;
  }

  Set<FileAdapter> getContent(bool includeHidden) {
    return _directory
        .listSync()
        .toList()
        .map((f) => FileAdapter(f.path))
        .where((file) => includeHidden ? true : !file.hidden)
        .toSet();
  }

  void delete() {
    _directory.deleteSync(recursive: true);
  }
}
