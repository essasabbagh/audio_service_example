import 'package:audio_service/audio_service.dart';
import 'package:audio_service_example/audio_service/common.dart';
import 'package:audio_service_example/audio_service/control_buttons.dart';
import 'package:audio_service_example/main.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;

/// The main screen.
class LessonScreen extends StatelessWidget {
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MediaItem display
            Expanded(
              child: StreamBuilder<MediaItem?>(
                stream: audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (mediaItem.artUri != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Image.network('${mediaItem.artUri!}'),
                            ),
                          ),
                        ),
                      Text(mediaItem.album ?? '', style: Theme.of(context).textTheme.headline6),
                      Text(mediaItem.title),
                    ],
                  );
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
            // Playback controls
            ControlButtons(audioHandler),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
