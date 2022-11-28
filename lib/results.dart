import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key, required this.speech_data});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final List<dynamic> speech_data;

  @override
  State<ResultsPage> createState() => ResultsPageState();
}

class ResultsPageState extends State<ResultsPage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Results"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Icon(Icons.insert_chart, size:100),
            SizedBox(
              height: 30,
            ),
            const Text(
              'Your results are:', style: TextStyle(fontSize: 40)
            ),
            SizedBox(
              height: 50,
            ),
            Padding(padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Text('Words per Minute: ' + widget.speech_data[0]),
                  SizedBox(
                    height: 20,
                  ),
              Text('Gender: ' + widget.speech_data[1]),
                  SizedBox(
                    height: 20,
                  ),
              Text('Mood of Speech: ' + widget.speech_data[2]),
                  SizedBox(
                    height: 20,
                  ),
              Text('Duration of Audio File: ' + widget.speech_data[3] + ' seconds'),
                  SizedBox(
                    height: 20,
                  ),
              Text('Time Spent Speaking: ' + widget.speech_data[4] + ' seconds'),
                  SizedBox(
                    height: 20,
                  ),
              Text('Number of Pauses: ' + widget.speech_data[5]),
                  SizedBox(
                    height: 20,
                  ),
              Text('Transcript: ' + widget.speech_data[6]),
                  SizedBox(
                    height: 30,
                  ),
              ]
            )),
          ],
        )),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}