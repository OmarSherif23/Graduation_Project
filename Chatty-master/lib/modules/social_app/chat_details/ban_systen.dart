 import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../layout/social_app/cubit/cubit.dart';
import '../../../shared/network/local/chache_helper.dart';
import '../social_login/social_login_screen.dart';
import 'chat_details_screen.dart';

class BanSystem{
  Future<void> userLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    CacheHelper.removeData(key: 'uId');
    await FirebaseAuth.instance.authStateChanges().firstWhere((user) => user == null);
    SocialCubit.get(context).clearUserModel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SocialLoginScreen()),
    );
  }

  Future<void> tempBan(String userId,bool value) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      Map<String, dynamic> updateData = {
        'isBanned': value,
        'banEndTime': value ? DateTime.now().add(const Duration(seconds: 7)) : null, // set ban end time to 3 hours from now if user is banned
      };
      await docRef.update(updateData);
      print('state updated successfully for user $userId');
      if (value) {
        Timer(const Duration(seconds: 7), () {
          docRef.update({
            'isBanned': false,
            'banEndTime': null,
          });
          print('ban lifted for user $userId');
        });
      } else {
        docRef.update({'banEndTime': null}); // remove ban end time if user is not banned
      }
    } catch (e) {
      print('Error updating state for user $userId: $e');
    }
  }

  Future<void> updateSumOfCounters(String userId,int value) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await docRef.update({
        'sumOfCounters': value,
      });
      print('numberOfBans updated successfully for user $userId');
    } catch (e) {
      print('Error updating numberOfBans for user $userId: $e');
    }
  }

  Future<void> updateUserNumOfBans(String userId,int value) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await docRef.update({
        'numberOfBans': value,
      });
      print('numberOfBans updated successfully for user $userId');
    } catch (e) {
      print('Error updating numberOfBans for user $userId: $e');
    }
  }

  Future<void> updateUserState(String userId,bool value) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await docRef.update({
        'isBanned': value,
      });
      print('state updated successfully for user $userId');
    } catch (e) {
      print('Error updating state for user $userId: $e');
    }
  }

  Future<void> updateUserCounter(String userId, CounterType counterType, int amount) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      String counterField;
      switch (counterType) {
        case CounterType.age:
          counterField = 'ageCounter';
          break;
        case CounterType.religion:
          counterField = 'religionCounter';
          break;
        case CounterType.gender:
          counterField = 'genderCounter';
          break;
        case CounterType.ethnicity:
          counterField = 'ethnicityCounter';
          break;
        case CounterType.other:
          counterField = 'otherCounter';
          break;
      }
      await docRef.update({
        counterField: amount,
      });
      print('Counter updated successfully for user $userId');
    } catch (e) {
      print('Error updating counter for user $userId: $e');
    }
  }
}