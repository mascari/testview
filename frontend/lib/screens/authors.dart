import 'package:flutter/material.dart';
import '../requests/authors.dart';

class AuthorsWidget extends StatefulWidget {
  AuthorsWidget(
      {Key key,
      this.projectName,
      this.repositoryName,
      this.initialData,
      this.listView})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final Authors initialData;
  final List<Widget> listView;

  @override
  _AuthorsWidgetState createState() => _AuthorsWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      initialData: initialData,
      listView: listView);
}

class _AuthorsWidgetState extends State<AuthorsWidget> {
  _AuthorsWidgetState(
      {this.projectName, this.repositoryName, this.initialData, this.listView});
  String projectName;
  String repositoryName;
  Authors initialData;
  List<Widget> listView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Project: $projectName and repository: $repositoryName - Authors'),
      ),
      drawer: Drawer(
        child: ListView(children: listView, padding: EdgeInsets.zero),
      ),
      body: FutureBuilder(
        initialData: initialData,
        future: getAuthors(projectName, repositoryName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<AuthorsObject> listAuthors =
                snapToDataAuthor(snapshot.data.data);

            List<DataRow> dataRows = new List<DataRow>(listAuthors.length);

            for (int i = 0; i < listAuthors.length; i++) {
              DataRow data = new DataRow(cells: <DataCell>[
                DataCell(Text(listAuthors[i].author)),
                DataCell(Text(listAuthors[i].date)),
                DataCell(Text(listAuthors[i].numberCommits)),
                DataCell(Text(listAuthors[i].numberLines)),
              ]);
              dataRows[i] = data;
            }

            return ListView(scrollDirection: Axis.vertical, children: [
              Column(
                children: [
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: <DataColumn>[
                            DataColumn(label: Text('Author')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Number Commits')),
                            DataColumn(label: Text('Number Lines')),
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
