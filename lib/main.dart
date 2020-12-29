import 'package:flutter/material.dart';

import 'list_of_devices.dart';

void main() => runApp(a_dicto_app());

class a_dicto_app extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.orange,
    ),
    home: ListOfDevicesScreen(),
  );
}