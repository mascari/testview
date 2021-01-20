import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:TestView/resources/config.dart';

class Settings {
  final String data;
  Settings({this.data});
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      data: json['data'],
    );
  }
}

Future<Settings> getDays(String projectName) async {
  var response =
      await http.get('$urlBackend/settings?project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code getDays: $statusCode');
  if (response.statusCode == 201) {
    return Settings.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Settings.');
  }
}

Future<Settings> getFileExtensions(String projectName) async {
  var response =
      await http.get('$urlBackend/settingsfiles?project_name=$projectName');

  final statusCode = response.statusCode;
  print('Response Status code getDileExtensions: $statusCode');
  if (response.statusCode == 201) {
    return Settings.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Settings.');
  }
}

void deleteFileExtensions(String projectName, String fileExtension) async {
  var response = await http.delete(
      '$urlBackend/settingsfiles?project_name=$projectName&file_extensions=$fileExtension');
  final statusCode = response.statusCode;
  print('Response Status code deleteFileExtensions: $statusCode');
}

void postFileExtensions(String projectName, String fileExtension) async {
  var response = await http.post(
    '$urlBackend/settingsfiles',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'file_extensions': fileExtension,
    }),
  );
  final statusCode = response.statusCode;
  print('Response Status code postFileExtensions: $statusCode');
}

void postDays(String projectName, String daysRetrieval) async {
  var response = await http.post(
    '$urlBackend/settings',
    body: jsonEncode(<String, String>{
      'project_name': projectName,
      'days_retrieval': daysRetrieval,
    }),
  );

  final statusCode = response.statusCode;
  print('Response Status code postDays: $statusCode');
}
