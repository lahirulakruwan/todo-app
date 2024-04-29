import 'dart:developer';

import 'package:flutter/src/material/data_table.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';


class Person {
  int? id;
  String? record_type;
  String? full_name;
  String? asgardeo_id;
  String? jwt_sub_id;
  String? jwt_email;
  String? digital_id;
  String? email;
  String? created;
  String? updated;

  Person({
    this.id,
    this.record_type,
    this.full_name,
    this.asgardeo_id,
    this.jwt_sub_id,
    this.jwt_email,
    this.email,
    this.digital_id,
    this.created,
    this.updated,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      record_type: json['record_type'],
      full_name: json['full_name'],
      asgardeo_id: json['asgardeo_id'],
      jwt_sub_id: json['jwt_sub_id'],
      jwt_email: json['jwt_email'],
      email: json['email'],
      digital_id: json['digital_id'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (record_type != null) 'record_type': record_type,
        if (full_name != null) 'full_name': full_name,
        if (asgardeo_id != null) 'asgardeo_id': asgardeo_id,
        if (jwt_sub_id != null) 'jwt_sub_id': jwt_sub_id,
        if (jwt_email != null) 'jwt_email': jwt_email,
        if (email != null) 'email': email,
        if (digital_id != null) 'digital_id': digital_id,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated,
      };

  map(DataRow Function(dynamic evaluation) param0) {}
}
//-------- start of profile functions ---------------

Future<Person> fetchPerson(String digital_id) async {
  final uri = Uri.parse(AppConfig.todoTaskBffApiUrl + '/person')
      .replace(queryParameters: {'digital_id': digital_id});

  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.todoTaskBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}
