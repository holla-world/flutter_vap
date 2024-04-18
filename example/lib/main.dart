import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vap/flutter_vap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> downloadPathList = [];
  bool isDownload = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 140, 41, 43),
            image: DecorationImage(image: AssetImage("static/bg.jpeg")),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoButton(
                    color: Colors.purple,
                    child:
                        Text("download video source${isDownload ? "(✅)" : ""}"),
                    onPressed: _download,
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("File1 play"),
                    onPressed: () => _playFile(downloadPathList[0]),
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("File2 play"),
                    onPressed: () => _playFile(downloadPathList[1]),
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("asset play"),
                    onPressed: () => _playAsset("static/demo.mp4"),
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("stop play"),
                    onPressed: () => VapController.stop(),
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("queue play"),
                    onPressed: _queuePlay,
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("cancel queue play"),
                    onPressed: _cancelQueuePlay,
                  ),
                ],
              ),
              IgnorePointer(
                // VapView可以通过外层包Container(),设置宽高来限制弹出视频的宽高
                // VapView can set the width and height through the outer package Container() to limit the width and height of the pop-up video
                child: VapView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _download() async {}

  Future<Map<dynamic, dynamic>?> _playFile(String path) async {
    var res = await VapController.playPath(path);
    if (res!["status"] == "failure") {
      // showToast(res["errorMsg"]);
    }
    return res;
  }

  Future<Map<dynamic, dynamic>?> _playAsset(String asset) async {
    var res = await VapController.playAsset(asset);
    if (res!["status"] == "failure") {
      // showToast(res["errorMsg"]);
    }
    return res;
  }

  _queuePlay() async {
    // 模拟多个地方同时调用播放,使得队列执行播放。
    // Simultaneously call playback in multiple places, making the queue perform playback.
    QueueUtil.get("vapQueue")
        ?.addTask(() => VapController.playPath(downloadPathList[0]));
    QueueUtil.get("vapQueue")
        ?.addTask(() => VapController.playPath(downloadPathList[1]));
  }

  _cancelQueuePlay() {
    QueueUtil.get("vapQueue")?.cancelTask();
  }
}
