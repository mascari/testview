import 'package:TestView/screens/files_association.dart';
import 'package:flutter/material.dart';
import '../requests/files.dart';

class FilesWidget extends StatefulWidget {
  FilesWidget(
      {Key key,
      this.projectName,
      this.repositoryName,
      this.initialData,
      this.listView})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final Files initialData;
  final List<Widget> listView;

  @override
  _FilesWidgetState createState() => _FilesWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      initialData: initialData,
      listView: listView);
}

class _FilesWidgetState extends State<FilesWidget> {
  _FilesWidgetState(
      {this.projectName, this.repositoryName, this.initialData, this.listView});
  String projectName;
  String repositoryName;
  Files initialData;
  List<Widget> listView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - Files'),
      ),
      drawer: Drawer(
        child: ListView(children: listView, padding: EdgeInsets.zero),
      ),
      body: FutureBuilder(
        initialData: initialData,
        future: getFiles(projectName, repositoryName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<FilesObject> listFiles = snapToDataFile(snapshot.data.data);

            List<DataRow> dataRows = new List<DataRow>(listFiles.length);

            for (int i = 0; i < listFiles.length; i++) {
              DataRow data = new DataRow(cells: <DataCell>[
                DataCell(Text(listFiles[i].fileName)),
                DataCell(Text(listFiles[i].filePath.replaceAll("\\\\", "\\"))),
                DataCell(Text(listFiles[i].numberFeatures)),
                DataCell(Text(listFiles[i].date)),
                DataCell(RaisedButton(
                    child: Text('Associate'),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilesAssociationWidget(
                              projectName: projectName,
                              repositoryName: repositoryName,
                              filePath: listFiles[i].filePath),
                        ))))
              ]);
              dataRows[i] = data;
            }

            return ListView(scrollDirection: Axis.vertical, children: [
              Column(children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text('File Name')),
                      DataColumn(label: Text('File Path')),
                      DataColumn(label: Text('Features')),
                      DataColumn(label: Text('Data')),
                      DataColumn(label: Text('Details')),
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
