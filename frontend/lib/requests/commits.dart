import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resources/config.dart';

class Commits {
  final String data;
  Commits({this.data});
  factory Commits.fromJson(Map<String, dynamic> json) {
    return Commits(
      data: json['data'],
    );
  }
}

class CommitsObject {
  String author = '';
  String date = '';
  String message = '';
  int numberFiles = 0;
  CommitsObject(
      {Key key, this.author, this.date, this.message, this.numberFiles});
}

List<CommitsObject> snapToDataCommits(var data) {
  var dataSplit = data.split(',\n');
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

  List<CommitsObject> listCommits = new List<CommitsObject>(sizeList);

  for (int i = 0; i < size; i = i + 7) {
    int j = (i ~/ 7);

    //Add the author to the list of commits
    var dataSplitOne = dataSplit[i + 1].split(':');
    var dataSplitTwo = dataSplitOne[1].split('"');
    CommitsObject author = new CommitsObject(author: dataSplitTwo[1]);
    listCommits[j] = author;

    //Add the date to the list of commits
    dataSplitOne = dataSplit[i + 2].split(':');
    dataSplitTwo = dataSplitOne[1].split('"');
    var dataSplitThree = dataSplitTwo[1].split(' ');
    listCommits[j].date = dataSplitThree[0];

    //Add the message to the list of commits
    dataSplitOne = dataSplit[i + 4].split(':');
    dataSplitTwo = dataSplitOne[1].split('"');
    listCommits[j].message = dataSplitTwo[1];

    //Add the numberFiles to the list of commits
    dataSplitOne = dataSplit[i + 5].split('":');
    listCommits[j].numberFiles = int.parse(dataSplitOne[1]);
  }

  return listCommits;
}

Future<Commits> getCommits(String projectName, String repositoryName) async {
  var response = await http.get(
      '$urlBackend/commits?project_name=$projectName&repository_name=$repositoryName');

  final statusCode = response.statusCode;
  print('Response Status code getCommits: $statusCode');
  if (response.statusCode == 201) {
    return Commits.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Commits.');
  }
}

void putCommits(String projectName, String repositoryName) async {
  var response = await http.put(
    '$urlBackend/commits',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'repository_name': repositoryName
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code putCommits: $statusCode');
}
