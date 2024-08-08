import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Chatty/layout/social_app/cubit/states.dart';
import 'package:Chatty/models/social_app/message_model.dart';
import 'package:Chatty/models/social_app/social_user_model.dart';
import 'package:Chatty/modules/social_app/chats/chats_screen.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../../modules/social_app/myprofile/settings_screen.dart';

class SocialCubit extends Cubit<SocialStates>{
  SocialCubit() : super(SocialInitialState());

  static SocialCubit get(context) => BlocProvider.of(context);
  SocialUserModel userModel = socialUserModel;


  // LOG OUT DEPENDENT
  void clearUserModel() {
    socialUserModel.uId='';
    socialUserModel.cover='';
    socialUserModel.image='';
    socialUserModel.email='';
    socialUserModel.name='';
    socialUserModel.phone='';
    socialUserModel.interests?.clear();
  }



  Future<SocialUserModel?> getCurrentUserData(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final userData = SocialUserModel.fromJson(docSnapshot.data()!);
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user data for ID $userId: $e');
      return null;
    }
  }


  void getUserData(){
    emit(SocialGetUserLoadingState());

    FirebaseFirestore.instance.collection('users').doc(loggedID).get()
        .then((value) {
          userModel = SocialUserModel.fromJson(value.data()!);
          emit(SocialGetUserSuccessState());
    })
        .catchError((error){
          print(error.toString());
          emit(SocialGetUserErrorState(error.toString()));
    });
  }

  bool isWarning = false;
  int currentIndex = 0;
  List<Widget> Screens = [
    ChatsScreen(),
    MyProfileScreen(),
  ];
  List<String> titles = [
    'Chats',
    'Profile',
  ];

  void changeWarningVariable(bool val)
  {
    isWarning = !val;
  }

  void changeBottomNav(int index){

    currentIndex = index;

    emit(SocialChangeBottomNavState());
  }

  File? profileImage;
  var picker =ImagePicker();

  Future<void> getProfileImage() async
  {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if(pickedFile != null){
      profileImage = File(pickedFile.path);
      print(pickedFile.path);
      emit(SocialProfilePickedImageSuccessState());
    }
    else{
      print('No image selected');
      emit(SocialProfilePickedImageErrorState());
    }
  }


  File? messageImage;
  Future<void> getMessageImage() async
  {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if(pickedFile != null){
      messageImage = File(pickedFile.path);
      uploadMessageImage();
      // emit(SocialMessagePickedImageSuccessState());
    }
    else{
      print('No image selected');
      //emit(SocialMessagePickedImageErrorState());
    }

  }


  File? coverImage;
  Future<void> getCoverImage() async
  {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if(pickedFile != null){
      coverImage = File(pickedFile.path);
      emit(SocialCoverPickedImageSuccessState());
    }
    else{
      print('No image selected');
      emit(SocialCoverPickedImageErrorState());
    }
  }



  void uploadMessageImage()
  {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(messageImage!.path).pathSegments.last}')
        .putFile(messageImage!)
        .then((value){
      value.ref.getDownloadURL().then((value)
      {
        print(value.toString());
        messageImg = value;
        print(messageImg);
        emit(SocialUploadMessageImageSuccessState());
      }).catchError((error){
        emit(SocialUploadMessageImageErrorState());
      });
    }).catchError((error){
      emit(SocialUploadMessageImageErrorState());
    });
  }
  void uploadProfileImage({
    required String name,
    required String phone,
    required String bio,
  }) {
    emit(SocialUserUpdateLoadingState());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        updateUser(
          name: name,
          phone: phone,
          bio: bio,
          image: value,
          // Pass the existing values of the fields that you're not updating
          cover: userModel.cover,
          genderCounter: userModel.genderCounter,
          otherCounter: userModel.otherCounter,
          religionCounter: userModel.religionCounter,
          ageCounter: userModel.ageCounter,
          ethnicityCounter: userModel.ethnicityCounter,
          isBanned: userModel.isBanned,
          interests: userModel.interests, // Pass existing interests

        );
      }).catchError((error) {
        emit(SocialUploadProfileImageErrorState());
      });
    }).catchError((error) {
      emit(SocialUploadProfileImageErrorState());
    });
  }

  void uploadCoverImage({
    required String name,
    required String phone,
    required String bio,
  }) {
    emit(SocialUserUpdateLoadingState());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(coverImage!.path).pathSegments.last}')
        .putFile(coverImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        updateUser(
          name: name,
          phone: phone,
          bio: bio,
          cover: value,
          // Pass the existing values of the fields that you're not updating
          image: userModel.image,
          genderCounter: userModel.genderCounter,
          otherCounter: userModel.otherCounter,
          religionCounter: userModel.religionCounter,
          ageCounter: userModel.ageCounter,
          ethnicityCounter: userModel.ethnicityCounter,
          isBanned: userModel.isBanned,
          interests: userModel.interests, // Pass existing interests

        );
      }).catchError((error) {
        emit(SocialUploadCoverImageErrorState());
      });
    }).catchError((error) {
      emit(SocialUploadCoverImageErrorState());
    });
  }

  void updateUser({
    String? name,
    String? phone,
    String? bio,
    int? genderCounter,
    int? otherCounter,
    int? religionCounter,
    int? ageCounter,
    int? ethnicityCounter,
    String? cover,
    String? image,
    bool? isBanned,
    List<String>? interests,
  }) {
    emit(SocialUserUpdateLoadingState());
    SocialUserModel model = SocialUserModel(
      name: name ?? userModel.name,
      email: userModel.email,
      uId: userModel.uId,
      phone: phone ?? userModel.phone,
      bio: bio ?? userModel.bio,
      image: image ?? userModel.image,
      cover: cover ?? userModel.cover,
      isEmailVerified: false,
      genderCounter: genderCounter ?? userModel.genderCounter,
      religionCounter: religionCounter ?? userModel.religionCounter,
      otherCounter: otherCounter ?? userModel.otherCounter,
      ageCounter: ageCounter ?? userModel.ageCounter,
      ethnicityCounter: ethnicityCounter ?? userModel.ethnicityCounter,
      isBanned: isBanned ?? userModel.isBanned,
      interests: interests ?? userModel.interests, // Preserve existing interests
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.uId)
        .update(model.toMap())
        .then((value) {
      getUserData();
    }).catchError((error) {
      emit(SocialUserUpdateErrorState());
    });
  }
  List<SocialUserModel> users = [];

  void getUsers ()
  {

    FirebaseFirestore.instance.collection('users').get().then((value) {
      for (var element in value.docs) {
        if(element.data()['uId'] != userModel.uId) {
          users.add(SocialUserModel.fromJson(element.data()));
        }
      }
      emit(SocialGetAllUsersSuccessState());
    }).catchError((error){
      print(error.toString());
      emit(SocialGetAllUsersErrorState(error.toString()));
    });
  }

  void sendMessage({
    required String receiverId,
    required String dateTime,
    required String text,
    required String image,
    required String audio,
    required bool warning
  })
  {
    MessageModel model = MessageModel(
      receiverId: receiverId,
      senderId: userModel.uId,
      dateTime: dateTime,
      text: text,
      image: image,
      audio: audio,
      isBullying: warning,
    );
    FirebaseFirestore.instance
    .collection('users')
    .doc(userModel.uId)
    .collection('chats')
    .doc(receiverId)
    .collection('messages')
    .add(model.toMap())
    .then((value){
      emit(SocialSendMessageSuccessState());
    })
    .catchError((error){
      emit(SocialSendMessageErrorState());
    });


    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel.uId)
        .collection('messages')
        .add(model.toMap())
        .then((value){
      emit(SocialSendMessageSuccessState());
    })
        .catchError((error){
      emit(SocialSendMessageErrorState());
    });


  }

  List<MessageModel> messages = [];

  void getMessages({
    required String receiverId,
    }){
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
    .orderBy('dateTime')
        .snapshots()
        .listen((event) {
          messages = [];
          for (var element in event.docs) {
            messages.add(MessageModel.fromJson(element.data()));
          }
          emit(SocialGetMessagesSuccessState());
    });
  }





}