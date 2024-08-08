import 'dart:async';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/layout/social_app/cubit/states.dart';
import 'package:Chatty/modules/social_app/chat_details/ban_systen.dart';
import 'package:Chatty/modules/social_app/chat_details/chat_details_screen.dart';
import 'package:Chatty/shared/components/components.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:Chatty/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/social_app/social_user_model.dart';
import '../social_login/social_login_screen.dart';

class ImageUploaded extends StatelessWidget {
  SocialUserModel? userModel;
  late SocialUserModel currentUser;
  var url;
  var queryText;
  int sum = 0;
  String? message1 = '';
  ImageUploaded({super.key,this.userModel,});
  var messageController = TextEditingController();
  BanSystem banSystem = BanSystem();

  Future<String> predictimage(String imageUrl) async {
    final endpointUrl = 'http://192.168.1.9:5000/image?imageUrl=$imageUrl';

    final response = await http.get(Uri.parse(endpointUrl));
    if (response.statusCode == 200) {
      final result = json.decode(response.body)['prediction'];
      return result;
    } else {
      throw Exception('Failed to load prediction');
    }
  }
  @override
  Widget build(BuildContext context) {
    SocialCubit.get(context).getMessages(receiverId: userModel!.uId!,);
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Theme(
            data:  ThemeData(
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
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.white, // Set color of navigation bar
                systemNavigationBarIconBrightness: Brightness.dark, // Set brightness of navigation bar icons
              ),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text(
                    'Image',
                  ),
                ),
                body: ConditionalBuilder(
                  condition: state is SocialUploadMessageImageSuccessState && messageImg != '',
                  builder: (context) => Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              borderOnForeground: true,
                              child: Image.network(
                                messageImg ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: () async {
                            currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                            sum = currentUser.sumOfCounters!;
                            final encodedUrl = Uri.encodeComponent(messageImg!);
                            queryText = await predictimage(encodedUrl);
                            if (currentUser.isBanned == false)
                            {
                              if (queryText != 'not_cyberbullying') {
                                if (messageImg != null) {
                                  switch (queryText) {
                                    case 'age':
                                      banSystem.updateUserCounter(loggedID!, CounterType.age, currentUser.ageCounter! + 1);
                                      sum += 1;
                                      currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                      if (currentUser.ageCounter == 3)
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Due to inappropriate behavior you are banned from sending messages')),
                                        );
                                        banSystem.tempBan(loggedID!, true);
                                        banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                        banSystem.updateUserCounter(loggedID!, CounterType.age, 0);
                                        currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                        if (currentUser.numberOfBans! >= 5)
                                        {
                                          banSystem.updateUserState(loggedID!, true);
                                          banSystem.userLogout(context);
                                          navigateAndfFinish(context, SocialLoginScreen());
                                        }
                                      }
                                      break;
                                    case 'religion':
                                      banSystem.updateUserCounter(loggedID!, CounterType.religion, currentUser.religionCounter! + 1);
                                      sum += 1;
                                      currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                      if (currentUser.religionCounter == 2)
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Due to inappropriate behavior you are banned from sending messages')),
                                        );
                                        banSystem.tempBan(loggedID!, true);
                                        banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                        banSystem.updateUserCounter(loggedID!, CounterType.religion, 0);
                                        currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                        if (currentUser.numberOfBans! >= 5)
                                        {
                                          banSystem.updateUserState(loggedID!, true);
                                          banSystem.userLogout(context);
                                          navigateAndfFinish(context, SocialLoginScreen());
                                        }

                                      }
                                      break;
                                    case 'ethnicity':
                                      banSystem.updateUserCounter(loggedID!, CounterType.ethnicity, currentUser.ethnicityCounter! + 1);
                                      sum += 1;
                                      currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                      if (currentUser.ethnicityCounter == 4)
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Due to inappropriate behavior you are banned from sending messages')),
                                        );
                                        banSystem.tempBan(loggedID!, true);
                                        banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                        banSystem.updateUserCounter(loggedID!, CounterType.ethnicity, 0);
                                        currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                        if (currentUser.numberOfBans! >= 5)
                                        {
                                          banSystem.updateUserState(loggedID!, true);
                                          banSystem.userLogout(context);
                                          navigateAndfFinish(context, SocialLoginScreen());
                                        }
                                      }
                                      break;
                                    case 'gender':
                                      banSystem.updateUserCounter(loggedID!, CounterType.gender, currentUser.genderCounter! + 1);
                                      sum += 1;
                                      currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                      if (currentUser.genderCounter == 6)
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Due to inappropriate behavior you are banned from sending messages')),
                                        );
                                        banSystem.tempBan(loggedID!, true);
                                        banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                        banSystem.updateUserCounter(loggedID!, CounterType.gender, 0);
                                        currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                        if (currentUser.numberOfBans! >= 5)
                                        {
                                          banSystem.updateUserState(loggedID!, true);
                                          banSystem.userLogout(context);
                                          navigateAndfFinish(context, SocialLoginScreen());
                                        }
                                      }
                                      break;
                                    case 'other_cyberbullying':
                                      banSystem.updateUserCounter(loggedID!, CounterType.other, currentUser.otherCounter! + 1);
                                      sum += 1;
                                      currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                      if (currentUser.otherCounter == 5)
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Due to inappropriate behavior you are banned from sending messages')),
                                        );
                                      }
                                      if (currentUser.otherCounter == 6)
                                      {
                                        banSystem.tempBan(loggedID!, true);
                                        banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                        banSystem.updateUserCounter(loggedID!, CounterType.other, 0);
                                        currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                        if (currentUser.numberOfBans! > 1)
                                        {
                                          banSystem.updateUserState(loggedID!, true);
                                          banSystem.userLogout(context);
                                          navigateAndfFinish(context, SocialLoginScreen());
                                        }
                                      }
                                      break;
                                    default:
                                      break;
                                  }
                                  banSystem.updateSumOfCounters(loggedID!, sum);
                                  SocialCubit.get(context)
                                      .sendMessage(
                                    receiverId: userModel!.uId!,
                                    dateTime: DateTime.now()
                                        .toString(),
                                    text: messageController.text,
                                    image: messageImg ?? '',
                                    audio: url1 ?? '',
                                    warning: true,
                                  );
                                  messageController.clear();
                                  messageImg = null;
                                  if (sum >= 5)
                                  {
                                    banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                    banSystem.tempBan(loggedID!, true);
                                    banSystem.updateSumOfCounters(loggedID!, 0);
                                  }
                                  // Scroll to the last message
                                  //scrollDown();
                                }
                                else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(content: Text(
                                        'Please enter some text or select an image.')),
                                  );
                                }
                              }
                              else {
                                if (messageImg != null) {
                                  SocialCubit.get(context)
                                      .sendMessage(
                                    receiverId: userModel!.uId!,
                                    dateTime: DateTime.now()
                                        .toString(),
                                    text: messageController.text,
                                    image: messageImg ?? '',
                                    audio: url1 ?? '',
                                    warning: false,
                                  );
                                  messageController.clear();
                                  messageImg = null;
                                  // Scroll to the last message
                                  //0scrollDown();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(content: Text(
                                        'Please enter some text or select an image.')),
                                  );
                                }
                              }
                              Navigator.pop(context);
                            }
                            else
                            {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(content: Text(
                                    'Due to inappropriate behavior you are banned from sending messages')),
                              );
                            }
                          },
                          child: const Icon(IconBroken.Send),
                        ),
                      ),
                    ],
                  ),
                  fallback: (context) => const Center(child: CircularProgressIndicator()),
                ),
              ),
            ));
      },
    );
  }
}

// final encodedUrl = Uri.encodeComponent(messageImg!);
// imageLabel = await predictimage(encodedUrl);