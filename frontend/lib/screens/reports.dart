import 'package:TestView/resources/size-config.dart';
import 'package:flutter/material.dart';
import '../requests/reports.dart';

class ReportsWidget extends StatefulWidget {
  ReportsWidget(
      {Key key,
      this.projectName,
      this.repositoryName,
      this.initialData,
      this.listView})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final Reports initialData;
  final List<Widget> listView;

  @override
  _ReportsWidgetState createState() => _ReportsWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      initialData: initialData,
      listView: listView);
}

class _ReportsWidgetState extends State<ReportsWidget> {
  _ReportsWidgetState(
      {this.projectName, this.repositoryName, this.initialData, this.listView});
  String projectName;
  String repositoryName;
  bool sort = true;
  bool _ascending = false;
  int _column = 6;
  List<ReportsObject> reports;
  List<ReportsObject> selectedReports;
  List<Widget> listView;
  Reports initialData;
  bool update = false;

  final TextEditingController _controllerDate = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bool _visibilityWait = false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - Reports'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                update = true;
              });
            },
            tooltip: "Refresh",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(children: listView, padding: EdgeInsets.zero),
      ),
      body: FutureBuilder(
        initialData: initialData,
        future: getReports(projectName, repositoryName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _visibilityWait =
                snapshot.connectionState != ConnectionState.done && update
                    ? true
                    : false;
            update = false;

            List<ReportsObject> listReports =
                snapToDataReport(snapshot.data.data);

            //  METHOD TO SORT THE TABLE
            // Column Date
            if (_column == 0) {
              if (_ascending) {
                listReports.sort((a, b) => a.date.compareTo(b.date));
              } else {
                listReports.sort((a, b) => b.date.compareTo(a.date));
              }
            }
            //Column Feature Name
            if (_column == 1) {
              if (_ascending) {
                listReports
                    .sort((a, b) => a.featureName.compareTo(b.featureName));
              } else {
                listReports
                    .sort((a, b) => b.featureName.compareTo(a.featureName));
              }
            }
            //Column Bugs
            if (_column == 2) {
              if (_ascending) {
                listReports
                    .sort((a, b) => a.numberBugs.compareTo(b.numberBugs));
              } else {
                listReports
                    .sort((a, b) => b.numberBugs.compareTo(a.numberBugs));
              }
            }
            //Column Number of Files Associated
            if (_column == 3) {
              if (_ascending) {
                listReports.sort((a, b) =>
                    a.numberFilesAssociated.compareTo(b.numberFilesAssociated));
              } else {
                listReports.sort((a, b) =>
                    b.numberFilesAssociated.compareTo(a.numberFilesAssociated));
              }
            }
            //Column Number of Files Modified
            if (_column == 4) {
              if (_ascending) {
                listReports.sort((a, b) =>
                    a.numberFilesModified.compareTo(b.numberFilesModified));
              } else {
                listReports.sort((a, b) =>
                    b.numberFilesModified.compareTo(a.numberFilesModified));
              }
            }
            if (_column == 5) {
              if (_ascending) {
                listReports.sort((a, b) =>
                    a.averageCyclomaticComplexity.compareTo(b.averageCyclomaticComplexity));
              } else {
                listReports.sort((a, b) =>
                    b.averageCyclomaticComplexity.compareTo(a.averageCyclomaticComplexity));
              }
            }
            if (_column == 6) {
              if (_ascending) {
                listReports.sort((a, b) =>
                    a.averageDmmUnitComplexity.compareTo(b.averageDmmUnitComplexity));
              } else {
                listReports.sort((a, b) =>
                    b.averageDmmUnitComplexity.compareTo(a.averageDmmUnitComplexity));
              }
            }
            if (_column == 7) {
              if (_ascending) {
                listReports.sort((a, b) =>
                    a.averageDmmUnitInterfacing.compareTo(b.averageDmmUnitInterfacing));
              } else {
                listReports.sort((a, b) =>
                    b.averageDmmUnitInterfacing.compareTo(a.averageDmmUnitInterfacing));
              }
            }
            if (_column == 8) {
              if (_ascending) {
                listReports.sort((a, b) =>
                    a.averageDmmUnitSize.compareTo(b.averageDmmUnitSize));
              } else {
                listReports.sort((a, b) =>
                    b.averageDmmUnitSize.compareTo(a.averageDmmUnitSize));
              }
            }
            if (_column == 9) {
              if (_ascending) {
                listReports
                    .sort((a, b) => a.priorization.compareTo(b.priorization));
              } else {
                listReports
                    .sort((a, b) => b.priorization.compareTo(a.priorization));
              }
            }
            //END OF METHOD SORT THE TABLE

            List<DataRow> dataRows = new List<DataRow>(listReports.length);

            for (int i = 0; i < listReports.length; i++) {
              DataRow data = new DataRow(cells: <DataCell>[
                DataCell(Text(listReports[i].date)),
                DataCell(Text(listReports[i].featureName)),
                DataCell(Text(listReports[i].numberBugs)),
                DataCell(Text(listReports[i].numberFilesAssociated)),
                DataCell(Text(listReports[i].numberFilesModified)),
                DataCell(Text(listReports[i].averageCyclomaticComplexity)),
                DataCell(Text(listReports[i].averageDmmUnitComplexity)),
                DataCell(Text(listReports[i].averageDmmUnitInterfacing)),
                DataCell(Text(listReports[i].averageDmmUnitSize)),
                DataCell(Text("${listReports[i].priorization}")),
              ]);
              dataRows[i] = data;
            }

            return ListView(scrollDirection: Axis.vertical, children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('From Date:    '),
                      Form(
                        key: _formKey,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal * 12,
                          child: TextFormField(
                            controller: _controllerDate,
                            decoration: InputDecoration(
                                labelText: "YYYY-MM-DD:",
                                hintText: 'Ex: 2021-10-18'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            postReports(projectName, repositoryName,
                                _controllerDate.text);
                            getReports(projectName, repositoryName);
                            _controllerDate.text = '';
                          });
                        },
                        child: Text('Submit'),
                      )
                    ],
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
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          sortAscending: sort,
                          sortColumnIndex: _column,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text('Date'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 0;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Feature'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 1;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Defects'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 2;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Associated Files'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 3;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Modified Files'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 4;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Cyclomatic Complexity Average'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 5;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Unit Complexity Average'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 6;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Unit Interfacing Average'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 7;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Unit Size Average'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 8;
                                });
                              },
                            ),
                            DataColumn(
                              label: Text('Testing Importance Index'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  sort = !sort;
                                  _ascending = ascending;
                                  _column = 9;
                                });
                              },
                            ),
                          ],
                          rows: dataRows,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
