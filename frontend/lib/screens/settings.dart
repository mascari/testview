import 'package:TestView/resources/font.dart';
import 'package:TestView/resources/size-config.dart';
import '../requests/settings.dart';
import '../resources/config.dart';

import 'package:flutter/material.dart';

class FileExtensionsObject {
  String data = '';
  FileExtensionsObject({Key key, this.data});
}

class SettingsWidget extends StatefulWidget {
  SettingsWidget({Key key, this.projectName}) : super(key: key);
  final String projectName;

  @override
  _SettingsWidgetState createState() =>
      _SettingsWidgetState(projectName: projectName);
}

class _SettingsWidgetState extends State<SettingsWidget> {
  _SettingsWidgetState({this.projectName});
  String projectName;

  final TextEditingController _controllerDaysRetrieval =
      TextEditingController();

  final TextEditingController _controllerFileExtension =
      TextEditingController(text: '');
  // String _days = '15';

  final _formKey = GlobalKey<FormState>();
  final _formKeyFile = GlobalKey<FormState>();
  bool _visibilityNewFileExtension = true;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName, style: ktitleAppbar),
      ),
      body: FutureBuilder(
        future:
            Future.wait([getDays(projectName), getFileExtensions(projectName)]),
        // initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            bool _visibilityWait =
                snapshot.connectionState == ConnectionState.done ? false : true;

            _controllerFileExtension.text = '';

            _controllerDaysRetrieval.text =
                snapshot.data[0].data != null ? snapshot.data[0].data : '0';

            var dataOne = snapshot.data[1].data;
            var dataSplit = dataOne.split(',');
            int size;
            int sizeList;
            if (dataSplit.length > rowsPerTable) {
              size = rowsPerTable;
              sizeList = rowsPerTable;
            } else if (dataSplit.length <= 1) {
              size = 0;
              sizeList = 0;
            } else {
              size = dataSplit.length;
              sizeList = size;
            }

            List<FileExtensionsObject> listFileExtensions =
                new List<FileExtensionsObject>(sizeList);

            for (int i = 0; i < size; i = i + 1) {
              int j = i;
              var dataSplitOne = dataSplit[i].split('"');

              FileExtensionsObject fileExtension =
                  new FileExtensionsObject(data: dataSplitOne[1]);

              listFileExtensions[j] = fileExtension;
            }

            List<Widget> chips = List();
            listFileExtensions.forEach((item) {
              chips.add(Container(
                child: Chip(
                  label: Text(item.data),
                  onDeleted: () {
                    setState(() {
                      deleteFileExtensions(projectName, item.data);
                      getFileExtensions(projectName);
                    });
                  },
                ),
              ));
            });

            return ListView(children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Settings: ', style: ktitleOne),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        iconSize: SizeConfig.blockSizeVertical * 4,
                        onPressed: () {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: SizeConfig.blockSizeVertical * 30,
                          child: TextFormField(
                              style: ktextOne,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                } else {
                                  return null;
                                }
                              },
                              controller: _controllerDaysRetrieval,
                              decoration: InputDecoration(
                                  labelText: 'Days Retrieval',
                                  labelStyle: ktextOne)),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            size: SizeConfig.blockSizeVertical * 4,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                postDays(
                                    projectName, _controllerDaysRetrieval.text);
                              }
                            });
                          },
                        ),
                        Tooltip(
                          message:
                              "Number of days in the past to analyze the development history. \nExample: 15 days ago, considering the current date of today's system",
                          child: Icon(Icons.help_outline),
                        )
                      ],
                    ),
                  ),
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
              Container(
                height: 50,
              ),
              Column(
                children: [Text('File Extensions Permited:', style: ktitleOne)],
              ),
              Wrap(
                spacing: 15,
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                children: chips,
              ),
              Container(height: 20),
              Visibility(
                visible: _visibilityNewFileExtension,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      child:
                          Text('New File Extension...       ', style: ktextOne),
                      onPressed: () => setState(() {
                        _visibilityNewFileExtension = false;
                      }),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !_visibilityNewFileExtension,
                child: Form(
                  key: _formKeyFile,
                  child: Column(children: [
                    Container(
                        width: 200,
                        child: TextFormField(
                          onFieldSubmitted: (value) {
                            setState(() {
                              postFileExtensions(projectName, value);
                            });
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else {
                              return null;
                            }
                          },
                          controller: _controllerFileExtension,
                          decoration:
                              InputDecoration(labelText: 'New File Extension'),
                        )),
                  ]),
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
