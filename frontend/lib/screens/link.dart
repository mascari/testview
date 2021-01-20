import 'package:TestView/requests/associations.dart';
import 'package:TestView/requests/authors.dart';
import 'package:TestView/requests/commits.dart';
import 'package:TestView/requests/features.dart';
import 'package:TestView/requests/files.dart';
import 'package:TestView/requests/reports.dart';
import 'package:TestView/requests/repositories.dart';
import 'package:TestView/resources/font.dart';
import 'package:TestView/screens/reports.dart';
import 'package:TestView/screens/repositories.dart';
import 'package:flutter/material.dart';

import 'commits.dart';
import 'associations.dart';
import 'authors.dart';
import 'features.dart';
import 'files.dart';

class LinkWidget extends StatefulWidget {
  LinkWidget(
      {Key key,
      this.projectName,
      this.repositoryName,
      this.listRepositories,
      this.listProjects})
      : super(key: key);
  final String projectName;
  final String repositoryName;
  final List<RepositoryObject> listRepositories;
  final List<String> listProjects;

  @override
  _LinkWidgetState createState() => _LinkWidgetState(
      projectName: projectName,
      repositoryName: repositoryName,
      listRepositories: listRepositories,
      listProjects: listProjects);
}

class _LinkWidgetState extends State<LinkWidget> {
  _LinkWidgetState(
      {this.projectName,
      this.repositoryName,
      this.listRepositories,
      this.listProjects});
  String projectName;
  String repositoryName;
  int _selectedIndex = 0;
  List<RepositoryObject> listRepositories;
  List<String> listProjects;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<RepositoryObject> listRepositoriesUpdated =
        List<RepositoryObject>(listRepositories.length - 1);

    int j = 0;
    for (int i = 0; i < listRepositories.length; i++) {
      if (listRepositories[i].name == repositoryName) {
        j--;
      } else {
        listRepositoriesUpdated[j] = listRepositories[i];
      }
      j++;
    }

    List<Widget> listView = List<Widget>(listRepositoriesUpdated.length + 3);

    DrawerHeader drawerHeader = DrawerHeader(
      child: Text('Project: $projectName \nRepository: $repositoryName',
          style: ktitleOne),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
      ),
    );

    ListTile listTileRepositoryList = ListTile(
      title: Text('Repository List:', style: ktextOne),
    );

    listView[0] = drawerHeader;
    listView[1] = listTileRepositoryList;

    for (int i = 2; i < listRepositoriesUpdated.length + 2; i++) {
      ListTile listTile = ListTile(
          title: Text('${listRepositoriesUpdated[i - 2].name}'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LinkWidget(
                    projectName: projectName,
                    repositoryName: listRepositoriesUpdated[i - 2].name,
                    listRepositories: listRepositories,
                    listProjects: listProjects,
                  ),
                ));
          });
      listView[i] = listTile;
    }
    ListTile listTileBackButton = ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Go back to Repositories'), Icon(Icons.arrow_back)],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepositoryWidget(
                  projectName: projectName,
                  listProjects: listProjects,
                ),
              ));
        });
    listView[listView.length - 1] = listTileBackButton;

    return Scaffold(
      body: FutureBuilder(
          future: Future.wait([
            getCommits(projectName, repositoryName),
            getFeatures(projectName, repositoryName),
            getAuthors(projectName, repositoryName),
            getFiles(projectName, repositoryName),
            getAssociations(projectName, repositoryName),
            getReports(projectName, repositoryName),
          ]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<Widget> _widgetOptions = <Widget>[
                CommitsWidget(
                  projectName: projectName,
                  repositoryName: repositoryName,
                  initialData: snapshot.data[0],
                  listView: listView,
                ),
                FeaturesWidget(
                  projectName: projectName,
                  repositoryName: repositoryName,
                  initialData: snapshot.data[1],
                  listView: listView,
                ),
                AuthorsWidget(
                  projectName: projectName,
                  repositoryName: repositoryName,
                  initialData: snapshot.data[2],
                  listView: listView,
                ),
                FilesWidget(
                  projectName: projectName,
                  repositoryName: repositoryName,
                  initialData: snapshot.data[3],
                  listView: listView,
                ),
                AssociationsWidget(
                  projectName: projectName,
                  repositoryName: repositoryName,
                  initialData: snapshot.data[4],
                  listView: listView,
                ),
                ReportsWidget(
                  projectName: projectName,
                  repositoryName: repositoryName,
                  initialData: snapshot.data[5],
                  listView: listView,
                ),
              ];
              return Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            title: Text('Commits'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.featured_play_list),
            title: Text('Features'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text('Authors'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Files'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            title: Text('Associations'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            title: Text('Reports'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
