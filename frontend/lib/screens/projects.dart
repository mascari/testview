import 'package:TestView/resources/font.dart';
import 'package:TestView/resources/size-config.dart';

import 'repositories.dart';
import 'package:flutter/material.dart';
import '../requests/projects.dart';
import '../resources/config.dart';

import 'package:flutter/services.dart' show rootBundle;

Future<String> loadAsset() async {
  return await rootBundle.loadString('version.txt');
}

class ProjectWidget extends StatefulWidget {
  ProjectWidget({Key key}) : super(key: key);

  @override
  _ProjectWidgetState createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  final TextEditingController _controllerProjectName = TextEditingController();
  bool _visible = false;

  bool wait = true;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return FutureBuilder(
      future: Future.wait([getProject(), loadAsset()]),
      // initialData: InitialData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          bool _visibilityWait =
              snapshot.connectionState == ConnectionState.done ? false : true;

          // print(snapshot.data.data);
          var dataOne = snapshot.data[0].data;
          var dataSplit = dataOne.split(',');
          int size;
          int sizeList;
          if (dataSplit.length > 2 * rowsPerTable) {
            size = 2 * rowsPerTable;
            sizeList = rowsPerTable;
          } else if (dataSplit.length < 2) {
            size = 0;
            sizeList = 0;
          } else {
            size = dataSplit.length;
            sizeList = size ~/ 2;
          }

          // o numero de dados vai ser a metade do tamanho (ex: se o tamanho for 6, existem 3 projects, nas posições 1, 3 e 5)

          List<String> finalSplit = new List(sizeList);

          for (int i = 0; i < size; i = i + 2) {
            int j = i ~/ 2;
            var dataSplitOne = dataSplit[i + 1].split(':');
            var dataSplitTwo = dataSplitOne[1].split('"');
            finalSplit[j] = (dataSplitTwo[1]);
          }

          return ListView(children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Projects: ', style: ktitleOne),
                  ],
                ),
              ],
            ),
            Column(
              children: finalSplit
                  .map<Widget>(
                    (project) => Column(
                      children: [
                        Container(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              child: Text(project, style: ktextOne),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RepositoryWidget(
                                        projectName: project,
                                        listProjects: finalSplit,
                                      ),
                                    ));
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: SizeConfig.blockSizeVertical * 4,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Delete $project?"),
                                    content: Text(
                                        "All the repositories from project $project will be lose!"),
                                    actions: [
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("No")),
                                      FlatButton(
                                        onPressed: () {
                                          deleteProject(project);
                                          getProject();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Yes"),
                                      )
                                    ],
                                    elevation: 24.0,
                                  ),
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            Container(height: 20),
            Visibility(
              visible: !_visible,
              child: Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      child: TextFormField(
                          style: ktextOne,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (finalSplit.contains(value)) {
                              return 'The project name needs to be unique';
                            } else {
                              return null;
                            }
                          },
                          controller: _controllerProjectName,
                          decoration: InputDecoration(
                              labelText: 'New Project', labelStyle: ktextOne)),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        size: SizeConfig.blockSizeVertical * 4,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_formKey.currentState.validate()) {
                            postProject(_controllerProjectName.text);
                            _controllerProjectName.text = '';
                            _visible = false;
                            getProject();
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _visibilityWait,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            Container(
              height: SizeConfig.blockSizeVertical * 50,
            ),
            Center(
              child: Text(snapshot.data[1]),
            )
          ]);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
