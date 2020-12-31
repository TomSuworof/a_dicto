import 'package:a_dicto/connected_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:system_setting/system_setting.dart';

class ListOfDevicesScreen extends StatefulWidget {
  @override
  _ListOfDevicesScreenState createState() => _ListOfDevicesScreenState();
}

class _ListOfDevicesScreenState extends State<ListOfDevicesScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  BluetoothDevice connectedDevice;
  List<BluetoothService> bluetoothServices;

  _showDeviceToList(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  bool isBluetoothOn() {
    var connection = true;
    flutterBlue.state.listen((state) {
      connection = state == BluetoothState.turningOn;
    });
    return connection;
  } // it does not work - always true

  ListView _buildListViewOfDevices() {
    flutterBlue.connectedDevices.asStream().listen((
        List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _showDeviceToList(device);
      }
    });
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _showDeviceToList(result.device);
      }
    });
    flutterBlue.startScan();

    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              MaterialButton(
                child: Text('Connect'),
                onPressed: () async {
                  flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } catch (e) {
                    if (e.code != 'already_connected') {
                      throw e;
                    }
                  } finally {
                    bluetoothServices = await device.discoverServices();
                  }
                  setState(() {
                    connectedDevice = device;
                  });
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ConnectedDeviceScreen(connectedDevice: connectedDevice)
                  ));
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ...containers,
      ],
    );
  }

  Container _buildBluetoothOffPage() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Bluetooth is off"),
          MaterialButton(
              child: Text("Go to settings"),
              onPressed: () {
                SystemSetting.goto(SettingTarget.BLUETOOTH);
              }
          )
        ],
      ),
    );
  }

  Widget _buildMainPage() {
    if (isBluetoothOn()) {
      print('--------------------------bluetooth is on!');
      return _buildListViewOfDevices();
    } else {
      print('--------------------------bluetooth is off!');
      return _buildBluetoothOffPage();
    }
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: Text("A_Dicto"),
          backgroundColor: Color.fromRGBO(0xFD, 0xAC, 0x53, 1),
        ),
        body: _buildMainPage(),
      );
}