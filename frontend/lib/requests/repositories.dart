import 'package:flutter/material.dart';

import '../resources/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Repository {
  final String data;
  Repository({this.data});
  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      data: json['data'],
    );
  }
}

class RepositoryObject {
  String name = '';
  String url = '';
  RepositoryObject({Key key, this.name, this.url});
}

List<RepositoryObject> snapToDataCommits(var data) {
  var dataSplit = data.split(',\n');
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

  List<RepositoryObject> listRepositories =
      new List<RepositoryObject>(sizeList);

  for (int i = 0; i < size; i = i + 3) {
    int j = (i ~/ 3);
    var dataSplitOne = dataSplit[i + 1].split(':');
    var dataSplitTwo = dataSplitOne[1].split('"');
    RepositoryObject name = new RepositoryObject(name: dataSplitTwo[1]);
    listRepositories[j] = name;

    dataSplitOne = dataSplit[i + 2];
    dataSplitTwo = dataSplitOne.split('"');
    listRepositories[j].url = dataSplitTwo[3];
  }

  return listRepositories;
}

Future<Repository> getRepository(String projectName) async {
  var response =
      await http.get('$urlBackend/repository?project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code getRepository: $statusCode');
  if (response.statusCode == 201) {
    return Repository.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Repository.');
  }
}

Future<Repository> deleteRepository(
    String projectName, String repositoryName) async {
  var response = await http.delete(
      '$urlBackend/repository?project_name=$projectName&repository_name=$repositoryName');

  final statusCode = response.statusCode;
  print('Response Status code deleteRepository: $statusCode');
  if (response.statusCode == 201) {
    return Repository.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Repository.');
  }
}

void postRepository(
    String projectName, String repositoryName, String url) async {
  var response = await http.post(
    '$urlBackend/repository',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'repository_name': repositoryName,
      'url': url
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code postRepository: $statusCode');
}

Future putRepository(String projectName, String repositoryName,
    String repositoryNameNew, String urlNew) async {
  var response = await http.put(
    '$urlBackend/repository',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'repository_name_old': repositoryName,
      'repository_name_new': repositoryNameNew,
      'url_new': urlNew
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code: $statusCode');
}
