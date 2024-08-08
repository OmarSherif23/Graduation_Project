import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:Chatty/modules/social_app/social_login/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class SocialLoginCubit extends Cubit<SocialLoginStates>
{
  SocialLoginCubit() : super(SocialLoginInitialState());

  static SocialLoginCubit get(context) => BlocProvider.of(context);


  void userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) {
    SocialCubit.get(context).clearUserModel();

    emit(SocialLoginLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      print(value.user!.email);
      print(value.user!.uid);
      loggedID = value.user!.uid;
      SocialCubit.get(context).getUserData();

      // Check if the user is banned
      FirebaseFirestore.instance
          .collection('users')
          .doc(loggedID)
          .get()
          .then((doc) {
        if (doc.exists) {
          var isBanned = doc.get('isBanned');
          if (isBanned == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('You are banned from logging in.'),
            ));
            emit(SocialLoginErrorState('User is banned.'));
          } else {
            emit(SocialLoginSuccessState(value.user!.uid));
          }
        }
      }).catchError((error) {
        emit(SocialLoginErrorState(error.toString()));
      });
    }).catchError((error) {
      emit(SocialLoginErrorState(error.toString()));
    });
  }





  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;
  void changePasswordVisibilty(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined ;
    emit(SocialChangePasswordVisibilityState());
  }

}