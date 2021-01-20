import 'package:flutter/material.dart';
import '../requests/associations.dart';

class AssociationsWidget extends StatefulWidget {
  AssociationsWidget(
      {Key key,
      this.projectName,
      this.repositoryName,
      this.initialData,
      this.listView})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final Associations initialData;
  final List<Widget> listView;

  @override
  _AssociationsWidgetState createState() => _AssociationsWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      initialData: initialData,
      listView: listView);
}

class _AssociationsWidgetState extends State<AssociationsWidget> {
  _AssociationsWidgetState(
      {this.projectName, this.repositoryName, this.initialData, this.listView});
  String projectName;
  String repositoryName;
  Associations initialData;
  bool update = false;
  List<Widget> listView;

  @override
  Widget build(BuildContext context) {
    bool _visibilityWait = false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - Associations'),
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
        future: getAssociations(projectName, repositoryName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _visibilityWait =
                snapshot.connectionState != ConnectionState.done && update
                    ? true
                    : false;
            update = false;

            List<AssociationsObject> listAssociations =
                snapToDataAssociation(snapshot.data.data);

            List<DataRow> dataRows = new List<DataRow>(listAssociations.length);

            for (int i = 0; i < listAssociations.length; i++) {
              DataRow data = new DataRow(cells: <DataCell>[
                DataCell(Text(listAssociations[i].featureName)),
                DataCell(Text(listAssociations[i].filePath)),
                DataCell(Center(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        deleteAssociations(
                            projectName,
                            repositoryName,
                            listAssociations[i].featureName,
                            listAssociations[i].filePath);
                        getAssociations(projectName, repositoryName);
                      });
                    },
                  ),
                )),
              ]);
              dataRows[i] = data;
            }

            return ListView(scrollDirection: Axis.vertical, children: [
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
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: <DataColumn>[
                            DataColumn(label: Text('Feature')),
                            DataColumn(label: Text('Files')),
                            DataColumn(label: Text('Delete'))
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
