import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../core/group_controller.dart';

class PingScreen extends StatefulWidget {
  const PingScreen({super.key});

  @override
  State<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends State<PingScreen> {
  static const xSize = 10;
  final _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.blueGrey,
  ];
  // Color _randomColor() {
  //   Random random = Random();
  //   return Color.fromRGBO(
  //     random.nextInt(256), // Red
  //     random.nextInt(256), // Green
  //     random.nextInt(256), // Blue
  //     1, // Alpha
  //   );
  // }

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    super.initState();
  }

  final _groupController = Get.find<GroupController>();
  @override
  Widget build(BuildContext context) {
    var index = 0;
    var index2 = 0;
    return Scaffold(
        body: SafeArea(
      child: (_groupController.selectedServers.last.pings.isEmpty)
          ? Center(
              child: GestureDetector(
                onTap: () {
                  _groupController.multistartPing();
                },
                child: const Card(
                    color: Colors.green,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      child: Text(
                        'Start',
                        style: TextStyle(color: Colors.white, fontSize: 23),
                      ),
                    )),
              ),
            )
          : PopScope(
              onPopInvoked: (didPop) {
                if (didPop) {
                  _groupController.multistopPing();
                  _groupController.selectedServers.last.pings.clear();
                }
              },
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: LineChart(
                        LineChartData(
                          clipData: const FlClipData.all(),
                          borderData: FlBorderData(
                              border: const Border(
                                  top: BorderSide.none,
                                  right: BorderSide.none,
                                  bottom: BorderSide(),
                                  left: BorderSide())),
                          titlesData: const FlTitlesData(
                              topTitles: AxisTitles(),
                              rightTitles: AxisTitles()),
                          maxX: _groupController
                              .selectedServers.last.pings.last.x,
                          maxY:
                              _groupController.multimaxPing(xSize).toDouble() +
                                  10,
                          minX: _groupController
                                  .selectedServers.last.pings.last.x -
                              (xSize - 1),
                          minY: _groupController.multiminPing(xSize) <= 10
                              ? _groupController.multiminPing(xSize).toDouble()
                              : _groupController
                                      .multiminPing(xSize)
                                      .toDouble() -
                                  10,
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: true,
                          ),
                          lineBarsData: _groupController.selectedServers.map(
                            (e) {
                              final color = _colors[index];
                              index++;
                              return LineChartBarData(
                                  spots: e.pings,
                                  color: color,
                                  dotData: const FlDotData(show: false));
                            },
                          ).toList(),
                        ),
                        // read about it in the LineChartData section
                      ),
                    ),
                  ),
                  const Divider(),
                  Column(
                    children: [
                      DataTable(
                          columnSpacing: 15,
                          columns: const [
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Current')),
                            DataColumn(label: Text('Min')),
                            DataColumn(label: Text('Max')),
                            DataColumn(label: Text('Avg')),
                          ],
                          rows: _groupController.selectedServers.map((e) {
                            var title = _groupController.groups
                                .firstWhere((el) =>
                                    el.servers.any((ele) => ele.id == e.id))
                                .title;
                            return DataRow(
                                color: MaterialStateProperty.all(
                                    _colors[index2++]),
                                cells: [
                                  DataCell(Text(
                                    '$title:${e.location}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  )),
                                  DataCell(Text((e.pings.isEmpty)
                                      ? '...'
                                      : e.pings.last.y.toInt().toString())),
                                  DataCell(Text(e.minPing(xSize).toString())),
                                  DataCell(Text(e.maxPing(xSize).toString())),
                                  DataCell(
                                      Text(e.averagePing(xSize).toString())),
                                ]);
                          }).toList()),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          _groupController.multistopPing();
                          _groupController.selectedServers.last.pings.clear();
                        },
                        child: const Card(
                            color: Colors.green,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 8),
                              child: Text(
                                'Stop',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    ));
  }
}
