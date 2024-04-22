import 'dart:developer';

import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class TodoTask {
  int? id;
  String? task;
  String? record_type;

  TodoTask({
    this.id,
    this.task,
    this.record_type,
  });

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'],
      task: json['task'],
      record_type: json['record_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (task != null) 'task': task,
        if (record_type != null) 'record_type': record_type,
      };
}

Future<List<TodoTask>> fetchTodos() async {
  final response = await http.get(
    // Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/address'),
    Uri.parse('http://localhost:9095/todo_tasks'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    log(resultsJson.toString());
    List<TodoTask> todos = await resultsJson
        .map<TodoTask>((json) => TodoTask.fromJson(json))
        .toList();
    return todos;
  } else {
    throw Exception('Failed to load Todo Task List');
  }
}

Future<TodoTask> fetchTodoTask(String id) async {
  final response = await http.get(
    Uri.parse('http://localhost:9095/todo_task_by_id/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode == 200) {
    TodoTask todo = TodoTask.fromJson(json.decode(response.body));
    return todo;
  } else {
    throw Exception('Failed to load Todo');
  }
}

Future<TodoTask> createTodoTask(TodoTask todoTask) async {
  final response = await http.post(
    Uri.parse('http://localhost:9095/add_todo_task'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(todoTask.toJson()),
  );

  if (response.statusCode == 201) {
    log(response.body);
    TodoTask createdTodo = TodoTask.fromJson(json.decode(response.body));
    return createdTodo;
  } else {
    log("${response.body} Status code =${response.statusCode}");
    throw Exception('Failed to create Todo.');
  }
}

Future<http.Response> upgradeTodoTask(TodoTask todoTask) async {
  final response = await http.put(
    Uri.parse('http://localhost:9095/update_todo_task'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(todoTask.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Todo Task.');
  }
}

Future<http.Response> deleteTodoTask(String id) async {
  final http.Response response = await http.delete(
    Uri.parse('http://localhost:9095/delete_todo_task/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Todo Task.');
  }
}
