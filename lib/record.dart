import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'results.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late FlutterSoundRecorder _recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  late String pathToAudio;
  bool hasRecording = false;
  bool isRecording = false;
  bool isLoading = false;
  bool _playAudio = false;
  String _timerText = 'On Standby';
  @override
  void initState() {
    super.initState();
    initializer();
  }
  void initializer() async {
    pathToAudio = '/sdcard/Download/temp.wav';
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _recordingSession.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path + "/test.wav";
    if (await File(tempPath).exists()) {
      setState(() {
        hasRecording = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Recording and Playing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Container(
              child: Center(
                child: Text(
                  _timerText,
                  style: TextStyle(fontSize: 70, color: Colors.red),
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Visibility(
              visible: !_playAudio && !isLoading,
              child: ElevatedButton.icon(
                style:
                ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.green),
                onPressed: () {
                  setState(() {
                    isRecording = !isRecording;
                  });
                  if (isRecording) startRecording();
                  if (!isRecording) {
                    stopRecording();
                    hasRecording = true;
                  }
                },
                icon: isRecording ? Icon(Icons.stop) : Icon(Icons.keyboard_voice),
                label: isRecording
                    ? Text(
                  "Finish",
                  style: TextStyle(
                    fontSize: 28,
                  ),
                )
                    : Text(
                    "Record",
                    style: TextStyle(fontSize: 28)),
              ),
            ),

            SizedBox(
              height: 20,
            ),
            Visibility(
              visible: !isRecording && hasRecording && !isLoading,
              child: ElevatedButton.icon(
                style:
                ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.red),
                onPressed: () {
                  setState(() {
                    _playAudio = !_playAudio;
                  });
                  if (_playAudio) playFunc();
                  if (!_playAudio) stopPlayFunc();
                },
                icon: _playAudio
                    ? Icon(
                  Icons.stop,
                )
                    : Icon(Icons.play_arrow),
                label: _playAudio
                    ? Text(
                  "Stop",
                  style: TextStyle(
                    fontSize: 28,
                  ),
                )
                    : Text(
                    "Play",
                    style: TextStyle(fontSize: 28)),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Visibility(
              visible: !isRecording && !_playAudio && hasRecording && !isLoading,
              child: ElevatedButton.icon(
                  style:
                  ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.blue),
                  onPressed: uploadFileToServer,
                  icon: Icon(
                    Icons.arrow_forward,
                  ),
                  label: Text(
                    "Analyze",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  )
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Visibility(
              visible: isLoading,
              child: CircularProgressIndicator()
            ),
            SizedBox(
              height: 20,
            ),
            Visibility(
                visible: isLoading,
                child: Text("Loading..."),
            ),
          ],
        ),
      )
    );
  }

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession.openAudioSession();
    await _recordingSession.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      _timerText = "Recording";
    });
    StreamSubscription _recorderSubscription =
    _recordingSession.onProgress?.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
      print(timeText);
      setState(() {
        _timerText = timeText.substring(0, 8);
      });
    }) as StreamSubscription;
    _recorderSubscription.cancel();
  }

  Future<String?> stopRecording() async {
    _recordingSession.closeAudioSession();
    setState(() {
      _timerText = "On Standby";
    });
    return await _recordingSession.stopRecorder();
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }

  Future<void> uploadFileToServer() async {
    print("Getting ready to upload");
    setState(() {
      isLoading = true;
    });

    try {
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse("https://Debatemate.ryanyan8.repl.co/analyze"));
      request.files.add(await http.MultipartFile.fromPath("song", pathToAudio));
      Wakelock.enable();
      request.send().then((r) async {
        print(r.statusCode);
        var data = json.decode(await r.stream.transform(utf8.decoder).join());
        print(data);
        if (r.statusCode == 200) {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path + "/test.wav";
          setState(() {
            isLoading = false;
          });
          Wakelock.disable();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ResultsPage(speech_data: data)));
        } else {
          setState(() {
            isLoading = false;
          });
          Wakelock.disable();
          final snackBar = SnackBar(
            content: const Text('An error has occurred'),
            action: SnackBarAction(
              label: 'Close',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );
        }
      });
    } catch(e) {
      final snackBar = SnackBar(
        content: Text(e.toString()),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
    }
  }
}
