import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_example/main.dart';
import 'package:audio_service_example/widgets/item.dart';
import 'package:audio_service_example/audio_service/common.dart';
import 'package:audio_service_example/audio_service/control_buttons.dart';
import 'package:audio_service_example/audio_service/queue_state.dart';
import 'package:audio_service_example/widgets/main_drawer.dart';
import 'package:rxdart/rxdart.dart' as rx;

/// The main screen.
class MainScreen extends StatelessWidget {
  Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState.map((state) => state.bufferedPosition).distinct();
  Stream<Duration?> get _durationStream => audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream => rx.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      AudioService.position,
      _bufferedPositionStream,
      _durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MainDrawer(),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Repeat/shuffle controls
              // Row(
              //   children: [
              //     StreamBuilder<AudioServiceRepeatMode>(
              //       stream: audioHandler.playbackState.map((state) => state.repeatMode).distinct(),
              //       builder: (context, snapshot) {
              //         final repeatMode = snapshot.data ?? AudioServiceRepeatMode.none;
              //         const icons = [
              //           Icon(Icons.repeat, color: Colors.grey),
              //           Icon(Icons.repeat, color: Colors.orange),
              //           Icon(Icons.repeat_one, color: Colors.orange),
              //         ];
              //         const cycleModes = [
              //           AudioServiceRepeatMode.none,
              //           AudioServiceRepeatMode.all,
              //           AudioServiceRepeatMode.one,
              //         ];
              //         final index = cycleModes.indexOf(repeatMode);
              //         return IconButton(
              //           icon: icons[index],
              //           onPressed: () {
              //             audioHandler.setRepeatMode(cycleModes[(cycleModes.indexOf(repeatMode) + 1) % cycleModes.length]);
              //           },
              //         );
              //       },
              //     ),
              //     Expanded(
              //       child: Text(
              //         "Playlist",
              //         style: Theme.of(context).textTheme.headline6,
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //     StreamBuilder<bool>(
              //       stream: audioHandler.playbackState.map((state) => state.shuffleMode == AudioServiceShuffleMode.all).distinct(),
              //       builder: (context, snapshot) {
              //         final shuffleModeEnabled = snapshot.data ?? false;
              //         return IconButton(
              //           icon: shuffleModeEnabled
              //               ? const Icon(Icons.shuffle, color: Colors.orange)
              //               : const Icon(Icons.shuffle, color: Colors.grey),
              //           onPressed: () async {
              //             final enable = !shuffleModeEnabled;
              //             await audioHandler.setShuffleMode(enable ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
              //           },
              //         );
              //       },
              //     ),
              //   ],
              // ),
              // Playlist
              Expanded(
                child: StreamBuilder<QueueState>(
                  stream: audioHandler.queueState,
                  builder: (context, snapshot) {
                    final queueState = snapshot.data ?? QueueState.empty;
                    final queue = queueState.queue;

                    return ListView.separated(
                      itemCount: queue.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (c, i) => ItemWidget(
                        index: i,
                        url: "",
                        color: i == queueState.queueIndex ? Colors.grey.shade300 : null,
                                // onTap: () => audioHandler.skipToQueueItem(i),

                      ),
                    );
                    // return ReorderableListView(
                    //   shrinkWrap: false,
                    //   onReorder: (int oldIndex, int newIndex) {
                    //     if (oldIndex < newIndex) newIndex--;
                    //     audioHandler.moveQueueItem(oldIndex, newIndex);
                    //   },
                    //   children: [
                    //     for (var i = 0; i < queue.length; i++)
                    //       Dismissible(
                    //         key: ValueKey(queue[i].id),
                    //         background: Container(
                    //           color: Colors.redAccent,
                    //           alignment: Alignment.centerRight,
                    //           child: const Padding(
                    //             padding: EdgeInsets.only(right: 8.0),
                    //             child: Icon(Icons.delete, color: Colors.white),
                    //           ),
                    //         ),
                    //         onDismissed: (dismissDirection) {
                    //           audioHandler.removeQueueItemAt(i);
                    //         },
                    //         child: Material(
                    //           color: i == queueState.queueIndex ? Colors.grey.shade300 : null,
                    //           child: ListTile(
                    //             title: Text(queue[i].title),
                    //             onTap: () => audioHandler.skipToQueueItem(i),
                    //           ),
                    //         ),
                    //       ),
                    //   ],
                    // );
                  },
                ),
              ),

              // A seek bar.
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data ?? PositionData(Duration.zero, Duration.zero, Duration.zero);
                  return SeekBar(
                    duration: positionData.duration,
                    position: positionData.position,
                    onChangeEnd: (newPosition) => audioHandler.seek(newPosition),
                  );
                },
              ),
              const SizedBox(height: 8.0),
              // Playback controls
              ControlButtons(audioHandler),
            ],
          ),
        ),
      ),
    );
  }
}
