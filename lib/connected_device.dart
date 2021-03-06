import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:utf/utf.dart';

class ConnectedDeviceScreen extends StatefulWidget {
  final BluetoothDevice connectedDevice;

  ConnectedDeviceScreen({@required this.connectedDevice});

  @override
  State<StatefulWidget> createState() => _ConnectedDeviceScreenState(connectedDevice);
}

class _ConnectedDeviceScreenState extends State<ConnectedDeviceScreen> {
  final textController = TextEditingController();

  BluetoothDevice connectedDevice;

  List<BluetoothService> bluetoothServices;
  Map<Guid, List<int>> characteristicsAndValues = new Map<Guid, List<int>>();
  Map<Guid, List<int>> descriptorsAndValues = new Map<Guid, List<int>>();

  _ConnectedDeviceScreenState(this.connectedDevice) {
    connectedDevice.discoverServices().then((services) => bluetoothServices = services);
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = new List<ButtonTheme>();
    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('READ'),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    characteristicsAndValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
                for (BluetoothDescriptor descriptor in characteristic.descriptors) {
                  descriptorsAndValues[descriptor.uuid] = await descriptor.read();
                }
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('WRITE'),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: textController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          MaterialButton(
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(utf8.encode(textController.value.text));
                              // print("text: ${textController.value.text} was sent to: ${characteristic.uuid.toString()}");
                              Navigator.pop(context);
                            },
                          ),
                          MaterialButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('NOTIFY'),
              onPressed: () async {
                characteristic.value.listen((value) {
                  characteristicsAndValues[characteristic.uuid] = value;
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }
    return buttons;
  }

  String decode(List<int> bytes) {
    return decodeUtf8(bytes);
  } // some strange symbols

  ListView _buildListViewOfConnectedDevice() {
    var containers = new List<Container>();
    for (BluetoothService service in bluetoothServices) {
      var characteristicsWidgets = new List<Widget>();
      print(service.uuid);

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        List<int> bytes = characteristicsAndValues[characteristic.uuid];
        String decodedValue = bytes == null ? "null" : decode(bytes);
        print('  ' + characteristic.uuid.toString() + ': ' + decodedValue);

        var descriptorsInfo = new List<Row>();
        for (BluetoothDescriptor descriptor in characteristic.descriptors) {
          String uuidAndDecode = descriptor.uuid.toString() + ': ' + decode(descriptor.lastValue);
          print('    ' + uuidAndDecode);

          descriptorsInfo.add(
            Row(
              children: [
                Text(uuidAndDecode),
              ],
            )
          );
        }

        characteristicsWidgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                        characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
                Row(
                  children: [
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                // Row(
                //   children: [
                //     Text('Value: ' + bytes.toString()),
                //   ],
                // ),
                Row(
                  children: [
                    Text('This characteristic is about: ' + decodedValue),
                  ],
                ),
                Container(
                  child: Column(
                    children: [
                      ...descriptorsInfo,
                    ],
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidgets
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(connectedDevice.name),
      backgroundColor: Color.fromRGBO(0xFD, 0xAC, 0x53, 1),
    ),
    body: _buildListViewOfConnectedDevice(),
  );
}