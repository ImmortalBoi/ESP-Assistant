// flutter_sound
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class FlutterSoundController extends GetxController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final RxBool _isRecording = false.obs;
  final RxBool _isPlaying = false.obs;
  late RxString transcript = ''.obs;
  late String _pathToAudio;

  @override
  void onInit() async {
    super.onInit();
    // Request necessary permissions
    await [Permission.microphone, Permission.storage].request();
  }

  Future<String> transcribeAudio(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();

    final response = await http.post(
      Uri.parse(
          "https://api.deepgram.com/v1/listen?model=whisper&detect_language=true&filler_words=false&version=latest"),
      headers: {
        'Authorization': 'Token 4eb2f30695ae2d6d0945dd2248189916912eb895',
        'Content-Type': 'audio/wav',
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to transcribe audio');
    }
  }

  void startRecording(String path) async {
    _pathToAudio = path;
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: _pathToAudio, bitRate: 64000);
    _isRecording.value = true;
  }

  Future stopRecording() async {
    await _recorder.stopRecorder().then((value) {
      _pathToAudio = value!;
    });
    await _recorder.closeRecorder();
    _isRecording.value = false;
    try {
      final transcription = await transcribeAudio(_pathToAudio);
      transcript.value = json.decode(transcription)['results']['channels'][0]['alternatives'][0]['transcript'];
      print('Transcription: $transcription');
    } catch (e) {
      print('Failed to transcribe audio: $e');
    }
  }

  void startPlaying() async {
    await _player.openPlayer();
    await _player.startPlayer(fromURI: _pathToAudio);
    _isPlaying.value = true;
  }

  void stopPlaying() async {
    await _player.stopPlayer();
    await _player.closePlayer();
    _isPlaying.value = false;
  }

  bool get isRecording => _isRecording.value;
  bool get isPlaying => _isPlaying.value;
}
