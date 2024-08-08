import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Chatty/models/social_app/social_user_model.dart';
import 'package:Chatty/modules/social_app/social_register/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/components/constants.dart';

class SocialRegisterCubit extends Cubit<SocialRegisterStates>
{
  SocialRegisterCubit() : super(SocialRegisterInitialState());

  static SocialRegisterCubit get(context) => BlocProvider.of(context);
  void userRegister({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    emit(SocialRegisterLoadingState());

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification to the user
      await userCredential.user!.sendEmailVerification();

      userCreate(
        uId: userCredential.user!.uid,
        phone: phone,
        email: email,
        name: name,
      );

      emit(SocialCreateUserSuccessState());
    } catch (error) {
      print(error.toString());
      emit(SocialRegisterErrorState(error.toString()));
    }
  }


  void userCreate({
    required String name,
    required String email,
    required String phone,
    required String uId,

  })
  {
      socialUserModel = SocialUserModel(
        name: name,
        email: email,
        phone: phone,
        uId: uId,
        bio: '',
        cover: 'https://img.freepik.com/free-photo/close-up-young-successful-man-smiling-camera-standing-casual-outfit-against-blue-background_1258-66609.jpg?w=996&t=st=1676499092~exp=1676499692~hmac=5d4f12cb876a133d021d0e08eb9d60cdd7daec9eff61f1cae0507775392e8689',
        image: 'https://img.freepik.com/free-photo/close-up-young-successful-man-smiling-camera-standing-casual-outfit-against-blue-background_1258-66609.jpg?w=996&t=st=1676499092~exp=1676499692~hmac=5d4f12cb876a133d021d0e08eb9d60cdd7daec9eff61f1cae0507775392e8689',
        isEmailVerified: false,
        isBanned: false,
        ageCounter: 0,
        religionCounter: 0,
        otherCounter: 0,
        genderCounter: 0,
        ethnicityCounter: 0,
      );

    FirebaseFirestore.instance.collection('users').doc(uId).set(  socialUserModel.toMap())
        .then(
            (value)
        {
          loggedID = uId;
          emit(SocialCreateUserSuccessState());
        })
        .catchError((error)
        {
          emit(SocialCreateUserErrorState(error.toString()));
        });
  }



  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;
  void changePasswordVisibility(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined ;
    emit(SocialRegisterChangePasswordVisibilityState());
  }

}