import 'screens/projects.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var answer = ' ';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      title: 'TestView',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Test View'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
              },
              tooltip: "Refresh",
            ),
          ],
        ),
        body: ProjectWidget(),
        // RepositoryWidget(
        //   projectName: answer,
        // ),
      ),
    );
  }
}
