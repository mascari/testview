import 'package:TestView/resources/size-config.dart';
import 'package:TestView/screens/features_association.dart';
import 'package:flutter/material.dart';
import '../requests/features.dart';

class FeaturesWidget extends StatefulWidget {
  FeaturesWidget(
      {Key key,
      this.projectName,
      this.repositoryName,
      this.initialData,
      this.listView})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final Features initialData;
  final List<Widget> listView;

  @override
  _FeaturesWidgetState createState() => _FeaturesWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      initialData: initialData,
      listView: listView);
}

class _FeaturesWidgetState extends State<FeaturesWidget> {
  _FeaturesWidgetState(
      {this.projectName, this.repositoryName, this.initialData, this.listView});
  String projectName;
  String repositoryName;
  Features initialData;
  List<Widget> listView;
  final TextEditingController _controllerFeatureName = TextEditingController();
  final TextEditingController _controllerNumberBugs = TextEditingController();
  final _formKeyFeature = GlobalKey<FormState>();
  final _formKeyBugs = GlobalKey<FormState>();
  final _formKeyEdit = GlobalKey<FormState>();
  bool update = false;

  @override
  Widget build(BuildContext context) {
    bool _visibilityWait = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - Features'),
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
        future: getFeatures(projectName, repositoryName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _visibilityWait =
                snapshot.connectionState != ConnectionState.done && update
                    ? true
                    : false;
            update = false;

            List<FeaturesObject> listFeatures =
                snapToDataFeature(snapshot.data.data);

            List<TextEditingController> _controllerFeatureNameEdit =
                List<TextEditingController>(listFeatures.length);
            List<TextEditingController> _controllerNumberBugsEdit =
                List<TextEditingController>(listFeatures.length);

            List<DataRow> dataRows = new List<DataRow>(listFeatures.length + 1);

            for (int i = 0; i < listFeatures.length; i++) {
              DataRow data = new DataRow(cells: <DataCell>[
                DataCell(Text(listFeatures[i].featureName)),
                DataCell(Text(listFeatures[i].numberBugs)),
                DataCell(Text(listFeatures[i].numberFiles)),
                DataCell(Center(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _controllerFeatureNameEdit[i] =
                              new TextEditingController();
                          _controllerFeatureNameEdit[i].text =
                              listFeatures[i].featureName;
                          _controllerNumberBugsEdit[i] =
                              new TextEditingController();
                          _controllerNumberBugsEdit[i].text =
                              listFeatures[i].numberBugs;

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title:
                                  Text("Edit ${listFeatures[i].featureName}"),
                              content: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Form(
                                    key: _formKeyEdit,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: SizeConfig.screenWidth * 0.7,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                labelText:
                                                    'New Repository Name:'),
                                            controller:
                                                _controllerFeatureNameEdit[i],
                                            validator: (value) {
                                              bool equal = false;
                                              for (int j = 0;
                                                  j < listFeatures.length;
                                                  j++) {
                                                if (listFeatures[j]
                                                        .featureName ==
                                                    _controllerFeatureNameEdit[
                                                            i]
                                                        .text) {
                                                  equal = true;
                                                }
                                              }
                                              if (value.isEmpty) {
                                                return 'Please enter some text';
                                              } else if (equal &&
                                                  _controllerFeatureNameEdit[i]
                                                          .text !=
                                                      listFeatures[i]
                                                          .featureName) {
                                                return 'The feature name needs to be unique';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: SizeConfig.screenWidth * 0.7,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                labelText: 'New Number Bugs:'),
                                            controller:
                                                _controllerNumberBugsEdit[i],
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter some text';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RaisedButton(
                                    child: Text('DELETE'),
                                    color: Colors.red,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(
                                              'Delete Feature ${listFeatures[i].featureName}'),
                                          content: Text(
                                              'All the associations from feature ${listFeatures[i].featureName} will be lose!'),
                                          actions: [
                                            FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("No")),
                                            FlatButton(
                                              onPressed: () {
                                                deleteFeatures(
                                                    projectName,
                                                    repositoryName,
                                                    listFeatures[i]
                                                        .featureName);
                                                getFeatures(projectName,
                                                    repositoryName);
                                                int count = 0;
                                                Navigator.popUntil(context,
                                                    (route) {
                                                  return count++ == 2;
                                                });
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
                              actions: [
                                FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Discart")),
                                FlatButton(
                                  onPressed: () {
                                    if (_formKeyEdit.currentState.validate()) {
                                      putFeatures(
                                          projectName,
                                          repositoryName,
                                          listFeatures[i].featureName,
                                          _controllerFeatureNameEdit[i].text,
                                          _controllerNumberBugsEdit[i].text);
                                      getFeatures(projectName, repositoryName);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text("Save"),
                                )
                              ],
                              elevation: 24.0,
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.assignment_outlined),
                        onPressed: () {
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FeaturesAssociationWidget(
                                          projectName: projectName,
                                          repositoryName: repositoryName,
                                          featureName:
                                              listFeatures[i].featureName),
                                ));
                          });
                        },
                      )
                    ],
                  ),
                )),
              ]);
              dataRows[i] = data;
            }
            dataRows[listFeatures.length] = DataRow(cells: <DataCell>[
              DataCell(
                Form(
                    key: _formKeyFeature,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal * 12,
                      child: TextFormField(
                        controller: _controllerFeatureName,
                        decoration:
                            InputDecoration(labelText: "New feature name:"),
                        validator: (value) {
                          bool equal = false;
                          for (int i = 0; i < listFeatures.length; i++) {
                            if (listFeatures[i].featureName ==
                                _controllerFeatureName.text) {
                              equal = true;
                            }
                          }
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          } else if (equal) {
                            return 'The feature name must be unique!';
                          } else {
                            return null;
                          }
                        },
                      ),
                    )),
              ),
              DataCell(
                Form(
                    key: _formKeyBugs,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal * 12,
                      child: TextFormField(
                        controller: _controllerNumberBugs,
                        decoration:
                            InputDecoration(labelText: "Number of bugs open:"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some number';
                          } else {
                            return null;
                          }
                        },
                      ),
                    )),
              ),
              DataCell(Text(' ')),
              DataCell(IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (_formKeyFeature.currentState.validate() &&
                        _formKeyBugs.currentState.validate()) {
                      postFeatures(
                          projectName,
                          repositoryName,
                          _controllerFeatureName.text,
                          _controllerNumberBugs.text);
                      _controllerFeatureName.text = '';
                      _controllerNumberBugs.text = '';
                      getFeatures(projectName, repositoryName);
                    }
                  });
                },
              )),
            ]);

            return ListView(scrollDirection: Axis.vertical, children: [
              Column(
                children: [
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
                          columns: <DataColumn>[
                            DataColumn(label: Text('Feature')),
                            DataColumn(label: Text('Bugs')),
                            DataColumn(label: Text('Files')),
                            DataColumn(label: Text('Actions')),
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
