import 'dart:developer' as console;
import 'package:multiserver_ping/models/group_model.dart';
import 'package:color_picker_field/color_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:multiserver_ping/screens/servers_screen.dart';
import 'package:get/get.dart';
import 'package:multiserver_ping/screens/ping_screen.dart';

import '../core/group_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupController = Get.put(GroupController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          Obx(() => TextButton.icon(
              style: ButtonStyle(
                  iconColor: MaterialStateProperty.resolveWith((states) {
                console.log(states.toString());
                return states.isEmpty ? Colors.red : null;
              })),
              onPressed: groupController.selectedServers.isEmpty
                  ? null
                  : () => Get.dialog(AlertDialog(
                        title: const Text('Delete Servers'),
                        content: const Text(
                            'Are you sure you want to delete selected servers?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              groupController.selectedServers.clear();
                              Get.back();
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: Get.back,
                            child: const Text('No'),
                          ),
                        ],
                      )),
              icon: const Icon(Icons.delete),
              label: Text(groupController.selectedServers.length.toString()))),
          // Play Button Icon to open ping screen
          Obx(() => IconButton(
                style: ButtonStyle(
                    iconColor: MaterialStateProperty.resolveWith((states) {
                  console.log(states.toString());
                  return states.isEmpty ? Colors.green : null;
                })),
                onPressed: groupController.selectedServers.isEmpty
                    ? null
                    : () {
                        Get.to(() => const PingScreen());
                      },
                icon: const Icon(Icons.play_arrow),
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddUpdateGroupDialogWidget();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            Obx(() {
              final a = [...groupController.groups];
              a.sort((a, b) => a.title.compareTo(b.title));
              return Expanded(
                child: a.isEmpty
                    ? const Center(child: Text('No Groups added. Please add.'))
                    : GridView.builder(
                        itemBuilder: (_, i) {
                          return ServerTile(a[i]);
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 5,
                                childAspectRatio: 2 / 0.5,
                                mainAxisSpacing: 5,
                                crossAxisCount: 2),
                        itemCount: a.length),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AddUpdateGroupDialogWidget extends StatefulWidget {
  const AddUpdateGroupDialogWidget({super.key, this.group});
  final GroupModel? group;

  @override
  State<AddUpdateGroupDialogWidget> createState() =>
      _AddGroupDialogWidgetState();
}

class _AddGroupDialogWidgetState extends State<AddUpdateGroupDialogWidget> {
  final _formKey = GlobalKey<FormState>();

  final _groupTitleController = TextEditingController();

  final _colorPickerController =
      ColorPickerFieldController(colors: const [Colors.white, Colors.black]);
  @override
  void initState() {
    if (widget.group != null) {
      _groupTitleController.text = widget.group!.title;
      _colorPickerController.colors = [
        widget.group!.backGroundColor,
        widget.group!.textColor
      ];
    }
    super.initState();
  }

  @override
  void dispose() {
    _groupTitleController.dispose();
    _colorPickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    return AlertDialog(
        content: SizedBox(
          height: 180,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Group Title'),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a group title' : null,
                  controller: _groupTitleController,
                  decoration: const InputDecoration(hintText: 'Local Server'),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.maxFinite,
                  child: ColorPickerField(
                    enableLightness: true,
                    defaultColor: Colors.blue,
                    maxColors: 2,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    selectedColorItemBuilder:
                        (color, selected, onSelectionChange) {
                      return InkWell(
                        onTap: () {
                          onSelectionChange(!selected, color);
                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            Container(
                                margin: const EdgeInsets.all(5),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: color,
                                )),
                            if (selected)
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    controller: _colorPickerController,
                    decoration: const InputDecoration(
                      labelText: 'Colors',
                      helperText: 'Background and Text Color',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          if (widget.group != null)
            TextButton(
              onPressed: () {
                groupController.groups.remove(widget.group);
                Get.back();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              final a = GroupModel(
                title: _groupTitleController.text,
                backGroundColor: _colorPickerController.colors.isEmpty
                    ? Colors.white
                    : _colorPickerController.colors[0],
                textColor: _colorPickerController.colors.length < 2
                    ? Colors.black
                    : _colorPickerController.colors[1],
                servers: [],
                id: widget.group != null
                    ? widget.group!.id
                    : DateTime.now().microsecondsSinceEpoch.toString(),
              );
              if (widget.group != null) {
                groupController.groups.remove(widget.group);
              }
              groupController.groups.add(
                a,
              );
              Get.back();
            },
            child: Text(widget.group == null ? 'Add' : 'Update'),
          ),
        ]);
  }
}

class ServerTile extends StatelessWidget {
  const ServerTile(this.group, {super.key});
  final GroupModel group;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => ServersScreen(group),
      ),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddUpdateGroupDialogWidget(group: group);
          },
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: group.backGroundColor,
                boxShadow: [
                  BoxShadow(
                      color: group.backGroundColor,
                      offset: const Offset(1, 1),
                      blurRadius: 1)
                ],
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  group.title,
                  style: TextStyle(fontSize: 17, color: group.textColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
