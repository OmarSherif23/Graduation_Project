import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Chatty/modules/social_app/profile_view/profile_view.dart';
import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/layout/social_app/cubit/states.dart';
import 'package:Chatty/models/social_app/message_model.dart';
import 'package:Chatty/models/social_app/social_user_model.dart';
import 'package:Chatty/modules/social_app/chat_details/ban_systen.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:Chatty/shared/styles/colors.dart';
import 'package:Chatty/shared/styles/icon_broken.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as pth;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/components/components.dart';
import '../social_login/social_login_screen.dart';
import 'image_message_screen.dart';



enum CounterType { age, religion, gender, ethnicity, other }
class ChatDetailsScreen extends StatefulWidget {
  SocialUserModel? userModel;

  ChatDetailsScreen({
    super.key,
    this.userModel,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late SocialUserModel currentUser;

  var url;
  var queryText;

  int sum = 0;

  var messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  String path = '';

  bool is_record = false;

  AudioRecorder? record;
  // late AudioPlayer audioPlayer;

  bool isPlaying = false;

  BanSystem banSystem = BanSystem();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    record = AudioRecorder();

    SocialCubit.get(context).getMessages(
      receiverId: widget.userModel!.uId!,
    );
    super.initState();
  }

  @override
  void dispose() {
    record!.dispose();
    // audioPlayer.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }
  String formatDuration(Duration d){
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}";
  }

  Future<void> playRecording(AudioPlayer player) async {
    try {
      //Source urlSource = UrlSource(audioPath);
      print("++++++++++");
      print(url1);
      await player.play(UrlSource(url1!));
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error Playing Recording : $e');
      rethrow;
    }
  }


  Future<void> pauseRecording(AudioPlayer player) async {
    try {
      //Source urlSource = UrlSource(audioPath);
      await player.pause();
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      print('Error pausing Recording : $e');
    }
  }
  Future<void> start_record() async {
    final location = await getApplicationDocumentsDirectory();
    String name = const Uuid().v4() +
        DateTime.now().toIso8601String().replaceAll('.', '-');
    if (await record!.hasPermission()) {
      await record!.start(const RecordConfig(), path: '${location.path}$name.m4a');
      setState(() {
        is_record = true;
        print('start Record');
        print('${location.path}$name.m4a');
        //url1 = '${location.path}$name.m4a';
      });
    }
    print('Start Record');
  }

  Future <void> stop_record(BuildContext context) async {
    String? finalPath = await record!.stop();
    setState(() {
      path = finalPath!;
      is_record = false;
    });
    print('Stop Record');
    upload(context);
  }

  void sendMessage(BuildContext context, bool temp) {
    SocialCubit.get(context).sendMessage(
      receiverId: widget.userModel!.uId!,
      dateTime: DateTime.now().toString(),
      text: messageController.text,
      image: messageImg ?? '',
      audio: url1 ?? '',
      warning: temp,
    );
    messageController.clear();
    messageImg = null;
    url1 = null;
  }

  void upload(BuildContext context){
    String name = pth.basename(path);
    FirebaseStorage.instance
        .ref('voice/$name')
        .putFile(File(path))
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value.toString());
        url1 = value;
        print(url1);
        // sendMessage(context,false);
      }).catchError((error) {
        print('error :$error');
      });
    }).catchError((error) {
      print('error :$error');
    });
    print('Uploaded');
  }

  Future<String> predictRecord(String recordUrl) async {
    final endpointUrl = 'http://192.168.1.9:5000/record?recordUrl=$recordUrl';

    final response = await http.get(Uri.parse(endpointUrl));
    if (response.statusCode == 200) {
      final result = json.decode(response.body)['prediction'];
      print(result);
      return result;
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  Future<String> fetchData(String? queryString) async {
    final response = await http
        .get(Uri.parse('http://192.168.1.9:5000//?query=$queryString'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['prediction'];
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return BlocConsumer<SocialCubit, SocialStates>(
          listener: (context, state) {
            if (state is SocialSendMessageSuccessState ||
                state is SocialRecieveMessageSuccessState) {
              scrollDown();
            } else if (state is SocialGetMessagesSuccessState) {
              scrollDown();
            }
          },
          builder: (context, state) {
            return Theme(
              data: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  iconTheme: IconThemeData(
                    color: Colors.black,
                  ),
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              child: Scaffold(
                appBar: AppBar(
                  titleSpacing: 0.0,
                  title: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          navigateToProfileScreen(context);
                        },
                        child: CircleAvatar(
                          radius: 20.0,
                          backgroundImage:
                              NetworkImage(widget.userModel!.image!),
                        ),
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      InkWell(
                        onTap: () {
                          navigateToProfileScreen(context);
                        },
                        child: Text(
                          widget.userModel!.name!,
                        ),
                      ),
                    ],
                  ),
                ),
                resizeToAvoidBottomInset: true,
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  SocialCubit.get(context).messages.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 15.0,
                              ),
                              itemBuilder: (context, index) {
                                var message = SocialCubit.get(context).messages[index];
                                bool isCurrentUserMessage =
                                    SocialCubit.get(context).userModel.uId ==
                                        message.senderId;
                                bool? isCyberbullying = message
                                    .isBullying;
                                print("messages: $message");
                                if (isCurrentUserMessage) {
                                  if (message.audio!.isNotEmpty &&
                                      isCyberbullying! == false) {
                                    print('Received');
                                    return buildVoiceMessage(
                                        message, context, true);
                                  }
                                  if (isCyberbullying!) {
                                    // if this is the user's message and it's cyberbullying, display a warning message
                                    print('Sent Bullying');
                                    return buildWarningMessage(
                                        'This is Bullying');
                                  } else {
                                    // if(message.audio!.isNotEmpty){
                                    //   print('Received');
                                    //   messageType = false;
                                    //   return buildVoiceMyMessage(message, context);
                                    // }
                                    // if this is the user's message and it's not cyberbullying, display the user's message
                                    print('Sent Normal');
                                    return buildMyMessage(message, context);
                                  }
                                }
                                else {
                                  if (message.audio!.isNotEmpty &&
                                      isCyberbullying! == false) {
                                    print('Received');
                                    return buildVoiceMessage(
                                        message, context, false);
                                  }
                                  // if this is not the user's message, display the message normally
                                  if (isCyberbullying == true) {
                                    // if this is not the user's message and it's cyberbullying, don't display the message
                                    return const SizedBox.shrink();
                                  } else {
                                    // if this is not the user's message and it's not cyberbullying, display the message
                                    print('Received');
                                    return buildMessage(message, context);
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type your message here...',
                                      contentPadding: EdgeInsets.all(10.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    messageImg = '';
                                    SocialCubit.get(context).getMessageImage();
                                    navigateTo(
                                        context,
                                        ImageUploaded(
                                          userModel: widget.userModel,
                                        ));
                                  },
                                  minWidth: 1.0,
                                  child: const Icon(
                                    IconBroken.Image,
                                    size: 22.0,
                                    color: defaultColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 50.0,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (!is_record) {
                                      await  start_record();
                                      } else {
                                        await stop_record(context);
                                        currentUser = (await SocialCubit.get(
                                                context)
                                            .getCurrentUserData(loggedID!))!;
                                        sum = currentUser.sumOfCounters!;
                                        final encodedUrl =
                                            Uri.encodeComponent(url1!);
                                        queryText =
                                            await predictRecord(encodedUrl);
                                        if (currentUser.isBanned == false) {
                                          if (queryText !=
                                              'not_cyberbullying') {
                                            if (url1 != null) {
                                              switch (queryText) {
                                                case 'age':
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.age,
                                                      currentUser.ageCounter! +
                                                          1);
                                                  sum += 1;
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser.ageCounter ==
                                                      3) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Due to inappropriate behavior you are banned from sending messages')),
                                                    );
                                                    banSystem.tempBan(
                                                        loggedID!, true);
                                                    banSystem.updateUserNumOfBans(
                                                        loggedID!,
                                                        currentUser
                                                                .numberOfBans! +
                                                            1);
                                                    banSystem.updateUserCounter(
                                                        loggedID!,
                                                        CounterType.age,
                                                        0);
                                                    currentUser =
                                                        (await SocialCubit.get(
                                                                context)
                                                            .getCurrentUserData(
                                                                loggedID!))!;
                                                    if (currentUser
                                                            .numberOfBans! >=
                                                        5) {
                                                      banSystem.updateUserState(
                                                          loggedID!, true);
                                                      banSystem
                                                          .userLogout(context);
                                                      navigateAndfFinish(
                                                          context,
                                                          SocialLoginScreen());
                                                    }
                                                  }
                                                  break;
                                                case 'religion':
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.religion,
                                                      currentUser
                                                              .religionCounter! +
                                                          1);
                                                  sum += 1;
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .religionCounter ==
                                                      2) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Due to inappropriate behavior you are banned from sending messages')),
                                                    );
                                                    banSystem.tempBan(
                                                        loggedID!, true);
                                                    banSystem.updateUserNumOfBans(
                                                        loggedID!,
                                                        currentUser
                                                                .numberOfBans! +
                                                            1);
                                                    banSystem.updateUserCounter(
                                                        loggedID!,
                                                        CounterType.religion,
                                                        0);
                                                    currentUser =
                                                        (await SocialCubit.get(
                                                                context)
                                                            .getCurrentUserData(
                                                                loggedID!))!;
                                                    if (currentUser
                                                            .numberOfBans! >=
                                                        5) {
                                                      banSystem.updateUserState(
                                                          loggedID!, true);
                                                      banSystem
                                                          .userLogout(context);
                                                      navigateAndfFinish(
                                                          context,
                                                          SocialLoginScreen());
                                                    }
                                                  }
                                                  break;
                                                case 'ethnicity':
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.ethnicity,
                                                      currentUser
                                                              .ethnicityCounter! +
                                                          1);
                                                  sum += 1;
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .ethnicityCounter ==
                                                      4) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Due to inappropriate behavior you are banned from sending messages')),
                                                    );
                                                    banSystem.tempBan(
                                                        loggedID!, true);
                                                    banSystem.updateUserNumOfBans(
                                                        loggedID!,
                                                        currentUser
                                                                .numberOfBans! +
                                                            1);
                                                    banSystem.updateUserCounter(
                                                        loggedID!,
                                                        CounterType.ethnicity,
                                                        0);
                                                    currentUser =
                                                        (await SocialCubit.get(
                                                                context)
                                                            .getCurrentUserData(
                                                                loggedID!))!;
                                                    if (currentUser
                                                            .numberOfBans! >=
                                                        5) {
                                                      banSystem.updateUserState(
                                                          loggedID!, true);
                                                      banSystem
                                                          .userLogout(context);
                                                      navigateAndfFinish(
                                                          context,
                                                          SocialLoginScreen());
                                                    }
                                                  }
                                                  break;
                                                case 'gender':
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.gender,
                                                      currentUser
                                                              .genderCounter! +
                                                          1);
                                                  sum += 1;
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .genderCounter ==
                                                      6) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Due to inappropriate behavior you are banned from sending messages')),
                                                    );
                                                    banSystem.tempBan(
                                                        loggedID!, true);
                                                    banSystem.updateUserNumOfBans(
                                                        loggedID!,
                                                        currentUser
                                                                .numberOfBans! +
                                                            1);
                                                    banSystem.updateUserCounter(
                                                        loggedID!,
                                                        CounterType.gender,
                                                        0);
                                                    currentUser =
                                                        (await SocialCubit.get(
                                                                context)
                                                            .getCurrentUserData(
                                                                loggedID!))!;
                                                    if (currentUser
                                                            .numberOfBans! >=
                                                        5) {
                                                      banSystem.updateUserState(
                                                          loggedID!, true);
                                                      banSystem
                                                          .userLogout(context);
                                                      navigateAndfFinish(
                                                          context,
                                                          SocialLoginScreen());
                                                    }
                                                  }
                                                  break;
                                                case 'other_cyberbullying':
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.other,
                                                      currentUser
                                                              .otherCounter! +
                                                          1);
                                                  sum += 1;
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser.otherCounter == 5)
                                                  {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Due to inappropriate behavior you are banned from sending messages')),
                                                    );
                                                  }
                                                  if (currentUser
                                                          .otherCounter ==
                                                      6) {
                                                    banSystem.tempBan(
                                                        loggedID!, true);
                                                    banSystem.updateUserNumOfBans(
                                                        loggedID!,
                                                        currentUser
                                                                .numberOfBans! +
                                                            1);
                                                    banSystem.updateUserCounter(
                                                        loggedID!,
                                                        CounterType.other,
                                                        0);
                                                    currentUser =
                                                        (await SocialCubit.get(
                                                                context)
                                                            .getCurrentUserData(
                                                                loggedID!))!;
                                                    if (currentUser
                                                        .numberOfBans! >
                                                        1) {
                                                      banSystem.updateUserState(
                                                          loggedID!, true);
                                                      banSystem
                                                          .userLogout(context);
                                                      navigateAndfFinish(
                                                          context,
                                                          SocialLoginScreen());
                                                    }
                                                  }
                                                  break;
                                                default:
                                                  break;
                                              }
                                              banSystem.updateSumOfCounters(
                                                  loggedID!, sum);
                                              sendMessage(context, true);
                                              messageController.clear();
                                              if (sum >= 5) {
                                                banSystem.updateUserNumOfBans(
                                                    loggedID!,
                                                    currentUser.numberOfBans! +
                                                        1);
                                                banSystem.tempBan(
                                                    loggedID!, true);
                                                banSystem.updateSumOfCounters(
                                                    loggedID!, 0);
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Please enter some text or select an image.')),
                                              );
                                            }
                                          } else {
                                            if (url1 != null) {
                                              sendMessage(context, false);
                                              messageController.clear();
                                              // Scroll to the last message
                                              //0scrollDown();
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Please enter some text or select an image.')),
                                              );
                                            }
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Due to inappropriate behavior you are banned from sending messages')),
                                          );
                                        }
                                      }
                                    },
                                    icon: is_record
                                        ? const Icon(
                                            Icons.stop,
                                            color: defaultColor,
                                          )
                                        : const Icon(
                                            Icons.mic,
                                            color: defaultColor,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                SizedBox(
                                  height: 50.0,
                                  child: MaterialButton(
                                    onPressed: () async {
                                      currentUser =
                                          (await SocialCubit.get(context)
                                              .getCurrentUserData(loggedID!))!;
                                      sum = currentUser.sumOfCounters!;

                                      queryText = await fetchData(
                                          messageController.text.trim());
                                      if (currentUser.isBanned == false) {
                                        if (queryText != 'not_cyberbullying') {
                                          if (messageController
                                              .text.isNotEmpty) {
                                            switch (queryText) {
                                              case 'age':
                                                banSystem.updateUserCounter(
                                                    loggedID!,
                                                    CounterType.age,
                                                    currentUser.ageCounter! +
                                                        1);
                                                sum += 1;
                                                currentUser =
                                                    (await SocialCubit.get(
                                                            context)
                                                        .getCurrentUserData(
                                                            loggedID!))!;
                                                if (currentUser.ageCounter ==
                                                    3) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Due to inappropriate behavior you are banned from sending messages')),
                                                  );
                                                  banSystem.tempBan(
                                                      loggedID!, true);
                                                  banSystem.updateUserNumOfBans(
                                                      loggedID!,
                                                      currentUser
                                                              .numberOfBans! +
                                                          1);
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.age,
                                                      0);
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .numberOfBans! >=
                                                      5) {
                                                    banSystem.updateUserState(
                                                        loggedID!, true);
                                                    banSystem
                                                        .userLogout(context);
                                                    navigateAndfFinish(context,
                                                        SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              case 'religion':
                                                banSystem.updateUserCounter(
                                                    loggedID!,
                                                    CounterType.religion,
                                                    currentUser
                                                            .religionCounter! +
                                                        1);
                                                sum += 1;
                                                currentUser =
                                                    (await SocialCubit.get(
                                                            context)
                                                        .getCurrentUserData(
                                                            loggedID!))!;
                                                if (currentUser
                                                        .religionCounter ==
                                                    2) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Due to inappropriate behavior you are banned from sending messages')),
                                                  );
                                                  banSystem.tempBan(
                                                      loggedID!, true);
                                                  banSystem.updateUserNumOfBans(
                                                      loggedID!,
                                                      currentUser
                                                              .numberOfBans! +
                                                          1);
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.religion,
                                                      0);
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .numberOfBans! >=
                                                      5) {
                                                    banSystem.updateUserState(
                                                        loggedID!, true);
                                                    banSystem
                                                        .userLogout(context);
                                                    navigateAndfFinish(context,
                                                        SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              case 'ethnicity':
                                                banSystem.updateUserCounter(
                                                    loggedID!,
                                                    CounterType.ethnicity,
                                                    currentUser
                                                            .ethnicityCounter! +
                                                        1);
                                                sum += 1;
                                                currentUser =
                                                    (await SocialCubit.get(
                                                            context)
                                                        .getCurrentUserData(
                                                            loggedID!))!;
                                                if (currentUser
                                                        .ethnicityCounter ==
                                                    4) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Due to inappropriate behavior you are banned from sending messages')),
                                                  );
                                                  banSystem.tempBan(
                                                      loggedID!, true);
                                                  banSystem.updateUserNumOfBans(
                                                      loggedID!,
                                                      currentUser
                                                              .numberOfBans! +
                                                          1);
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.ethnicity,
                                                      0);
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .numberOfBans! >=
                                                      5) {
                                                    banSystem.updateUserState(
                                                        loggedID!, true);
                                                    banSystem
                                                        .userLogout(context);
                                                    navigateAndfFinish(context,
                                                        SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              case 'gender':
                                                banSystem.updateUserCounter(
                                                    loggedID!,
                                                    CounterType.gender,
                                                    currentUser.genderCounter! +
                                                        1);
                                                sum += 1;
                                                currentUser =
                                                    (await SocialCubit.get(
                                                            context)
                                                        .getCurrentUserData(
                                                            loggedID!))!;
                                                if (currentUser.genderCounter ==
                                                    6) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Due to inappropriate behavior you are banned from sending messages')),
                                                  );
                                                  banSystem.tempBan(
                                                      loggedID!, true);
                                                  banSystem.updateUserNumOfBans(
                                                      loggedID!,
                                                      currentUser
                                                              .numberOfBans! +
                                                          1);
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.gender,
                                                      0);
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .numberOfBans! >=
                                                      5) {
                                                    banSystem.updateUserState(
                                                        loggedID!, true);
                                                    banSystem
                                                        .userLogout(context);
                                                    navigateAndfFinish(context,
                                                        SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              case 'other_cyberbullying':
                                                banSystem.updateUserCounter(
                                                    loggedID!,
                                                    CounterType.other,
                                                    currentUser.otherCounter! +
                                                        1);
                                                sum += 1;
                                                currentUser =
                                                    (await SocialCubit.get(
                                                            context)
                                                        .getCurrentUserData(
                                                            loggedID!))!;
                                                if (currentUser.otherCounter == 5)
                                                {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Due to inappropriate behavior you are banned from sending messages')),
                                                  );
                                                }
                                                if (currentUser.otherCounter ==
                                                    6) {
                                                  banSystem.tempBan(
                                                      loggedID!, true);
                                                  banSystem.updateUserNumOfBans(
                                                      loggedID!,
                                                      currentUser
                                                              .numberOfBans! +
                                                          1);
                                                  banSystem.updateUserCounter(
                                                      loggedID!,
                                                      CounterType.other,
                                                      0);
                                                  currentUser =
                                                      (await SocialCubit.get(
                                                              context)
                                                          .getCurrentUserData(
                                                              loggedID!))!;
                                                  if (currentUser
                                                          .numberOfBans! >
                                                      1) {
                                                    banSystem.updateUserState(
                                                        loggedID!, true);
                                                    banSystem
                                                        .userLogout(context);
                                                    navigateAndfFinish(context,
                                                        SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              default:
                                                break;
                                            }
                                            banSystem.updateSumOfCounters(
                                                loggedID!, sum);
                                            SocialCubit.get(context)
                                                .sendMessage(
                                              receiverId:
                                                  widget.userModel!.uId!,
                                              dateTime:
                                                  DateTime.now().toString(),
                                              text: messageController.text,
                                              image: messageImg ?? '',
                                              audio: url1 ?? '',
                                              warning: true,
                                            );
                                            messageController.clear();
                                            messageImg = null;
                                            url1 = null;
                                            if (sum >= 5) {
                                              banSystem.updateUserNumOfBans(
                                                  loggedID!,
                                                  currentUser.numberOfBans! +
                                                      1);
                                              banSystem.tempBan(
                                                  loggedID!, true);
                                              banSystem.updateSumOfCounters(
                                                  loggedID!, 0);
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please enter some text or select an image.')),
                                            );
                                          }
                                        } else {
                                          if (messageController
                                              .text.isNotEmpty) {
                                            SocialCubit.get(context)
                                                .sendMessage(
                                              receiverId:
                                                  widget.userModel!.uId!,
                                              dateTime:
                                                  DateTime.now().toString(),
                                              text: messageController.text,
                                              image: messageImg ?? '',
                                              audio: url1 ?? '',
                                              warning: false,

                                            );
                                            messageController.clear();
                                            messageImg = null;
                                            url1 = null;
                                            // Scroll to the last message
                                            //0scrollDown();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please enter some text or select an image.')),
                                            );
                                          }
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Due to inappropriate behavior you are banned from sending messages')),
                                        );
                                      }
                                    },
                                    minWidth: 1.0,
                                    color: defaultColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: const Icon(
                                      IconBroken.Send,
                                      size: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //GoToBottomButton(scrollController: _scrollController),
                      if (SocialCubit.get(context).messages.isEmpty)
                        const Positioned(
                          bottom: 80.0,
                          left: 10.0,
                          child: SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: defaultColor,
                            ),
                          ),
                        ),
                      if (SocialCubit.get(context).state
                          is SocialSendMessageErrorState)
                        const Positioned(
                          bottom: 80.0,
                          left: 10.0,
                          child: SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: defaultColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildWarningMessage(String warningText) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(10.0),
            topStart: Radius.circular(10.0),
            topEnd: Radius.circular(10.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              warningText,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget? buildMessage(MessageModel? model, BuildContext context) {
    if (model!.text == '') {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Image'),
                  ),
                  body: Center(
                    child: Hero(
                      tag: 'image${model.image}',
                      child: Image.network(model.image!),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Hero(
            tag: 'image${model.image}',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(
                    10.0,
                  ),
                  topStart: Radius.circular(
                    10.0,
                  ),
                  topEnd: Radius.circular(
                    10.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: Image.network(
                model.image!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(
              10.0,
            ),
            topStart: Radius.circular(
              10.0,
            ),
            topEnd: Radius.circular(
              10.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Text('${model.text}'),
      ),
    );
  }
  // Widget buildVoiceMessage(
  //     MessageModel? model, BuildContext context, bool isSender) {
  //   print("model!.isPlaying123: ${model!.isPlaying}");
  //   return Align(
  //     alignment: isSender
  //         ? AlignmentDirectional.centerEnd
  //         : AlignmentDirectional.centerStart,
  //     child: Container(
  //       padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 3),
  //       margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
  //       decoration: BoxDecoration(
  //         color: defaultColor.withOpacity(0.2), // Adjust opacity value here
  //         borderRadius: const BorderRadiusDirectional.only(
  //           bottomEnd: Radius.circular(
  //             10.0,
  //           ),
  //           topStart: Radius.circular(
  //             10.0,
  //           ),
  //           topEnd: Radius.circular(
  //             10.0,
  //           ),
  //         ),
  //       ),
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           children: [
  //             IconButton(
  //               // onPressed: isPlaying ? pauseRecording : playRecording,
  //               onPressed: () async {
  //                 if (url1 != null) {
  //                   await pauseRecording(model.player!);
  //                   if (url1 == model.audio) {
  //                     url1 = null;
  //                     return;
  //                   }
  //                 }
  //                 url1 = model.audio!;
  //                 await playRecording(model.player!);
  //                 model.player!.onPositionChanged.listen((event) {
  //                   setState(() {
  //                     model.position = event;
  //                   });
  //                 });
  //                 model.player!.onDurationChanged.listen((event) {
  //                   setState(() {
  //                     model.duration = event;
  //                   });
  //                 });
  //               },
  //               color: defaultColor,
  //               icon: (model.audio == url1)
  //                   ? const Icon(Icons.pause)
  //                   : const Icon(Icons.play_arrow),
  //             ),
  //             Slider(
  //               min: 0,
  //               max: model.duration!.inSeconds.toDouble(),
  //               value: model.position!.inSeconds
  //                   .toDouble(),
  //               // .clamp(0.0, model.duration!.inMilliseconds.toDouble()),
  //               onChanged: (value) {
  //                 print("valueee: $value");
  //                 model.player!.seek(Duration(milliseconds: value.toInt()));
  //                 model.player!.resume();
  //               },
  //               activeColor: defaultColor,
  //               thumbColor: defaultColor,
  //             ),
  //             Text(formatTime((model.duration! - model.position!).inSeconds)),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget buildVoiceMessage(
      MessageModel? model, BuildContext context, bool isSender) {
    print("model!.isPlaying123: ${model!.isPlaying}");
    return
      // ConditionalBuilder(
      //   condition: recordFlag == true,
      //   builder: (context) =>
      Align(
      alignment: isSender
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 3),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        decoration: BoxDecoration(
          color:isSender ? defaultColor.withOpacity(0.2) : Colors.grey[300], // Adjust opacity value here
          borderRadius: const BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(
              10.0,
            ),
            topStart: Radius.circular(
              10.0,
            ),
            topEnd: Radius.circular(
              10.0,
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:
          // VoiceListView(
          //     url: model.audio!,
          //     isSender: isSender)
          Row(
            children: [
              IconButton(
                // onPressed: isPlaying ? pauseRecording : playRecording,
                onPressed: () async {
                  if (url1 != null) {
                    await pauseRecording(model.player!);
                    if (url1 == model.audio) {
                      url1 = null;
                      return;
                    }
                  }
                  url1 = model.audio!;
                  await playRecording(model.player!);
                  print('???????????>>>>>>>>>>${model.duration!}');
                  print('???????????>>>>>>>>>>${model.position!}');
                  model.player!.onPositionChanged.listen((event) {
                    setState(() {
                      model.position = event;
                    });
                  });
                  model.player!.onPlayerComplete.listen((event) {
                    setState(() {
                      model.duration = Duration.zero;
                      url1 = null;
                      model.position = Duration.zero;
                      model.player!.seek(model.position!);
                    });
                  });
                  model.player!.onDurationChanged.listen((event) {
                    setState(() {
                      model.duration = event;
                    });
                  });
                },
                color: isSender ? defaultColor : Colors.grey[600],
                icon: (model.audio == url1)
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
              ),
              Slider(
                min: 0,
                max: model.duration!.inSeconds.toDouble(),
                value: model.position!.inSeconds.toDouble(),
                onChanged: (value) {
                  print("valueee: $value");
                  print('Durationnnnnnnnnn:');
                  print(model.duration!.inSeconds.toDouble());
                  print('positionnnnnnnnnnnn:');
                  print(model.position!.inSeconds.toDouble());
                  print('format-timeeeeeeeeeeeeeeeeeeeee:');
                  print(formatTime((model.duration! - model.position!).inSeconds));
                  // model.player!.seek(Duration(seconds: value.toInt()));
                  // model.player!.resume();
                },
                activeColor:isSender ? defaultColor : Colors.grey[600],
                thumbColor: isSender ? defaultColor : Colors.grey[600],
              ),
              Text(formatDuration(model.position!)),
            ],
          ),
        ),
      ),
    );
    //   fallback: (context) => const Center(child: CircularProgressIndicator()),
    // );
  }

  Widget buildMyMessage(MessageModel? model, BuildContext context) {
    if (model!.text == '') {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    iconTheme: const IconThemeData(
                      color: Colors.black,
                    ),
                    elevation: 0.0,
                    title: const Text(
                      'Image',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  body: Center(
                    child: Hero(
                      tag: 'image${model.image}',
                      child: Image.network(model.image!),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Hero(
            tag: 'image${model.image}',
            child: Container(
              decoration: BoxDecoration(
                color: defaultColor.withOpacity(
                  0.2,
                ),
                borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(
                    10.0,
                  ),
                  topStart: Radius.circular(
                    10.0,
                  ),
                  topEnd: Radius.circular(
                    10.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: Image.network(
                model.image!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        decoration: BoxDecoration(
          color: defaultColor.withOpacity(
            0.2,
          ),
          borderRadius: const BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(
              10.0,
            ),
            topStart: Radius.circular(
              10.0,
            ),
            topEnd: Radius.circular(
              10.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Text(model.text!),
      ),
    );
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void navigateToProfileScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileView(
          userModel: widget.userModel,
        ),
      ),
    );
  }
}