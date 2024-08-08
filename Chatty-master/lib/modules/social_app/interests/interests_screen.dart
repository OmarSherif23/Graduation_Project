import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/modules/social_app/social_login/cubit/cubit.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../layout/social_app/social_layout.dart';
import '../../../models/social_app/social_user_model.dart';
import '../../../shared/components/components.dart';
import '../../../shared/network/local/chache_helper.dart';

class ChooseInterestsScreen extends StatefulWidget {
  final String email;
  final String password;
  const ChooseInterestsScreen({super.key, required this.email, required this.password});

  @override
  _ChooseInterestsScreenState createState() => _ChooseInterestsScreenState();
}

class _ChooseInterestsScreenState extends State<ChooseInterestsScreen> {
  List<String> interests = [
    'Sports',
    'Music',
    'Travel',
    'Art',
    'Technology',
    'Food',
    'Fashion',
    'Movies',
  ];
  List<String> selectedInterests = [];

  Map<String, IconData> interestIcons = {
    'Sports': Icons.sports,
    'Music': Icons.music_note,
    'Travel': Icons.flight,
    'Art': Icons.palette,
    'Technology': Icons.computer,
    'Food': Icons.restaurant,
    'Fashion': Icons.shopping_bag,
    'Movies': Icons.movie,
  };

  bool isButtonPressed = false;

  Future<void> updateUserInterests(String userId, List<String> interests) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the current user data
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final userData = SocialUserModel.fromJson(docSnapshot.data()!);

        // Update the interests field with the selected interests
        userData.interests = interests;

        // Update the user document in Firebase
        await docRef.set(userData.toMap());
      }
    } catch (e) {
      print('Error updating user interests for ID $userId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: isButtonPressed ? Colors.blue : Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Topics'),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pick topics to chat with people with similar interests :',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  childAspectRatio: 2, // Width to height ratio of each item
                ),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  final isSelected = selectedInterests.contains(interest);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedInterests.remove(interest);
                        } else {
                          selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        border: Border.all(color: Colors.black), // Add black border
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            interestIcons[interest],
                            color: isSelected ? Colors.white : Colors.black,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Call the function to update user interests
              await updateUserInterests(loggedID!, selectedInterests);
              SocialLoginCubit socialLoginCubit = SocialLoginCubit();
              socialLoginCubit.userLogin(email: widget.email, password: widget.password, context: context);
              socialUserModel =(await  SocialCubit.get(context).getCurrentUserData(loggedID!))!;
              CacheHelper.saveData(
                key: 'uId',
                value: loggedID,
              ).then(
                      (value){
                    navigateAndfFinish(
                      context,
                      const SocialLayout(),
                    );
                  });
              setState(() {
                isButtonPressed = !isButtonPressed;
              });
            },
            backgroundColor: isButtonPressed ? Colors.blue : Colors.white,
            foregroundColor: isButtonPressed ? Colors.white : Colors.black,
            child: const Icon(Icons.arrow_forward),
          ),
      ),
    );
  }
}
