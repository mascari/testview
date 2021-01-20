import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resources/config.dart';

class Features {
  final String data;
  Features({this.data});
  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      data: json['data'],
    );
  }
}

class FeaturesObject {
  String featureName = '';
  String numberBugs = '';
  String numberFiles = '';
  FeaturesObject(
      {Key key, this.featureName, this.numberBugs, this.numberFiles});
}

List<FeaturesObject> snapToDataFeature(var data) {
  var dataSplit = data.split(',');
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

  List<FeaturesObject> listFeatures = new List<FeaturesObject>(sizeList);

  for (int i = 0; i < size; i = i + 4) {
    int j = (i ~/ 4);
    var dataSplitOne = dataSplit[i + 1].split(':');
    var dataSplitTwo = dataSplitOne[1].split('"');

    FeaturesObject featureName =
        new FeaturesObject(featureName: dataSplitTwo[1]);
    listFeatures[j] = featureName;

    dataSplitOne = dataSplit[i + 2].split(':');
    listFeatures[j].numberBugs = dataSplitOne[1];

    dataSplitOne = dataSplit[i + 3].split(':');
    listFeatures[j].numberFiles = dataSplitOne[1][1];
  }

  return listFeatures;
}

Future<Features> getFeatures(String projectName, String repositoryName) async {
  var response = await http.get(
      '$urlBackend/features?repository_name=$repositoryName&project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code getFeatures: $statusCode');
  if (response.statusCode == 201) {
    return Features.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Features.');
  }
}

void postFeatures(String projectName, String repositoryName, String featureName,
    String numBugs) async {
  var response = await http.post(
    '$urlBackend/features',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'repository_name': repositoryName,
      'feature_name': featureName,
      'number_bugs': numBugs
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code putFeatures: $statusCode');
}

void putFeatures(String projectName, String repositoryName, String featureName,
    String featureNameNew, String numBugs) async {
  var response = await http.put(
    '$urlBackend/features',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'repository_name': repositoryName,
      'feature_name': featureName,
      'feature_name_new': featureNameNew,
      'number_bugs': numBugs
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code putFeatures: $statusCode');
}

void deleteFeatures(
    String projectName, String repositoryName, String featureName) async {
  var response = await http.delete(
      '$urlBackend/features?repository_name=$repositoryName&project_name=$projectName&feature_name=$featureName');

  final statusCode = response.statusCode;
  print('Response Status code deleteFeatures: $statusCode');
}
