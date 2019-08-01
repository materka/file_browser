import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _showHiddenFiles = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _showHiddenFiles = prefs.getBool("showHiddenFiles") ?? false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: const Text('Show hidden files'),
              value: _showHiddenFiles,
              onChanged: (value) => setState(() {
                    _showHiddenFiles = value;
                    SharedPreferences.getInstance().then(
                        (prefs) => prefs.setBool("showHiddenFiles", value));
                  }),
              secondary: const Icon(Icons.lightbulb_outline),
            )
          ],
        ),
      ),
    );
  }
}
