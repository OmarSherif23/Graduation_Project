import 'package:Chatty/models/social_app/message_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../shared/styles/colors.dart';

class VoiceListView extends StatefulWidget {
  const VoiceListView({Key? key, required this.url, required this.isSender}) : super(key: key);
  final String url;
  final bool isSender;


  @override
  State<VoiceListView> createState() => _VoiceListViewState();
}

class _VoiceListViewState extends State<VoiceListView> {

   MessageModel? model;

  final play = AudioPlayer();
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void handlePlayPause() {
    if (play.playing) {
      play.pause();
    } else {
      play.play();
    }
  }

  void handleSeek(double value) {
    play.seek(Duration(seconds: value.toInt()));
  }

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    play.setUrl(widget.url);
    play.positionStream.listen((p) {
      setState(() => position = p);
    });
    play.durationStream.listen((d) {
      setState(() => duration = d!);
    });

    play.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          position = Duration.zero;
        });
        play.pause();
        play.seek(position);
      }
    });
    print('???????????>>>>>>>>>>${duration.inSeconds}');
    print('???????????>>>>>>>>>>${position.inSeconds}');

  }

  @override
  Widget build(BuildContext context) {
    return
          Row(
            children: [
              IconButton(
                // onPressed: isPlaying ? pauseRecording : playRecording,
                onPressed: () {
                 handlePlayPause();
                 print('???????????>>>>>>>>>>$duration');
                 print('???????????>>>>>>>>>>$position');

                },
                color: widget.isSender ? defaultColor : Colors.grey[600],
                icon:
                play.playing
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
              ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: handleSeek,
                activeColor:widget.isSender ? defaultColor : Colors.grey[600],
                thumbColor: widget.isSender ? defaultColor : Colors.grey[600],
              ),
              Text(formatDuration(position)),
            ],
          );

  }
}
