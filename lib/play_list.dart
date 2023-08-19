import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:music/controller.dart';
import 'package:music/main.dart';
import 'package:music/my_box.dart';

import 'package:on_audio_query/on_audio_query.dart';


class PlayList extends StatefulWidget {
  List <SongModel> list;
  PlayList(this.list,{super.key,});

  @override
  State<PlayList> createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  final player = AudioPlayer();
  bool isPlaying = false;
  bool loop = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  final Controller cont = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    // check music is playing or not
    player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      setState(() {});
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    (loop) ? player.setReleaseMode(ReleaseMode.loop) : player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String formatTime(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return[
      if(duration.inHours>0) hours,minutes,seconds,
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: _customAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 50,width: 50,
                      child: MyBox(child: const Icon(Icons.arrow_back_ios_new_rounded),
                          onTap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                              return HomePage();
                            },));
                          }),
                    ),
                    SizedBox(height: 50,width: 50,
                      child: MyBox(child: InkWell(onTap: () {
                        setState(() {

                        });
                      },child: const Icon(Icons.menu))),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),

                MyBox(margin: 5,
                    child: Column(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(10),child: Image.asset("images/music.jpg"),),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (widget.list[cont.playIndex.value].displayName.length>30) ?
                                  Text("${widget.list[cont.playIndex.value].displayName.substring(0,28)}...", style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16,))
                                      : Text(widget.list[cont.playIndex.value].displayName, style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16,)),
                                  const SizedBox(height: 4,),
                                  Text("${widget.list[cont.playIndex.value].artist}",style: TextStyle(color: Colors.grey.shade600,fontSize: 14,fontWeight: FontWeight.w500),),

                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 20,),

                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(formatTime(position)),
                    const Icon(Icons.shuffle),
                    InkWell(
                        onTap: () {
                          loop = !loop;
                          setState(() {});
                        },
                        child: (loop) ? const Icon(Icons.repeat_one) : const Icon(Icons.repeat)),
                    Text(formatTime( duration-position))
                  ],
                ),
                const SizedBox(height: 20,),

                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade500,blurRadius: 15,offset: const Offset(5, 5)),
                        const BoxShadow( color: Colors.white,blurRadius: 15,offset: Offset(-5, -5) )]
                  ),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 15,
                        thumbColor: Colors.transparent,
                        thumbShape: SliderComponentShape.noThumb),
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      activeColor: Colors.green,
                      inactiveColor: Colors.green.withOpacity(0.2),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await player.seek(position);

                        await player.resume();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30,),

                SizedBox(height: 60,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MyBox(onTap: () {
                          if(cont.playIndex.value>0)
                          {
                            print(widget.list.length);
                            print(cont.playIndex.value);
                            cont.playIndex.value -- ;
                            player.play(DeviceFileSource(widget.list[cont.playIndex.value].data));
                            setState(() {});
                          }
                        },child: const Icon(Icons.skip_previous,size: 32,),),
                      ),
                      Expanded(flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: MyBox(child: (isPlaying) ? const Icon(Icons.pause,size: 32) : const Icon(Icons.play_arrow,size: 32),
                            onTap: (){
                              if (isPlaying) {
                                player.pause();
                              }
                              else {
                                player.play(DeviceFileSource(widget.list[cont.playIndex.value].data));
                              }
                            },),
                        ),
                      ),
                      Expanded(
                        child: MyBox(onTap: () {
                          if(widget.list.length > cont.playIndex.value+1)
                          {
                            print(widget.list.length);
                            print(cont.playIndex.value);
                            cont.playIndex.value ++ ;
                            player.play(DeviceFileSource(widget.list[cont.playIndex.value].data));
                            setState(() {});
                          }
                          else
                          {
                            player.stop();
                          }
                        },child: const Icon(Icons.skip_next,size: 32,)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

_customAppBar () {
  AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: const Icon(Icons.grid_view_outlined),
    actions: [
      IconButton(onPressed: () {

      }, icon: const Icon(Icons.person))
    ],
  );
}