import 'package:multiserver_ping/core/group_controller.dart';
import 'package:multiserver_ping/models/group_model.dart';
import 'package:flutter/material.dart';
import 'package:multiserver_ping/models/server_model.dart';
import 'package:multiserver_ping/screens/ping_screen.dart';
import 'package:get/get.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen(this.group, {super.key});
  final GroupModel group;

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.group.title,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            Obx(
              () => IconButton(
                onPressed: groupController.selectedServers.isEmpty
                    ? null
                    : () => Get.to(() => const PingScreen()),
                icon: Icon(
                  Icons.play_arrow,
                  color: groupController.selectedServers.isEmpty
                      ? null
                      : Colors.green,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddUpdateServerWidget(
                    setState,
                    groupId: widget.group.id,
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
        //choose a servermodel conatianing title "My server" from allServer list

        body: Obx(() {
          var index =
              groupController.groups.indexWhere((e) => e.id == widget.group.id);
          final a = [...groupController.groups[index].servers];
          a.sort((a, b) => (a.title.isEmpty ? a.location : a.title)
              .compareTo(b.title.isEmpty ? b.location : b.title));
          return ListView.builder(
            itemBuilder: (_, i) => Column(
              children: [
                a.isEmpty
                    ? const Center(
                        child: Text('No Servers added yet.'),
                      )
                    : CheckBoxTileWidget(
                        refreshWholeScreen: setState,
                        index: index,
                        server: a[i]),
                const SizedBox(
                  height: 5,
                )
              ],
            ),
            itemCount: a.length,
          );
        }));
  }
}

class AddUpdateServerWidget extends StatefulWidget {
  const AddUpdateServerWidget(this.refreshWholeScreen,
      {super.key, required this.groupId, this.server});
  final String groupId;
  final ServerModel? server;
  final void Function(void Function() fn) refreshWholeScreen;

  @override
  State<AddUpdateServerWidget> createState() => _AddUpdateServerWidgetState();
}

class _AddUpdateServerWidgetState extends State<AddUpdateServerWidget> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _regionController = TextEditingController();

  final _locationController = TextEditingController();

  final _urlController = TextEditingController();

  @override
  void initState() {
    if (widget.server != null) {
      _titleController.text = widget.server!.title;
      _regionController.text = widget.server!.region;
      _locationController.text = widget.server!.location;
      _urlController.text = widget.server!.url!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _regionController.dispose();
    _locationController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    return AlertDialog(
        // title: Text('Dialog Title'),
        content: SizedBox(
          height: 341,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title:'),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty && _locationController.text.isEmpty) {
                        return 'At least one field title or location';
                      }
                      return null;
                    },
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Server Title'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('Region:'),
                  TextFormField(
                    controller: _regionController,
                    decoration: const InputDecoration(hintText: 'Europe'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('Location:'),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty && _titleController.text.isEmpty) {
                        return 'Atleast one field title or location';
                      }
                      return null;
                    },
                    controller: _locationController,
                    decoration: const InputDecoration(hintText: 'Germany'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('Url/ip:'),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a valid url';
                      }
                      return null;
                    },
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(hintText: 'url'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              final a = ServerModel(
                  id: widget.server != null
                      ? widget.server!.id
                      : DateTime.now().microsecondsSinceEpoch,
                  location: _locationController.text,
                  region: _regionController.text,
                  url: _urlController.text,
                  title: _titleController.text);
              if (widget.server != null) {
                groupController.removeServer(widget.server!, widget.groupId);
              }
              groupController.addServer(a, widget.groupId);
              widget.refreshWholeScreen(() {});
              Get.back(result: false);
            },
            child: Text(widget.server != null ? 'Update' : 'Add'),
          ),
        ]);
  }
}

class CheckBoxTileWidget extends StatelessWidget {
  const CheckBoxTileWidget({
    super.key,
    required this.index,
    required this.server,
    required this.refreshWholeScreen,
  });
  final ServerModel server;
  final void Function(void Function() fn) refreshWholeScreen;
  final int index;
  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Container(
        color: Colors.grey.shade200,
        child: Dismissible(
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete),
          ),
          secondaryBackground: Container(
            color: Colors.green,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.edit),
          ),
          onDismissed: (direction) {
            groupController.groups[index].servers
                .removeWhere((element) => element.id == server.id);
            groupController.selectedServers
                .removeWhere((element) => element.id == server.id);
            groupController.writeDataToStorage();
          },
          confirmDismiss: (direction) {
            if (direction == DismissDirection.endToStart) {
              return showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AddUpdateServerWidget(
                    refreshWholeScreen,
                    groupId: groupController.groups[index].id,
                    server: server,
                  );
                },
              );
            }
            return Get.dialog<bool>(
              AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text(
                    'Do you want to remove this server from the list?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.back(result: false);
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          },
          key: ValueKey(server.id),
          child: Obx(() => CheckboxListTile(
                title:
                    Text(server.title.isEmpty ? server.location : server.title),
                subtitle:
                    Text(server.region.isEmpty ? server.url! : server.region),
                value: groupController.selectedServers
                    .any((e) => e.id == server.id),
                onChanged: (bool? val) {
                  if (val!) {
                    if (groupController.selectedServers.length == 10) {
                      Get.showSnackbar(const GetSnackBar(
                        duration: Duration(seconds: 3),
                        title: 'Érror',
                        message: 'Maximum of 10 servers allowed.',
                      ));
                      return;
                    }
                    groupController.selectedServers.add(server);
                  } else {
                    groupController.selectedServers
                        .removeWhere((e) => e.id == server.id);
                  }
                },
              )),
        ),
      ),
    );
  }
}
