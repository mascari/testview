import '../resources/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Project {
  final String data;
  Project({this.data});
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      data: json['data'],
    );
  }
}

Future<Project> getProject() async {
  var response = await http.get('$urlBackend/project');

  final statusCode = response.statusCode;
  print('Response Status code getProject: $statusCode');
  if (response.statusCode == 201) {
    return Project.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Project.');
  }
}

void postProject(String projectName) async {
  var response = await http.post(
    '$urlBackend/project',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code postProject: $statusCode');
}

void deleteProject(String projectName) async {
  var response =
      await http.delete('$urlBackend/project?project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code deleteProject: $statusCode');
}
