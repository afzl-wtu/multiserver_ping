import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yaml/yaml.dart';

import '../models/group_model.dart';
import '../models/server_model.dart';

class GroupController extends GetxController {
  final groups = <GroupModel>[].obs;
  final selectedServers = <ServerModel>[].obs;
  final _box = GetStorage();
  late final StreamSubscription<List<GroupModel>> groupsSubscription;
  late final StreamSubscription<List<ServerModel>> selectedServersSubscription;

  @override
  void onInit() {
    loadServers();
    groupsSubscription = groups.listen((_) => writeDataToStorage());
    selectedServersSubscription =
        selectedServers.listen((_) => writeDataToStorage());
    super.onInit();
  }

  @override
  void onClose() {
    groupsSubscription.cancel();
    selectedServersSubscription.cancel();
    super.onClose();
  }

  void addServer(ServerModel server, String groupId) {
    groups.firstWhere((element) => element.id == groupId).servers.add(server);
  }

  void removeServer(ServerModel server, String groupId) {
    groups
        .firstWhere((element) => element.id == groupId)
        .servers
        .remove(server);
  }

  int multiaveragePing(int limit) {
    if (selectedServers.isEmpty) {
      return 0;
    }
    return selectedServers.fold(
            0,
            (previousValue, element) =>
                previousValue + element.averagePing(limit)) ~/
        selectedServers.length;
  }

  Future<void> loadServers() async {
    final isDataAlreadySet = _box.read<bool>('isDataAlreadySet');
    if (isDataAlreadySet == null) {
      final data = await rootBundle.loadString('assets/servers.yml');
      YamlMap yaml = loadYaml(data);
      //Loop
      for (YamlMap server in yaml['servers']) {
        //condition
        if (server['enable'] == true) {
          var groupIndex = groups.indexWhere((e) => e.title == server['title']);
          if (groupIndex == -1) {
            groups.add(GroupModel(
              title: server['title'],
              textColor: Colors.black,
              backGroundColor: Colors.white,
              servers: [],
              id: DateTime.now().microsecondsSinceEpoch.toString(),
            ));
          }
          if (groupIndex == -1) {
            groupIndex = groups.length - 1;
          }
          //condition in condition
          if (server['codes'] == null) {
            //2nd loop in codition
            for (String url in server['urls']) {
              groups[groupIndex].servers.add(ServerModel(
                  id: DateTime.now().microsecondsSinceEpoch,
                  location: '',
                  region: '',
                  url: url));
            }
          } else {
            for (YamlMap code in server['codes']) {
              final urlCode = code.keys.toList()[0];
              groups[groupIndex].servers.add(
                    ServerModel(
                      id: DateTime.now().microsecondsSinceEpoch,
                      location: code[urlCode],
                      region: urlCode.split("-")[0],
                      url: server['prefix'] + urlCode + server['suffix'],
                    ),
                  );
            }
          } //condition end
        } //main condition end
      } //main loop end
      writeDataToStorage();
      _box.write('isDataAlreadySet', true);
    } else {
      _readDataFromStorage();
    }
  }

  void writeDataToStorage() {
    _box.write('selectedServers', selectedServers.map((e) => e.id).toList());
    _box.write('groups', groups.map((e) => e.toMap()).toList());
  }

  void _readDataFromStorage() {
    final List<dynamic> data = _box.read('groups');
    groups.value = data.map((e) => GroupModel.fromMap(e)).toList();
    final selectedServerIds = List<int>.from(_box.read('selectedServers'));
    for (var group in groups) {
      for (var server in group.servers) {
        if (selectedServerIds.contains(server.id)) {
          selectedServers.add(server);
        }
      }
    }
  }

  int multimaxPing(int limit) {
    if (selectedServers.isEmpty) {
      return 0;
    }
    return selectedServers.fold(
        0,
        (previousValue, element) => previousValue < element.maxPing(limit)
            ? element.maxPing(limit)
            : previousValue);
  }

  int multiminPing(int limit) {
    if (selectedServers.isEmpty) {
      return 0;
    }
    return selectedServers.fold(
        999999,
        (previousValue, element) => previousValue < element.minPing(limit)
            ? previousValue
            : element.minPing(limit));
  }

  void multistartPing() {
    for (var element in selectedServers) {
      element.startPing();
    }
  }

  void multistopPing() {
    for (var element in selectedServers) {
      element.stopPing();
    }
  }
}
