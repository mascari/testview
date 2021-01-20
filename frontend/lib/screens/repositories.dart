import 'dart:async';

import 'package:TestView/main.dart';
import 'package:TestView/resources/font.dart';
import 'package:TestView/resources/size-config.dart';
import 'package:TestView/screens/settings.dart';
import 'link.dart';
import 'package:flutter/material.dart';
import '../requests/repositories.dart';

class RepositoryWidget extends StatefulWidget {
  RepositoryWidget({Key key, this.projectName, this.listProjects})
      : super(key: key);
  final String projectName;
  final List<String> listProjects;

  @override
  _RepositoryWidgetState createState() => _RepositoryWidgetState(
      projectName: projectName, listProjects: listProjects);
}

class _RepositoryWidgetState extends State<RepositoryWidget> {
  _RepositoryWidgetState({this.projectName, this.listProjects});
  String projectName;
  bool _visibility = true;
  bool creating = false;
  final _formKey = GlobalKey<FormState>();
  final _formKeyUser = GlobalKey<FormState>();
  final _formKeyEdit = GlobalKey<FormState>();

  List<String> listProjects;

  String repositoryNameBack = '';
  String repositoryUrlBack = '';

  bool check = false;

  Timer timer;

  double checkCommits = 0.1;

  void handleCheckCommits() {
    if (creating) {
      setState(() {
        if (checkCommits < 0.95) {
          checkCommits = checkCommits + 1 / 20;
        }
      });
    } else {
      checkCommits = 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controllerRepositoryName =
        TextEditingController();
    final TextEditingController _controllerUrlName = TextEditingController();
    final TextEditingController _controllerUsername = TextEditingController();
    final TextEditingController _controllerPassword = TextEditingController();
    final TextEditingController _controllerRepositoryNameEdit =
        TextEditingController();
    final TextEditingController _controllerRepositoryUrlEdit =
        TextEditingController();

    _controllerRepositoryName.text = repositoryNameBack;
    _controllerUrlName.text = repositoryUrlBack;

    bool _visibilityWait = false;
    bool _visibilityWaitCreating = false;

    List<String> listProjectUpdated = List<String>(listProjects.length - 1);

    int j = 0;
    for (int i = 0; i < listProjects.length; i++) {
      if (listProjects[i] == projectName) {
        j--;
      } else {
        listProjectUpdated[j] = listProjects[i];
      }
      j++;
    }

    List<Widget> listView = List<Widget>(listProjectUpdated.length + 3);

    DrawerHeader drawerHeader = DrawerHeader(
      child: Text('Project Name: $projectName', style: ktitleOne),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
      ),
    );

    ListTile listTileProjectList = ListTile(
      title: Text('Project List:', style: ktextOne),
    );

    listView[0] = drawerHeader;
    listView[1] = listTileProjectList;

    for (int i = 2; i < listProjectUpdated.length + 2; i++) {
      ListTile listTile = ListTile(
          title: Text('${listProjectUpdated[i - 2]}'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RepositoryWidget(
                    projectName: listProjectUpdated[i - 2],
                    listProjects: listProjects,
                  ),
                ));
          });
      listView[i] = listTile;
    }
    ListTile listTileBackButton = ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Go back to Projects'), Icon(Icons.arrow_back)],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
          );
        });
    listView[listView.length - 1] = listTileBackButton;

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName, style: ktitleAppbar),
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
                creating = false;
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
        future: getRepository(projectName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _visibilityWait =
                snapshot.connectionState != ConnectionState.done && !creating
                    ? true
                    : false;

            if (snapshot.connectionState != ConnectionState.done && creating) {
              _visibilityWaitCreating = true;
              timer = Timer.periodic(
                  Duration(seconds: 4), (Timer t) => handleCheckCommits());
            } else {
              _visibilityWaitCreating = false;
              creating = false;
            }

            List<RepositoryObject> listRepositories =
                snapToDataCommits(snapshot.data.data);

            return ListView(children: [
              Column(
                children: [
                  Text('Repositories from project $projectName: ',
                      style: ktitleOne),
                ],
              ),
              Column(
                children: listRepositories
                    .map<Widget>(
                      (repository) => Column(
                        children: [
                          Container(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                child: Text(repository.name, style: ktextOne),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LinkWidget(
                                            projectName: projectName,
                                            repositoryName: repository.name,
                                            listRepositories: listRepositories,
                                            listProjects: listProjects),
                                      ));
                                },
                              ),
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      creating = false;
                                      _controllerRepositoryNameEdit.text =
                                          repository.name;
                                      _controllerRepositoryUrlEdit.text =
                                          repository.url;
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title:
                                              Text("Edit ${repository.name}"),
                                          content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Form(
                                                key: _formKeyEdit,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: SizeConfig
                                                              .screenWidth *
                                                          0.7,
                                                      child: TextFormField(
                                                        decoration: InputDecoration(
                                                            labelText:
                                                                'New Repository Name:'),
                                                        controller:
                                                            _controllerRepositoryNameEdit,
                                                        validator: (value) {
                                                          bool equal = false;
                                                          for (int i = 0;
                                                              i <
                                                                  listRepositories
                                                                      .length;
                                                              i++) {
                                                            if (listRepositories[
                                                                        i]
                                                                    .name ==
                                                                _controllerRepositoryNameEdit
                                                                    .text) {
                                                              equal = true;
                                                            }
                                                          }
                                                          if (value.isEmpty) {
                                                            return 'Please enter some text';
                                                          } else if (equal &&
                                                              _controllerRepositoryNameEdit
                                                                      .text !=
                                                                  repository
                                                                      .name) {
                                                            return 'The repository name needs to be unique';
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    Container(
                                                      width: SizeConfig
                                                              .screenWidth *
                                                          0.7,
                                                      child: TextFormField(
                                                        decoration:
                                                            InputDecoration(
                                                                labelText:
                                                                    'New Url:'),
                                                        controller:
                                                            _controllerRepositoryUrlEdit,
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
                                                          'Delete Repository ${repository.name}'),
                                                      content: Text(
                                                          'All the data from repository ${repository.name} will be lose!'),
                                                      actions: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text("No")),
                                                        FlatButton(
                                                          onPressed: () {
                                                            deleteRepository(
                                                                projectName,
                                                                repository
                                                                    .name);
                                                            getRepository(
                                                                projectName);
                                                            int count = 0;
                                                            Navigator.popUntil(
                                                                context,
                                                                (route) {
                                                              return count++ ==
                                                                  2;
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
                                                if (_formKeyEdit.currentState
                                                    .validate()) {
                                                  putRepository(
                                                      projectName,
                                                      repository.name,
                                                      _controllerRepositoryNameEdit
                                                          .text,
                                                      _controllerRepositoryUrlEdit
                                                          .text);
                                                  getRepository(projectName);
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
                                    });
                                  }),
                            ],
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              Container(height: 20),
              Visibility(
                visible: _visibility,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      child: Text('New Repository...             ',
                          style: ktextOne),
                      onPressed: () => setState(() {
                        creating = false;
                        _visibility = false;
                      }),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !_visibility,
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    Container(
                        width: 400,
                        child: TextFormField(
                          validator: (value) {
                            bool equal = false;
                            for (int i = 0; i < listRepositories.length; i++) {
                              if (listRepositories[i].name ==
                                  _controllerRepositoryName.text) {
                                equal = true;
                              }
                            }
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (equal) {
                              return 'The repository name needs to be unique';
                            } else {
                              return null;
                            }
                          },
                          controller: _controllerRepositoryName,
                          decoration:
                              InputDecoration(labelText: 'New Repository Name'),
                        )),
                    Container(
                        width: 400,
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else {
                              return null;
                            }
                          },
                          controller: _controllerUrlName,
                          decoration:
                              InputDecoration(labelText: "Repository's url"),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Private repository from GitHub? ',
                            style: ktextOne),
                        Checkbox(
                            value: check,
                            onChanged: (value) {
                              setState(() {
                                creating = false;
                                check = value;
                                repositoryNameBack =
                                    _controllerRepositoryName.text;
                                repositoryUrlBack = _controllerUrlName.text;
                              });
                            }),
                      ],
                    ),
                    Visibility(
                      visible: check,
                      child: Form(
                        key: _formKeyUser,
                        child: Column(children: [
                          Container(
                              width: 200,
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _controllerUsername,
                                decoration: InputDecoration(
                                    labelText: "Github's username"),
                              )),
                          Container(
                              width: 200,
                              child: TextFormField(
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _controllerPassword,
                                decoration: InputDecoration(
                                    labelText: "Github's password"),
                              )),
                        ]),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlatButton(
                          child: Text('Cancel', style: ktextOne),
                          onPressed: () {
                            setState(() {
                              creating = false;
                              _visibility = true;
                              repositoryNameBack =
                                  _controllerRepositoryName.text;
                              repositoryUrlBack = _controllerUrlName.text;
                            });
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Submit',
                            style: ktextOne,
                          ),
                          onPressed: () {
                            setState(() {
                              repositoryNameBack =
                                  _controllerRepositoryName.text;
                              repositoryUrlBack = _controllerUrlName.text;
                              if (_formKey.currentState.validate() &&
                                  (check &&
                                          _formKeyUser.currentState
                                              .validate() ||
                                      !check)) {
                                creating = true;
                                String repositoryUrl = _controllerUrlName.text;
                                if (check) {
                                  repositoryUrl =
                                      _controllerUrlName.text.substring(0, 8) +
                                          _controllerUsername.text +
                                          ":" +
                                          _controllerPassword.text +
                                          "@" +
                                          _controllerUrlName.text.substring(8);
                                }
                                postRepository(
                                    projectName,
                                    _controllerRepositoryName.text,
                                    repositoryUrl);
                                _controllerRepositoryName.text = '';
                                _controllerUrlName.text = '';
                                _visibility = true;
                                getRepository(projectName);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ]),
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
              Visibility(
                visible: _visibilityWaitCreating,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        value: checkCommits,
                        backgroundColor: Colors.grey,
                      ),
                      Text('Creating a new Repository...')
                    ],
                  ),
                ),
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
