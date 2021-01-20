import 'package:TestView/resources/font.dart';
import 'package:flutter/material.dart';
import '../requests/repositories.dart';

class RepositoryEditWidget extends StatefulWidget {
  RepositoryEditWidget({Key key, this.projectName, this.repositoryName})
      : super(key: key);
  final String projectName;
  final String repositoryName;

  @override
  _RepositoryEditWidgetState createState() => _RepositoryEditWidgetState(
      projectName: projectName, repositoryName: repositoryName);
}

class _RepositoryEditWidgetState extends State<RepositoryEditWidget> {
  _RepositoryEditWidgetState({this.projectName, this.repositoryName});
  String projectName;
  String repositoryName;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool check = false;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controllerRepositoryName =
        TextEditingController();
    _controllerRepositoryName.text = repositoryName;

    Icon iconButton = Icon(Icons.edit);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(projectName, style: ktitleAppbar),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  child: TextFormField(
                    controller: _controllerRepositoryName,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: iconButton,
                  onPressed: () {
                    _scaffoldKey.currentState
                      ..showBottomSheet((context) {
                        return Container(
                          height: 200,
                          color: Colors.grey,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                    'Rename $repositoryName to ${_controllerRepositoryName.text}'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                        child: const Text('Confirm'),
                                        onPressed: () {
                                          putRepository(
                                              projectName,
                                              repositoryName,
                                              _controllerRepositoryName.text,
                                              '_controllerUrl');
                                          getRepository(projectName);
                                          Navigator.pop(context);
                                        }),
                                    Container(
                                      width: 20,
                                    ),
                                    RaisedButton(
                                      child: const Text('Undo'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                    // deleteRepository(projectName, repositoryName);
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 20,
          ),
          RaisedButton(
            color: Colors.red,
            child: Text('DELETE REPOSITORY'),
            onPressed: () {
              // deleteRepository(projectName, repositoryName);
              _scaffoldKey.currentState.showBottomSheet((context) {
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Deleting $repositoryName...'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RaisedButton(
                                color: Colors.red,
                                child: const Text('Confirm'),
                                onPressed: () {
                                  deleteRepository(projectName, repositoryName);
                                  int count = 0;
                                  getRepository(projectName);
                                  Navigator.popUntil(context, (route) {
                                    return count++ == 2;
                                  });
                                }),
                            Container(
                              width: 20,
                            ),
                            RaisedButton(
                                child: const Text('Undo'),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
              //Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
