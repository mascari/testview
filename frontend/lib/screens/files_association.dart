import 'package:flutter/material.dart';
import '../requests/features.dart';
import '../requests/associations.dart';
import '../resources/config.dart';

class FeaturesAssociationObject {
  String featureName = '';
  String numberBugs = '';
  String numberFilesAssociated = '';
  bool value = false;
  FeaturesAssociationObject(
      {Key key,
      this.featureName,
      this.numberBugs,
      this.numberFilesAssociated,
      this.value});
}

class FilesAssociationWidget extends StatefulWidget {
  FilesAssociationWidget(
      {Key key, this.projectName, this.repositoryName, this.filePath})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final String filePath;

  @override
  _FilesAssociationWidgetState createState() => _FilesAssociationWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      filePath: filePath);
}

class _FilesAssociationWidgetState extends State<FilesAssociationWidget> {
  _FilesAssociationWidgetState(
      {this.projectName, this.repositoryName, this.filePath});
  String projectName;
  String repositoryName;
  String filePath;
  bool _visibilityWait;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - FilesAssociation: $filePath'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          getAssociations(projectName, repositoryName),
          getFeatures(projectName, repositoryName)
        ]),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            _visibilityWait =
                snapshot.connectionState == ConnectionState.done ? false : true;

            var dataOne = snapshot.data[1].data;
            var dataSplit = dataOne.split(',');
            int size;
            int sizeList;
            if (dataSplit.length > 4 * rowsPerTable) {
              size = 4 * rowsPerTable;
              sizeList = rowsPerTable;
            } else if (dataSplit.length < 4) {
              size = 0;
              sizeList = 0;
            } else {
              size = dataSplit.length;
              sizeList = size ~/ 4;
            }

            var dataOneAssociation = snapshot.data[0].data;
            var dataSplitAssociation = dataOneAssociation.split(',');
            int sizeAssociation;
            int sizeListAssociation;
            if (dataSplitAssociation.length > 60) {
              sizeAssociation = 60;
              sizeListAssociation = 20;
            } else if (dataSplitAssociation.length < 3) {
              sizeAssociation = 0;
              sizeListAssociation = 0;
            } else {
              sizeAssociation = dataSplitAssociation.length;
              sizeListAssociation = sizeAssociation ~/ 3;
            }

            List<FeaturesAssociationObject> listFilesAssociated =
                new List<FeaturesAssociationObject>(sizeList);

            for (int i = 0; i < size; i = i + 4) {
              int j = (i ~/ 4);
              //Fix the featureName String received from the server
              var dataSplitOne = dataSplit[i + 1].split(':');
              var dataSplitTwo = dataSplitOne[1].split('"');
              FeaturesAssociationObject feature =
                  new FeaturesAssociationObject(featureName: (dataSplitTwo[1]));
              listFilesAssociated[j] = feature;

              //Fix the numberBugs String received from the server
              dataSplitOne = dataSplit[i + 2].split(':');
              listFilesAssociated[j].numberBugs = dataSplitOne[1];

              //Fix the numberFilesAssociated String received from the server
              dataSplitOne = dataSplit[i + 3].split(':');
              listFilesAssociated[j].numberFilesAssociated = dataSplitOne[1][1];

              listFilesAssociated[j].value = false;
            }

            List<AssociationsObject> listAssociations =
                new List<AssociationsObject>(sizeListAssociation);

            for (int i = 0; i < sizeAssociation; i = i + 3) {
              int j = (i ~/ 3);
              //Fix the featureName String
              var dataSplitOneAssociation =
                  dataSplitAssociation[i + 1].split(':');
              var dataSplitTwoAssociation =
                  dataSplitOneAssociation[1].split('"');
              AssociationsObject association = new AssociationsObject(
                  featureName: dataSplitTwoAssociation[1]);
              listAssociations[j] = association;

              //Fix the filePath String
              dataSplitOneAssociation = dataSplitAssociation[i + 2].split(':');
              dataSplitTwoAssociation = dataSplitOneAssociation[1].split('"');
              listAssociations[j].filePath = dataSplitTwoAssociation[1];
            }

            for (int i = 0; i < sizeListAssociation; i++) {
              if (listAssociations[i].filePath == filePath) {
                for (int j = 0; j < sizeList; j++) {
                  if (listAssociations[i].featureName ==
                      listFilesAssociated[j].featureName) {
                    listFilesAssociated[j].value = true;
                  }
                }
              }
            }

            List<DataRow> dataRows = new List<DataRow>(sizeList);

            for (int i = 0; i < sizeList; i++) {
              DataRow data = new DataRow(
                cells: <DataCell>[
                  DataCell(Text(listFilesAssociated[i].featureName)),
                  DataCell(Text(listFilesAssociated[i].numberBugs)),
                  DataCell(Text(listFilesAssociated[i].numberFilesAssociated)),
                  DataCell(
                    Checkbox(
                        value: listFilesAssociated[i].value,
                        onChanged: (value) {
                          setState(() {
                            if (value) {
                              postAssociations(projectName, repositoryName,
                                  listFilesAssociated[i].featureName, filePath);
                              getAssociations(projectName, repositoryName);
                            } else if (!value) {
                              deleteAssociations(projectName, repositoryName,
                                  listFilesAssociated[i].featureName, filePath);
                              getAssociations(projectName, repositoryName);
                            }
                          });
                        }),
                  ),
                ],
              );
              dataRows[i] = data;
            }

            return ListView(scrollDirection: Axis.vertical, children: [
              Column(children: [
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text('Feature Name')),
                      DataColumn(label: Text('Bugs')),
                      DataColumn(label: Text('Files Associated')),
                      DataColumn(label: Text('Associated')),
                    ],
                    rows: dataRows,
                  ),
                ),
              ]),
            ]);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
