// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dart_ping/dart_ping.dart';
import 'package:fl_chart/fl_chart.dart';

class ServerModel {
  final int id;
  final String title;
  final String location;
  final String region;
  String? url;
  String? ip;
  List<FlSpot> pings = [];
  late var _ping = Ping(url!, count: 5000);

  ServerModel({
    required this.id,
    this.title = '',
    required this.location,
    required this.region,
    required this.url,
    this.ip,
  });

  int maxPing(int limit) {
    if (pings.length < limit) {
      return pings.fold(0, (p, e) => p < e.y ? e.y.toInt() : p);
    }
    return pings.getRange(pings.length - limit, pings.length).toList().fold(
        0,
        (previousValue, element) =>
            previousValue < element.y ? element.y.toInt() : previousValue);
  }

  int minPing(int limit) {
    if (pings.length < limit) {
      return pings.fold(
          999999,
          (p, e) => p > e.y
              ? e.y.toInt()
              : p); //TODO: fix this because if packet drops minimum ping will be zero
    }
    return pings.getRange(pings.length - limit, pings.length).toList().fold(
        999999,
        (previousValue, element) =>
            previousValue < element.y ? previousValue : element.y.toInt());
  }

  int averagePing(int limit) {
    if (pings.length < limit) {
      if (pings.isEmpty) {
        return 0;
      }
      return pings.fold(0, (p, e) => p + e.y.toInt()) ~/ pings.length;
    }
    return pings.getRange(pings.length - limit, pings.length).toList().fold(
            0, (previousValue, element) => previousValue + element.y.toInt()) ~/
        limit;
  }

  void startPing() {
    pings = [];
    _ping.stream.listen((event) {
      if (event.response != null) {
        ip = event.response!.ip;
        // (event.response!.time != null)
        //     ? event.response!.time?.inMilliseconds.toDouble()
        //     : 0;
        if (event.response!.time != null) {
          pings.add(FlSpot(event.response!.seq!.toDouble(),
              event.response!.time?.inMilliseconds.toDouble() ?? 0));
        }
      }
    });
  }

  void stopPing() {
    _ping.stop();
    _ping = Ping(url!, count: 5000);
  }

  ServerModel copyWith({
    int? id,
    String? title,
    String? location,
    String? region,
    String? url,
    String? ip,
  }) {
    return ServerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      region: region ?? this.region,
      url: url ?? this.url,
      ip: ip ?? this.ip,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'location': location,
      'region': region,
      'url': url,
      'ip': ip,
    };
  }

  factory ServerModel.fromMap(Map<String, dynamic> map) {
    return ServerModel(
      id: map['id'] as int,
      title: map['title'] as String,
      location: map['location'] as String,
      region: map['region'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      ip: map['ip'] != null ? map['ip'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerModel.fromJson(String source) =>
      ServerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ServerModel(id: $id, title: $title, location: $location, region: $region, url: $url, ip: $ip)';
  }

  @override
  bool operator ==(covariant ServerModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.location == location &&
        other.region == region &&
        other.url == url &&
        other.ip == ip;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        location.hashCode ^
        region.hashCode ^
        url.hashCode ^
        ip.hashCode;
  }
}
