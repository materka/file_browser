// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_browser/views/directory/directory_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Provider',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _requestPermission(),
        initialData: Container(),
        builder: (context, snapshot) {
          return snapshot.data;
        },
      ),
    );
  }

  Future<Widget> _requestPermission() {
    return PermissionHandler()
        .requestPermissions([PermissionGroup.storage])
        .then((Map value) =>
            value[PermissionGroup.storage] == PermissionStatus.granted)
        .then((granted) {
          if (granted) {
            return DirectoryView(
              title: "File Browser",
            );
          } else {
            return AlertDialog(
              title: Text("Permissions"),
              content: Text('Try again?'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop'),
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: () {
                    _requestPermission();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          }
        });
  }
}
