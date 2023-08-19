
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:music/controller.dart';
import 'package:music/play_list.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';



void main() {
  runApp(const GetMaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final player = AudioPlayer();
  bool t=false;

  int selectedIndex=0;
  final List  _pages = [];

  final Controller c = Get.put(Controller());

  @override
  void initState() {
    super.initState();
  }

  permission() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      var status = await Permission.storage.status;
      var status1 = await Permission.audio.status;
      if(sdkInt>30)
        {
          if (status.isDenied || status1.isDenied) {
            Map<Permission, PermissionStatus> statuses = await [
              Permission.audio,
              Permission.storage,
            ].request();
            t=true;
          }
        }
      else
        {
          if(status.isDenied)
            {
              Map<Permission, PermissionStatus> statuses = await [
                Permission.storage,
              ].request();
              t=true;
            }
      }
      t=true;
      setState(() {});
    }
  }

  musicList() async {
    List<AlbumModel> albums = await _audioQuery.queryAlbums();
    print("albums :");
    print(albums.toList());
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    t = c.temp.value;
    print(t);
    return Scaffold(
        backgroundColor: Colors.black,
        appBar:  AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("My Music"),centerTitle: true,
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 60),
          margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
          decoration:  BoxDecoration(color: Colors.grey.shade600.withOpacity(.60),
              borderRadius: const BorderRadius.all(Radius.circular(20))
          ),
          child: GNav(
              gap: 8, color: Colors.white,
              activeColor: Colors.white,tabActiveBorder: Border.all(color: Colors.grey.shade900),
              tabBackgroundColor: Colors.grey.shade800,
              padding: const EdgeInsets.all(10),
              rippleColor: Colors.white, hoverColor: Colors.white,
              onTabChange: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              tabs:  [
                const GButton(
                  icon: Icons.home,iconSize: 30,
                  text: 'Home',
                ),
                const GButton(
                  icon: Icons.person,iconSize: 30,
                  text: 'Profile',
                ),
              ]
          ),
        ),
        body: SafeArea(
            child: (t) ? FutureBuilder(
              future: _audioQuery.querySongs(
                  ignoreCase: true,
                  orderType: OrderType.ASC_OR_SMALLER,
                  sortType: null,
                  uriType: UriType.EXTERNAL
              ),
              builder: (context, snapshot) {
                if( snapshot.connectionState == ConnectionState.waiting)
                {
                  return const Center(child: CircularProgressIndicator(),);
                }
                else
                {
                  List<SongModel> list = snapshot.data as List<SongModel>;
                  c.isPlaying.value = List.filled(list.length, false);
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Obx(() => customListView(
                          image: "images/music.jpg",
                       // image: "${list[index].album}",
                          singer: "${list[index].artist}",index: index,
                          title: list[index].displayName,
                          icon: (c.isPlaying[index]) ? Icons.pause_circle : Icons.play_circle,
                          songTap: () {
                            if (player.state == PlayerState.playing) {
                              player.pause();
                              c.isPlaying[index] =! c.isPlaying[index];
                            }
                            else {
                              player.play(DeviceFileSource(list[index].data));
                              c.isPlaying[index] =! c.isPlaying[index];
                            }
                          },
                          onTap: () {
                            c.playIndex.value = index;
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                              return PlayList(list);
                            },));

                          }));
                    },);
                }
              },) : const Center(child: CircularProgressIndicator())
        )
    );
  }


  Widget customListView({
    String? title,
    String? singer,
    String? image,
    IconData? icon,
    int? index,
    onTap,
    songTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
        decoration: BoxDecoration(
          color: (c.isPlaying[index!]) ? Colors.grey.shade800: Colors.grey.shade900.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: (c.isPlaying[index!]) ? Border.all(color: Colors.white) : null,

        ),
        child: Row(
          children: [
            InkWell(
              onTap: songTap,
              child: Stack(
                  children: [
                    SizedBox(height: 60.0, width: 60.0,
                        child: ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset(image! ?? "", fit: BoxFit.cover))
                    ),

                    SizedBox(height: 60.0, width: 60.0,
                        child: Icon(icon  , color: Colors.white.withOpacity(0.7), size: 42.0,)
                    )
                  ]
              ),
            ),
            const SizedBox(width: 16.0),
            InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (title!.toString().length>23) ?
                  Text("${title!.toString().substring(0, 20)}..",overflow: TextOverflow.fade,maxLines: 1,
                      style: const TextStyle(color: Colors.white60,fontWeight: FontWeight.normal,fontSize: 18.0,overflow: TextOverflow.fade,))
                      : Text(title!,style: const TextStyle(color: Colors.white60,fontWeight: FontWeight.normal, fontSize: 18.0)),

                  const SizedBox(height: 8.0),
                  Text(singer!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14.0),),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.6), size: 25.0,)
          ],
        ),
      ),
    );
  }

}
