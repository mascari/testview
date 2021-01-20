import 'package:flutter/material.dart';
import '../requests/associations.dart';
import '../requests/files.dart';
import '../resources/config.dart';

class FilesAssociationObject {
  String fileName = '';
  String filePath = '';
  String date = '';
  String featuresAssociated = '';
  bool value = false;
  FilesAssociationObject(
      {Key key,
      this.fileName,
      this.filePath,
      this.date,
      this.featuresAssociated,
      this.value});
}

class FeaturesAssociationWidget extends StatefulWidget {
  FeaturesAssociationWidget(
      {Key key, this.projectName, this.repositoryName, this.featureName})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final String featureName;

  @override
  _FeaturesAssociationWidgetState createState() =>
      _FeaturesAssociationWidgetState(
          projectName: projectName,
          repositoryName: repositoryName,
          featureName: featureName);
}

class _FeaturesAssociationWidgetState extends State<FeaturesAssociationWidget> {
  _FeaturesAssociationWidgetState(
      {this.projectName, this.repositoryName, this.featureName});
  String projectName;
  String repositoryName;
  String featureName;
  bool _visibilityWait;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - FeaturesAssociation: $featureName'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          getAssociations(projectName, repositoryName),
          getFiles(projectName, repositoryName)
        ]),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            _visibilityWait =
                snapshot.connectionState == ConnectionState.done ? false : true;

            var dataOne = snapshot.data[1].data;
            var dataSplit = dataOne.split(',');
            int size;
            int sizeList;
            if (dataSplit.length > 5 * rowsPerTable) {
              size = 5 * rowsPerTable;
              sizeList = rowsPerTable;
            } else if (dataSplit.length < 5) {
              size = 0;
              sizeList = 0;
            } else {
              size = dataSplit.length;
              sizeList = size ~/ 5;
            }

            var dataOneAssociation = snapshot.data[0].data;
            var dataSplitAssociation = dataOneAssociation.split(',');

            int sizeAssociation;
            int sizeListAssociation;
            if (dataSplitAssociation.length > 3 * rowsPerTable) {
              sizeAssociation = 3 * rowsPerTable;
              sizeListAssociation = rowsPerTable;
            } else if (dataSplitAssociation.length < 3) {
              sizeAssociation = 0;
              sizeListAssociation = 0;
            } else {
              sizeAssociation = dataSplitAssociation.length;
              sizeListAssociation = sizeAssociation ~/ 3;
            }

            List<FilesAssociationObject> listFilesAssociation =
                new List<FilesAssociationObject>(sizeList);

            for (int i = 0; i < size; i = i + 5) {
              int j = (i ~/ 5);
              var dataSplitOne = dataSplit[i + 1].split(':');
              var dataSplitTwo = dataSplitOne[1].split('"');

              FilesAssociationObject fileName =
                  FilesAssociationObject(fileName: dataSplitTwo[1]);

              listFilesAssociation[j] = fileName;

              //Fix the string to show the File Path
              dataSplitOne = dataSplit[i + 2].split(':');
              listFilesAssociation[j].filePath = dataSplitOne[1];
              listFilesAssociation[j].filePath =
                  listFilesAssociation[j].filePath.replaceAll('"', '');
              listFilesAssociation[j].filePath =
                  listFilesAssociation[j].filePath.replaceAll(' ', '');
              listFilesAssociation[j].filePath =
                  listFilesAssociation[j].filePath.replaceAll('\\\\', '\\');

              // Fix the string to show the Date
              dataSplitOne = dataSplit[i + 3].split(':');
              dataSplitTwo = dataSplitOne[1].split('"');
              var dataSplitThree = dataSplitTwo[1].split(' ');
              listFilesAssociation[j].date = dataSplitThree[0];

              //Fix the string to show the features associated
              dataSplitOne = dataSplit[i + 4].split(':');
              listFilesAssociation[j].featuresAssociated = dataSplitOne[1][1];

              listFilesAssociation[j].value = false;
            }

            List<AssociationsObject> listAssociations =
                new List<AssociationsObject>(sizeListAssociation);

            for (int i = 0; i < sizeAssociation; i = i + 3) {
              int j = (i ~/ 3);
              var dataSplitOneAssociation =
                  dataSplitAssociation[i + 1].split(':');
              var dataSplitTwoAssociation =
                  dataSplitOneAssociation[1].split('"');
              AssociationsObject feature = new AssociationsObject(
                  featureName: dataSplitTwoAssociation[1]);
              listAssociations[j] = feature;

              //Fix the FilePath String
              dataSplitOneAssociation = dataSplitAssociation[i + 2].split(':');
              dataSplitTwoAssociation = dataSplitOneAssociation[1].split('"');
              listAssociations[j].filePath = dataSplitTwoAssociation[1];
              listAssociations[j].filePath =
                  listAssociations[j].filePath.replaceAll('\\\\', '\\');
            }

            for (int i = 0; i < sizeListAssociation; i++) {
              if (listAssociations[i].featureName == featureName) {
                for (int j = 0; j < sizeList; j++) {
                  if (listAssociations[i].filePath ==
                      listFilesAssociation[j].filePath) {
                    listFilesAssociation[j].value = true;
                  }
                }
              }
            }

            List<DataRow> dataRows = new List<DataRow>(sizeList);

            for (int i = 0; i < sizeList; i++) {
              DataRow data = new DataRow(
                cells: <DataCell>[
                  DataCell(Text(listFilesAssociation[i].fileName)),
                  DataCell(Text(listFilesAssociation[i].filePath)),
                  DataCell(Text(listFilesAssociation[i].date)),
                  DataCell(Text(listFilesAssociation[i].featuresAssociated)),
                  DataCell(
                    Checkbox(
                        value: listFilesAssociation[i].value,
                        onChanged: (value) {
                          setState(() {
                            if (value) {
                              postAssociations(
                                  projectName,
                                  repositoryName,
                                  featureName,
                                  listFilesAssociation[i].filePath);
                              getAssociations(projectName, repositoryName);
                            } else if (!value) {
                              deleteAssociations(
                                  projectName,
                                  repositoryName,
                                  featureName,
                                  listFilesAssociation[i].filePath);
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
                      DataColumn(label: Text('File Name')),
                      DataColumn(label: Text('File Path')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Features Associated')),
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
