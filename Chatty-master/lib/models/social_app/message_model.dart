import 'package:audioplayers/audioplayers.dart';
class MessageModel
{
  String? senderId;
  String? receiverId;
  String? dateTime;
  String? text;
  String? image;
  String? audio;
  bool? isBullying;
  bool isPlaying;
  AudioPlayer? player;
  Duration? duration;
  Duration? position;

  MessageModel({
   this.senderId,
    this.receiverId,
    this.dateTime,
    this.text,
    this.image,
    this.audio,
    this.isBullying,
    this.isPlaying = false
  });

  MessageModel.fromJson(Map<String,dynamic> json, [this.isPlaying = false])
  {
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    dateTime = json['dateTime'];
    text = json['text'];
    image = json['image'];
    audio = json['audio'];
    isBullying = json['isBullying'];
    if(audio != null){
      player = AudioPlayer();
      duration = const Duration(seconds: 5);
      position = Duration.zero;
      player!.onPositionChanged.listen((event) {
        position = event;
      });
      player!.onDurationChanged.listen((event) {
        duration = event;
      });
    }
  }

  Map<String,dynamic> toMap()
  {
    return {
      'senderId' : senderId,
      'receiverId' : receiverId,
      'dateTime' : dateTime,
      'text' : text,
      'image' : image,
      'audio' : audio,
      'isBullying' : isBullying,
    };
  }

}