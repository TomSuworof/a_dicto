import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:utf/utf.dart';

class ConnectedDeviceScreen extends StatefulWidget {
  final BluetoothDevice connectedDevice;
  final List<BluetoothService> bluetoothServices;

  ConnectedDeviceScreen({
    @required this.connectedDevice,
    @required this.bluetoothServices});

  @override
  State<StatefulWidget> createState() => _ConnectedDeviceScreenState(connectedDevice, bluetoothServices);
}

class _ConnectedDeviceScreenState extends State<ConnectedDeviceScreen> {
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();
  final textController = TextEditingController();

  BluetoothDevice connectedDevice;
  List<BluetoothService> bluetoothServices;

  _ConnectedDeviceScreenState(this.connectedDevice, this.bluetoothServices);

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
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
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
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
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
                          FlatButton(
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(utf8.encode(textController.value.text));
                              print("text: ${textController.value.text} was sent to: ${characteristic.uuid.toString()}");
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
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
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  readValues[characteristic.uuid] = value;
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

  ListView _buildListViewOfConnectedDevice() {
    List<Container> containers = new List<Container>();
    for (BluetoothService service in bluetoothServices) {
      List<Widget> characteristicsWidgets = new List<Widget>();
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        List<int> bytes = readValues[characteristic.uuid];
        print(bytes);
        String decodedValue = bytes == null ? "null" : decodeUtf8(bytes);
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
                Row(
                  children: [
                    Text('Value: ' + bytes.toString()),
                  ],
                ),
                Row(
                  children: [
                    Text('Decoded value: ' + decodedValue),
                  ],
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