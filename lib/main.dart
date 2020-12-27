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

// import 'package:flutter/material.dart';
// import 'package:audio_recorder/audio_recorder.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'A-Dicto',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'A-Dicto'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   IconData icon = Icons.mic;
//   bool isRecording = true; // await AudioRecorder.isRecording;
//
//   // bool hasPermissions;
//   //
//   // Future<bool> _preparingForRecord() async {
//   //   hasPermissions = await AudioRecorder.hasPermissions;
//   //   return hasPermissions;
//   // }
//
//
//   void _startRecord() {
//     setState(() {
//       bool hasPermissions = true;
//       if (hasPermissions) {
//         if (isRecording) {
//           icon = Icons.stop;
//           isRecording = false;
//         } else {
//           icon = Icons.mic;
//           isRecording = true;
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//       //   child: Column(
//       //     mainAxisAlignment: MainAxisAlignment.center,
//       //     children: <Widget>[
//       //       Text(
//       //         'You have pushed the button this many times:',
//       //       ),
//       //       Text(
//       //         '$_counter',
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //     ],
//       //   ),
//       // ),
//       child: L
//       floatingActionButton: FloatingActionButton(
//         onPressed: _startRecord,
//         child: Icon(icon),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
