import 'dart:async';

import 'package:TestView/screens/settings.dart';
import 'package:flutter/material.dart';
import '../requests/commits.dart';

class CommitsWidget extends StatefulWidget {
  CommitsWidget(
      {Key key,
      this.projectName,
      this.repositoryName,
      this.initialData,
      this.listView})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final Commits initialData;
  final List<Widget> listView;

  @override
  _CommitsWidgetState createState() => _CommitsWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      initialData: initialData,
      listView: listView);
}

class _CommitsWidgetState extends State<CommitsWidget> {
  _CommitsWidgetState(
      {this.projectName, this.repositoryName, this.initialData, this.listView});
  String projectName;
  String repositoryName;
  bool sort = true;
  bool _ascending = false;
  int _column = 1;
  List<Widget> listView;
  List<CommitsObject> commits;
  List<CommitsObject> selectedcommits;
  Commits initialData;
  bool update = false;
  double checkCommits = 0.1;
  Timer timer;
  void handleCheckCommits() {
    if (update) {
      setState(() {
        if (checkCommits < 0.95) {
          checkCommits = checkCommits + 1 / 20;
        }
      });
    } else {
      checkCommits = 0.05;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _visibilityWait = false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - Commits'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsWidget(projectName: projectName),
                  ));
            },
            tooltip: "Settings",
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                putCommits(projectName, repositoryName);
                getCommits(projectName, repositoryName);
                update = true;
              });
            },
            tooltip: "Check for new commits",
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(children: listView, padding: EdgeInsets.zero),
      ),
      body: FutureBuilder(
        future: getCommits(projectName, repositoryName),
        initialData: initialData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.connectionState != ConnectionState.done && update) {
              _visibilityWait = true;
              timer = Timer.periodic(
                  Duration(seconds: 4), (Timer t) => handleCheckCommits());
            } else {
              _visibilityWait = false;
              update = false;
            }

            List<CommitsObject> listCommits =
                snapToDataCommits(snapshot.data.data);
            //  METHOD TO SORT THE TABLE
            // Column Author
            if (_column == 0) {
              if (_ascending) {
                listCommits.sort((a, b) => a.author.compareTo(b.author));
              } else {
                listCommits.sort((a, b) => b.author.compareTo(a.author));
              }
            }
            //Column Date
            if (_column == 1) {
              if (_ascending) {
                listCommits.sort((a, b) => a.date.compareTo(b.date));
              } else {
                listCommits.sort((a, b) => b.date.compareTo(a.date));
              }
            }
            //Column Message
            if (_column == 2) {
              if (_ascending) {
                listCommits.sort((a, b) => a.message.compareTo(b.message));
              } else {
                listCommits.sort((a, b) => b.message.compareTo(a.message));
              }
            }
            //Column Number of Files
            if (_column == 3) {
              if (_ascending) {
                listCommits
                    .sort((a, b) => a.numberFiles.compareTo(b.numberFiles));
              } else {
                listCommits
                    .sort((a, b) => b.numberFiles.compareTo(a.numberFiles));
              }
            }
            //END OF METHOD SORT THE TABLE

            List<DataRow> dataRows = new List<DataRow>(listCommits.length);

            // Create the list of Data Row ( rows of the table)
            // Add the list of commits to each row, and create the list of rows
            for (int i = 0; i < listCommits.length; i++) {
              DataRow data = new DataRow(cells: <DataCell>[
                DataCell(
                  Text(listCommits[i].author),
                ),
                DataCell(Text(listCommits[i].date)),
                DataCell(Text(
                  listCommits[i].message,
                )),
                DataCell(Text('${listCommits[i].numberFiles}')),
              ]);
              dataRows[i] = data;
            }

            return ListView(
              children: [
                Visibility(
                  visible: _visibilityWait,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(
                          value: checkCommits,
                          backgroundColor: Colors.grey,
                        ),
                        Text('Checking for new commits...')
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        sortAscending: sort,
                        sortColumnIndex: _column,
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text('Authors'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                _ascending = ascending;
                                _column = 0;
                              });
                            },
                          ),
                          DataColumn(
                            label: Text('Date'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                _ascending = ascending;
                                _column = 1;
                              });
                            },
                          ),
                          DataColumn(
                            label: Text('Message'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                _ascending = ascending;
                                _column = 2;
                              });
                            },
                          ),
                          DataColumn(
                            label: Text('Number of Files'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                _ascending = ascending;
                                _column = 3;
                              });
                            },
                          ),
                        ],
                        rows: dataRows,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
