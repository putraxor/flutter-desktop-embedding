import 'package:example_flutter/debugging.md.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
        platform: TargetPlatform.iOS,
      ),
      debugShowCheckedModeBanner: false,
      home: StarterPage(),
    );
  }
}

class StarterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: FlutterLogo(
                size: 100,
                style: FlutterLogoStyle.stacked,
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Markdown(
                  data: markdown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
