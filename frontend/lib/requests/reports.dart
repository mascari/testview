import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resources/config.dart';

class ReportsObject {
  String date = ' ';
  String featureName = ' ';
  String numberBugs = ' ';
  String numberFilesAssociated = ' ';
  String numberFilesModified = ' ';
  String averageComplexity = ' ';
  String priorization = ' ';
  ReportsObject(
      {Key key,
      this.averageComplexity,
      this.date,
      this.featureName,
      this.numberBugs,
      this.numberFilesAssociated,
      this.numberFilesModified,
      this.priorization});
}

List<ReportsObject> snapToDataReport(var data) {
  final intRegex = RegExp(r'(\d+)', multiLine: true);
  var dataSplit = data.split(',');
  print(dataSplit.length);
  
  int size;
  int sizeList;
  if (dataSplit.length > 8 * rowsPerTable) {
    size = 8 * rowsPerTable;
    sizeList = rowsPerTable;
  } else if (dataSplit.length < 8) {
    size = 0;
    sizeList = 0;
  } else {
    size = dataSplit.length;
    sizeList = size ~/ 8;
  }

  List<ReportsObject> listReports = new List<ReportsObject>(sizeList);

  for (int i = 0; i < size; i = i + 8) {
    int j = (i ~/ 8);
    var dataSplitOne = dataSplit[i + 2].split(':');

    ReportsObject date =
        new ReportsObject(date: dataSplitOne[1].replaceAll('"', ''));
    listReports[j] = date;

    dataSplitOne = dataSplit[i + 1].split(':');
    listReports[j].averageComplexity = dataSplitOne[1];

    dataSplitOne = dataSplit[i + 3].split(':');
    listReports[j].featureName = dataSplitOne[1].replaceAll('"', '');

    dataSplitOne = dataSplit[i + 4].split(':');
    listReports[j].numberBugs = dataSplitOne[1];

    dataSplitOne = dataSplit[i + 5].split(':');
    listReports[j].numberFilesAssociated = dataSplitOne[1];

    dataSplitOne = dataSplit[i + 6].split(':');
    listReports[j].numberFilesModified = dataSplitOne[1];

    

    dataSplitOne = dataSplit[i + 7].split(':');
    String prioNumber = dataSplitOne[1].replaceAll("]", "").replaceAll("}","").replaceAll("\n", "");
    listReports[j].priorization = prioNumber;
  }
  return listReports;
}

class Reports {
  final String data;
  Reports({this.data});
  factory Reports.fromJson(Map<String, dynamic> json) {
    return Reports(
      data: json['data'],
    );
  }
}

Future<Reports> getReports(String projectName, String repositoryName) async {
  var response = await http.get(
      '$urlBackend/reports?repository_name=$repositoryName&project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status getReports code: $statusCode');
  if (response.statusCode == 201) {
    return Reports.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Reports.');
  }
}

void postReports(String projectName, String repositoryName, String date) async {
  var response = await http.post(
    '$urlBackend/reports',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'repository_name': repositoryName,
      'date': date,
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code postReports: $statusCode');
}
