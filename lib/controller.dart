import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class Controller extends GetxController {

  RxList isPlaying = [].obs;
  RxBool temp = false.obs;
  RxInt playIndex = 0.obs;
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  void onInit(){
    super.onInit();
    permission();

  }

  permission() async {
    var status = await Permission.storage.status;
    var status1 = await Permission.audio.status;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if(sdkInt>30)
      {
        if (status.isDenied || status1.isDenied) {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.audio,
            Permission.storage,
          ].request();
          temp.value=true;
        }
      }
      else
      {
        if(status.isDenied)
        {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
          ].request();
          temp.value=true;
        }
      }
      temp.value=true;
    }
    print("object : ${temp.value}");

  }

  final player = AudioPlayer();
  final musicPlayer = AudioPlayer();
  RxBool isPlay = false.obs;
  RxBool loop = false.obs;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  songDetail(){
    musicPlayer.onPlayerStateChanged.listen((state) {
      isPlay.value = state == PlayerState.playing;
    });

    musicPlayer.onDurationChanged.listen((newDuration) {
      duration = newDuration;
    });

    musicPlayer.onPositionChanged.listen((newPosition) {
      position = newPosition;
    });

  }

  repateSong(){
    (loop.value) ? musicPlayer.setReleaseMode(ReleaseMode.loop) : musicPlayer.setReleaseMode(ReleaseMode.stop);
    loop.value =! loop.value;
    print(loop.value);
  }
}