// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';

import 'package:color_panel/color_panel.dart';
import 'package:example_flutter/keyboard_test_page.dart';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:menubar/menubar.dart';

void main() {
  // Desktop platforms are not recognized as valid targets by
  // Flutter; force a specific target to prevent exceptions.
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(new MyApp());
}

/// Top level widget for the example application.
class MyApp extends StatefulWidget {
  /// Constructs a new app with the given [key].
  const MyApp({Key key}) : super(key: key);

  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<MyApp> {
  Color _primaryColor = Colors.green;
  int _counter = 0;

  static _AppState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_AppState>());

  /// Sets the primary color of the example app.
  void setPrimaryColor(Color color) {
    setState(() {
      _primaryColor = color;
    });
  }

  void incrementCounter() {
    _setCounter(_counter + 1);
  }

  void _decrementCounter() {
    _setCounter(_counter - 1);
  }

  void _setCounter(int value) {
    setState(() {
      _counter = value;
    });
  }

  /// Rebuilds the native menu bar based on the current state.
  void updateMenubar() {
    // Currently, the menubar plugin is only implemented on macOS and linux.
    if (!Platform.isMacOS && !Platform.isLinux) {
      return;
    }
    setApplicationMenu([
      Submenu(label: 'Color', children: [
        MenuItem(
            label: 'Reset',
            enabled: _primaryColor != Colors.blue,
            onClicked: () {
              setPrimaryColor(Colors.blue);
            }),
        MenuDivider(),
        Submenu(label: 'Presets', children: [
          MenuItem(
              label: 'Red',
              enabled: _primaryColor != Colors.red,
              onClicked: () {
                setPrimaryColor(Colors.red);
              }),
          MenuItem(
              label: 'Green',
              enabled: _primaryColor != Colors.green,
              onClicked: () {
                setPrimaryColor(Colors.green);
              }),
          MenuItem(
              label: 'Purple',
              enabled: _primaryColor != Colors.deepPurple,
              onClicked: () {
                setPrimaryColor(Colors.deepPurple);
              }),
        ])
      ]),
      Submenu(label: 'Counter', children: [
        MenuItem(
            label: 'Reset',
            enabled: _counter != 0,
            onClicked: () {
              _setCounter(0);
            }),
        MenuDivider(),
        MenuItem(label: 'Increment', onClicked: incrementCounter),
        MenuItem(
            label: 'Decrement',
            enabled: _counter > 0,
            onClicked: _decrementCounter),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Any time the state changes, the menu needs to be rebuilt.
    updateMenubar();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: _primaryColor,
        accentColor: _primaryColor,
        fontFamily: 'Roboto',
        platform: TargetPlatform.iOS,
      ),
      debugShowCheckedModeBanner: false,
      home: ProfilePage() /*_MyHomePage(title: 'Desktop', counter: _counter) */,
    );
  }
}

class _MyHomePage extends StatelessWidget {
  final String title;
  final int counter;

  const _MyHomePage({this.title, this.counter = 0});

  void _changePrimaryThemeColor(BuildContext context) {
    final colorPanel = ColorPanel.instance;
    if (!colorPanel.showing) {
      colorPanel.show((color) {
        _AppState.of(context).setPrimaryColor(color);
        // Setting the primary color to a non-opaque color raises an exception.
      }, showAlpha: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.color_lens),
            tooltip: 'Change theme color',
            onPressed: () {
              _changePrimaryThemeColor(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$counter',
              style: Theme.of(context).textTheme.display1,
            ),
            TextInputTestWidget(),
            FileChooserTestWidget(),
            new RaisedButton(
                child: new Text('Test raw keyboard events'),
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => KeyboardTestPage()));
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _AppState.of(context).incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

/// A widget containing controls to test the file chooser plugin.
class FileChooserTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        new FlatButton(
          child: const Text('SAVE'),
          onPressed: () {
            file_chooser.showSavePanel((result, paths) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(_resultTextForFileChooserOperation(
                    _FileChooserType.save, result, paths)),
              ));
            }, suggestedFileName: 'save_test.txt');
          },
        ),
        new FlatButton(
          child: const Text('OPEN'),
          onPressed: () {
            file_chooser.showOpenPanel((result, paths) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(_resultTextForFileChooserOperation(
                    _FileChooserType.open, result, paths)),
              ));
            }, allowsMultipleSelection: true);
          },
        ),
      ],
    );
  }
}

/// A widget containing controls to test text input.
class TextInputTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        SampleTextField(),
        SampleTextField(),
      ],
    );
  }
}

/// A text field with styling suitable for including in a TextInputTestWidget.
class SampleTextField extends StatelessWidget {
  /// Creates a new sample text field.
  const SampleTextField();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }
}

/// Possible file chooser operation types.
enum _FileChooserType { save, open }

/// Returns display text reflecting the result of a file chooser operation.
String _resultTextForFileChooserOperation(
    _FileChooserType type, file_chooser.FileChooserResult result,
    [List<String> paths]) {
  if (result == file_chooser.FileChooserResult.cancel) {
    return '${type == _FileChooserType.open ? 'Open' : 'Save'} cancelled';
  }
  final statusText = type == _FileChooserType.open ? 'Opened' : 'Saved';
  return '$statusText: ${paths.join('\n')}';
}

///
///
///PROFILE PAGE
///
///
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //profile avatar radius
    var avaSize = 52.0;

    var textTheme = Theme.of(context).textTheme;
    //primary text style
    var primary = textTheme.title.copyWith(
      fontWeight: FontWeight.bold,
    );
    //secondary text style
    var secondary = textTheme.subtitle.copyWith(
      color: Colors.black54,
    );
    //secondary text style with bold weight
    var secondary2 = textTheme.subhead.copyWith(
      fontWeight: FontWeight.bold,
    );
    var card = Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: avaSize),
          padding: EdgeInsets.fromLTRB(16, avaSize * 1.5, 16, avaSize / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: Colors.blueGrey.shade100.withOpacity(.4),
              )
            ],
          ),
          child: Column(
            children: <Widget>[
              Text('Ardiansyah Putra', style: primary),
              Text('putraxor@gmail.com', style: secondary),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Text('Company', style: secondary),
                          Text('Eunomia', style: secondary2)
                        ],
                      ),
                    ),
                    Container(height: 24, width: 1, color: Colors.black12),
                    Flexible(
                      child: Column(
                        children: [
                          Text('Location', style: secondary),
                          Text('Indonesia', style: secondary2)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    tooltip: 'Email',
                    mini: true,
                    elevation: 1,
                    child: Icon(Icons.email),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurpleAccent,
                    onPressed: () {},
                  ),
                  FloatingActionButton(
                    tooltip: 'Chat',
                    mini: true,
                    elevation: 1,
                    child: Icon(Icons.chat),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    onPressed: () {},
                  ),
                  FloatingActionButton(
                    tooltip: 'Call',
                    mini: true,
                    elevation: 1,
                    child: Icon(Icons.call),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.greenAccent,
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
        CircleAvatar(
          radius: avaSize,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(
              'https://avatars0.githubusercontent.com/u/6225082?s=460&v=4'),
        ),
      ],
    );

    ///UI FOR REPOSITORIES
    var repos = ListView.builder(
      itemCount: 4,
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, i) => Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.blueGrey.shade100.withOpacity(.4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Awesome Project #$i',
                        style: secondary2.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Wrap(
                        spacing: 16,
                        children: [
                          Text('109 Stars', style: secondary),
                          Text('24 Forks', style: secondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('GITHUB', style: Theme.of(context).textTheme.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.blueGrey,
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cloud_download),
            color: Colors.blueGrey,
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            card,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Popular Repositories', style: secondary),
            ),
            repos,
          ],
        ),
      ),
    );
  }
}
