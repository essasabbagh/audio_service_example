import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_service_example/audio_service/queue_state.dart';
import 'package:audio_service_example/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({
    Key? key,
    required this.index,
    required this.url,
    required this.color,
  }) : super(key: key);

  final int index;
  final String url;
  final Color? color;

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  bool _allowWriteFile = false;

  requestWritePermission() async {
    if (await Permission.storage.request().isGranted) {
      _allowWriteFile = true;
      // setState(() => _allowWriteFile = true);
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  bool downloading = false;
  String progress = '0';
  bool isDownloaded = false;

  // String uri = 'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3'; // url of the file to be downloaded

  String filename = 'test.pdf'; // file name that you desire to keep

  // downloading logic is handled by this method
  Future<void> downloadFile(uri, fileName) async {
    if (!_allowWriteFile) {
      requestWritePermission();
    } else {
      setState(() => downloading = true);
      String savePath = await getFilePath(uri);
      Dio dio = Dio();
      dio.download(
        uri,
        savePath,
        onReceiveProgress: (rcv, total) {
          print('received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
          setState(() => progress = ((rcv / total) * 100).toStringAsFixed(0));
          if (progress == '100') {
            setState(() => isDownloaded = true);
          } else if (double.parse(progress) < 100) {}
        },
        deleteOnError: true,
      ).then((_) {
        setState(() {
          if (progress == '100') {
            isDownloaded = true;
          }
          downloading = false;
        });
      });
    }
  }

  //gets the applicationDirectory and path for the to-be downloaded file

  // which will be used to save the file to that path in the downloadFile method

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName.mp3';
    File f = File(path);

    setState(() => isDownloaded = f.existsSync());

    return path;
  }

  // Future<String> getDirectoryPath(String url) async {
  //   Directory appDocDirectory = await getApplicationDocumentsDirectory();

  //   Directory directory = await Directory(appDocDirectory.path + '/' + 'mp3').create(recursive: true);

  //   String extension = url.substring(url.lastIndexOf("/"));
  //   File f = File(directory.path + extension);

  //   setState(() => isDownloaded = f.existsSync());
  //   return directory.path;
  // }

  @override
  void initState() {
    super.initState();
    getFilePath(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed('/lesson'),
      child: Card(
        color: widget.color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Card No : ${widget.index}",
                    style: const TextStyle(fontSize: 24),
                  ),
                  if (isDownloaded) const Text('File Downloaded!') else const Text('Click to start Downloading!'),
                ],
              ),
              StreamBuilder<QueueState>(
                stream: audioHandler.queueState,
                builder: (context, snapshot) {
                  final queueState = snapshot.data ?? QueueState.empty;
                  return widget.index == queueState.queueIndex
                      ? StreamBuilder<PlaybackState>(
                          stream: audioHandler.playbackState,
                          builder: (context, snapshot) {
                            final playbackState = snapshot.data;
                            final processingState = playbackState?.processingState;
                            final playing = playbackState?.playing;
                            if (processingState == AudioProcessingState.loading ||
                                processingState == AudioProcessingState.buffering) {
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                width: 32.0,
                                height: 32.0,
                                child: const CircularProgressIndicator(),
                              );
                            } else if (playing != true) {
                              return IconButton(
                                icon: const Icon(Icons.play_arrow),
                                iconSize: 32.0,
                                onPressed: audioHandler.play,
                              );
                            } else {
                              return IconButton(
                                icon: const Icon(Icons.pause),
                                iconSize: 32.0,
                                onPressed: audioHandler.pause,
                              );
                            }
                          },
                        )
                      : StreamBuilder<PlaybackState>(
                          stream: audioHandler.playbackState,
                          builder: (context, snapshot) {
                            return IconButton(
                              icon: const Icon(Icons.play_arrow),
                              iconSize: 32.0,
                              onPressed: () => audioHandler.skipToQueueItem(widget.index),
                            );
                          },
                        );
                },
              ),
              // if (isDownloaded)
              //   MyBtn()
              // else
              //   downloading
              //       ? CircularPercentIndicator(
              //           animation: true,
              //           radius: 60.0,
              //           lineWidth: 5.0,
              //           circularStrokeCap: CircularStrokeCap.round,
              //           percent: double.parse(progress) / 100,
              //           center: Text('$progress%'),
              //           progressColor: Theme.of(context).primaryColor,
              //         )
              //       : TextButton(
              //           child: const Text("Click"),
              //           onPressed: () async {
              //             getFilePath(widget.url).then(
              //               (path) {
              //                 File f = File(path);
              //                 if (f.existsSync()) return;
              //                 // Navigator.push(context, MaterialPageRoute(builder: (context) => PDFScreen(f.path)));

              //                 downloadFile(widget.url, filename);
              //               },
              //             );
              //           })
            ],
          ),
        ),
      ),
    );
  }
}

class MyBtn extends StatefulWidget {
  const MyBtn({Key? key}) : super(key: key);

  @override
  _MyBtnState createState() => _MyBtnState();
}

class _MyBtnState extends State<MyBtn> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 32.0,
                height: 32.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 32.0,
                onPressed: audioHandler.play,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 32.0,
                onPressed: audioHandler.pause,
              );
            }
          },
        );
      },
    );
  }
}
