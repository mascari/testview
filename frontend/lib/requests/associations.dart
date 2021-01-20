import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resources/config.dart';

class Associations {
  final String data;
  Associations({this.data});
  factory Associations.fromJson(Map<String, dynamic> json) {
    return Associations(
      data: json['data'],
    );
  }
}

class AssociationsObject {
  String featureName = '';
  String filePath = '';
  AssociationsObject({Key key, this.featureName, this.filePath});
}

List<AssociationsObject> snapToDataAssociation(var data) {
  var dataSplit = data.split(',');
  int size;
  int sizeList;
  if (dataSplit.length > 3 * rowsPerTable) {
    size = 3 * rowsPerTable;
    sizeList = rowsPerTable;
  } else if (dataSplit.length < 3) {
    size = 0;
    sizeList = 0;
  } else {
    size = dataSplit.length;
    sizeList = size ~/ 3;
  }

  List<AssociationsObject> listAssociations =
      new List<AssociationsObject>(sizeList);

  for (int i = 0; i < size; i = i + 3) {
    int j = (i ~/ 3);
    var dataSplitOne = dataSplit[i + 1].split(':');
    var dataSplitTwo = dataSplitOne[1].split('"');

    AssociationsObject featureName =
        new AssociationsObject(featureName: dataSplitTwo[1]);
    listAssociations[j] = featureName;

    dataSplitOne = dataSplit[i + 2].split(':');
    dataSplitTwo = dataSplitOne[1].split('"');

    listAssociations[j].filePath = dataSplitTwo[1].replaceAll("\\\\", "\\");
  }
  return listAssociations;
}

Future<Associations> getAssociations(
    String projectName, String repositoryName) async {
  var response = await http.get(
      '$urlBackend/associations?repository_name=$repositoryName&project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code getAssociations: $statusCode');
  if (response.statusCode == 201) {
    return Associations.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Associations.');
  }
}

void deleteAssociations(String projectName, String repositoryName,
    String featureName, String filePath) async {
  var response = await http.delete(
      '$urlBackend/associations?repository_name=$repositoryName&project_name=$projectName&feature_name=$featureName&file_path=$filePath');

  final statusCode = response.statusCode;
  print('Response Status code deleteAssociations: $statusCode');
}

void postAssociations(String projectName, String repositoryName,
    String featureName, String filePath) async {
  filePath = filePath.replaceAll('"', '');
  var response = await http.post(
    '$urlBackend/associations',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'repository_name': repositoryName,
      'feature_name': featureName,
      'file_path': filePath
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code postAssociations: $statusCode');
}
