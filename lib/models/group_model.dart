// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'server_model.dart';

class GroupModel {
  String title;
  Color textColor;
  Color backGroundColor;
  final List<ServerModel> servers;
  String id;
  GroupModel({
    required this.title,
    required this.textColor,
    required this.backGroundColor,
    required this.servers,
    required this.id,
  });

  GroupModel copyWith({
    String? title,
    Color? textColor,
    Color? backGroundColor,
    List<ServerModel>? servers,
    String? id,
  }) {
    return GroupModel(
      title: title ?? this.title,
      textColor: textColor ?? this.textColor,
      backGroundColor: backGroundColor ?? this.backGroundColor,
      servers: servers ?? this.servers,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'textColor': textColor.value,
      'backGroundColor': backGroundColor.value,
      'servers': servers.map((x) => x.toMap()).toList(),
      'id': id,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      title: map['title'] as String,
      textColor: Color(map['textColor'] as int),
      backGroundColor: Color(map['backGroundColor'] as int),
      servers: List<ServerModel>.from(
        (List<Map<String, dynamic>>.from(map['servers'])).map<ServerModel>(
          (x) => ServerModel.fromMap(x),
        ),
      ),
      id: map['id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupModel.fromJson(String source) =>
      GroupModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GroupModel(title: $title, textColor: $textColor, backGroundColor: $backGroundColor, servers: $servers, id: $id)';
  }

  @override
  bool operator ==(covariant GroupModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.textColor == textColor &&
        other.backGroundColor == backGroundColor &&
        listEquals(other.servers, servers) &&
        other.id == id;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        textColor.hashCode ^
        backGroundColor.hashCode ^
        servers.hashCode ^
        id.hashCode;
  }
}
