import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resources/config.dart';

class Authors {
  final String data;
  Authors({this.data});
  factory Authors.fromJson(Map<String, dynamic> json) {
    return Authors(
      data: json['data'],
    );
  }
}

class AuthorsObject {
  String author = '';
  String date = '';
  String numberCommits = '';
  String numberLines = '';
  AuthorsObject(
      {Key key, this.author, this.date, this.numberCommits, this.numberLines});
}

List<AuthorsObject> snapToDataAuthor(var data) {
  final intRegex = RegExp(r'(\d+)', multiLine: true);
  var dataSplit = data.split(',');
  int size;
  int sizeList;
  if (dataSplit.length > 5 * rowsPerTable) {
    size = 5 * rowsPerTable;
    sizeList = rowsPerTable;
  } else if (dataSplit.length < 5) {
    size = 0;
    sizeList = 0;
  } else {
    size = dataSplit.length;
    sizeList = size ~/ 5;
  }

  List<AuthorsObject> listAuthors = new List<AuthorsObject>(sizeList);

  for (int i = 0; i < size; i = i + 5) {
    int j = (i ~/ 5);
    var dataSplitOne = dataSplit[i + 1].split(':');
    var dataSplitTwo = dataSplitOne[1].split('"');
    // finalSplitFeature[j] = (dataSplitTwo[1]);

    AuthorsObject authorName = new AuthorsObject(author: dataSplitTwo[1]);
    listAuthors[j] = authorName;

    dataSplitOne = dataSplit[i + 2].split(':');
    dataSplitTwo = dataSplitOne[1].split('"');
    var dataSplitThree = dataSplitTwo[1].split(' ');
    listAuthors[j].date = dataSplitThree[0];
    // finalSplitDate[j] = (dataSplitThree[0]);

    dataSplitOne = dataSplit[i + 3].split(':');
    String commits = intRegex
        .allMatches(dataSplitOne[1])
        .map((m) => m.group(0))
        .toString()
        .replaceAll("(", "")
        .replaceAll(")", "");
    listAuthors[j].numberCommits = commits;

    dataSplitOne = dataSplit[i + 4].split(':');
    dataSplitTwo = dataSplitOne[1].split('}');
    listAuthors[j].numberLines = dataSplitTwo[0];
    //finalSplitLines[j] = (dataSplitTwo[0]);

  }
  return listAuthors;
}

Future<Authors> getAuthors(String projectName, String repositoryName) async {
  var response = await http.get(
      '$urlBackend/authors?repository_name=$repositoryName&project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code getAuthors: $statusCode');
  if (response.statusCode == 201) {
    return Authors.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Authors.');
  }
}
