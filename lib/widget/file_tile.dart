import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_browser/file_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FileTile extends StatefulWidget {
  final FileAdapter file;
  final bool selectable;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final bool isSelected;

  FileTile(
      {this.file,
      this.selectable,
      this.isSelected,
      this.onLongPress,
      this.onTap});

  @override
  _FileTileState createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  @override
  Widget build(BuildContext context) {
    return widget.selectable ? _selectableTile() : _regularTile();
  }

  Widget _regularTile() {
    return ListTile(
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        leading: _getLeading(),
        title: _getTitle(),
        subtitle: _getSubtitle());
  }

  Widget _selectableTile() {
    return CheckboxListTile(
        value: widget.isSelected,
        title: _getTitle(),
        subtitle: _getSubtitle(),
        secondary: _getLeading(),
        selected: widget.isSelected,
        onChanged: (value) => widget.onTap());
  }

  Widget _getTitle() {
    return Text(widget.file.label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
  }

  Widget _getSubtitle() {
    return widget.file.size != null
        ? Text(widget.file.size, style: TextStyle(color: Colors.white))
        : null;
  }

  Widget _getLeading() {
    return Container(
      padding: EdgeInsets.only(right: 12.0),
      decoration: new BoxDecoration(
          border: new Border(
              right: new BorderSide(width: 1.0, color: Colors.white24))),
      child: _getIcon(),
    );
  }

  Icon _getIcon() {
    if (widget.file.isDirectory) {
      return Icon(CommunityMaterialIcons.folder, color: Colors.yellow);
    }
    IconData icon;
    switch (widget.file.ext) {
      case 'pdf':
        icon = CommunityMaterialIcons.file_pdf;
        break;
      case 'zip':
        icon = CommunityMaterialIcons.zip_box;
        break;
      case 'apk':
        icon = CommunityMaterialIcons.android;
        break;
      default:
        icon = CommunityMaterialIcons.file;
    }
    return Icon(icon, color: Colors.white);
  }
}
