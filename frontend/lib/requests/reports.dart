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
  int priorization = 0;
  ReportsObject(
      {Key key,
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

  int size;
  int sizeList;
  if (dataSplit.length > 7 * rowsPerTable) {
    size = 7 * rowsPerTable;
    sizeList = rowsPerTable;
  } else if (dataSplit.length < 7) {
    size = 0;
    sizeList = 0;
  } else {
    size = dataSplit.length;
    sizeList = size ~/ 7;
  }

  List<ReportsObject> listReports = new List<ReportsObject>(sizeList);

  for (int i = 0; i < size; i = i + 7) {
    int j = (i ~/ 7);
    var dataSplitOne = dataSplit[i + 1].split(':');

    ReportsObject date =
        new ReportsObject(date: dataSplitOne[1].replaceAll('"', ''));
    listReports[j] = date;

    dataSplitOne = dataSplit[i + 2].split(':');
    listReports[j].featureName = dataSplitOne[1].replaceAll('"', '');

    dataSplitOne = dataSplit[i + 3].split(':');
    listReports[j].numberBugs = dataSplitOne[1];

    dataSplitOne = dataSplit[i + 4].split(':');
    listReports[j].numberFilesAssociated = dataSplitOne[1];

    dataSplitOne = dataSplit[i + 5].split(':');
    listReports[j].numberFilesModified = dataSplitOne[1];

    dataSplitOne = dataSplit[i + 6].split(':');
    String prioNumber = intRegex
        .allMatches(dataSplitOne[1])
        .map((m) => m.group(0))
        .toString()
        .replaceAll("(", "")
        .replaceAll(")", "");
    int prioInt = int.parse(prioNumber);
    listReports[j].priorization = prioInt;
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
