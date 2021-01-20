import 'package:flutter/material.dart';

import '../resources/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Files {
  final String data;
  Files({this.data});
  factory Files.fromJson(Map<String, dynamic> json) {
    return Files(
      data: json['data'],
    );
  }
}

class FilesObject {
  String fileName = '';
  String filePath = '';
  String numberFeatures = '';
  String date = '';
  FilesObject(
      {Key key, this.fileName, this.filePath, this.numberFeatures, this.date});
}

List<FilesObject> snapToDataFile(var data) {
  var dataSplit = data.split(',');
  int size;
  int sizeList;
  if (dataSplit.length > 5 * 50) {
    size = 5 * 50;
    sizeList = 50;
  } else if (dataSplit.length < 5) {
    size = 0;
    sizeList = 0;
  } else {
    size = dataSplit.length;
    sizeList = size ~/ 5;
  }

  List<FilesObject> listFiles = new List<FilesObject>(sizeList);

  for (int i = 0; i < size; i = i + 5) {
    int j = (i ~/ 5);
    var dataSplitOne = dataSplit[i + 1].split(':');
    var dataSplitTwo = dataSplitOne[1].split('"');
    FilesObject file = new FilesObject(fileName: dataSplitTwo[1]);
    listFiles[j] = file;

    //Fix the FilePath String
    dataSplitOne = dataSplit[i + 2].split(':');
    dataSplitOne[1] = dataSplitOne[1].replaceAll('"', '');
    dataSplitOne[1] = dataSplitOne[1].replaceAll(' ', '');
    listFiles[j].filePath = dataSplitOne[1];

    //Fix the date String
    dataSplitOne = dataSplit[i + 3].split(':');
    dataSplitTwo = dataSplitOne[1].split('"');
    var dataSplitThree = dataSplitTwo[1].split(' ');
    listFiles[j].date = dataSplitThree[0];

    //Fix the numberFeatures String
    dataSplitOne = dataSplit[i + 4].split(':');
    listFiles[j].numberFeatures = dataSplitOne[1][1];
  }

  return listFiles;
}

Future<Files> getFiles(String projectName, String repositoryName) async {
  var response = await http.get(
      '$urlBackend/files?repository_name=$repositoryName&project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code getFiles: $statusCode');
  if (response.statusCode == 201) {
    return Files.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Files.');
  }
}
