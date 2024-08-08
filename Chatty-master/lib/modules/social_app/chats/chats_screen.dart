import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/layout/social_app/cubit/states.dart';
import 'package:Chatty/models/social_app/social_user_model.dart';
import 'package:Chatty/modules/social_app/chat_details/chat_details_screen.dart';
import 'package:Chatty/shared/components/components.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatelessWidget {
  final _scrollController = ScrollController();

  ChatsScreen({super.key});

  Future<List<String>> loggedInUserInterests(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data();
        final List<String>? interests = userData?['interests']?.cast<String>();
        return interests ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error retrieving interests for user ID $userId: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: loggedInUserInterests(loggedID!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          final loggedUserInterests = snapshot.data!;
          final usersWithCommonInterests = SocialCubit.get(context).users.where((user) {
            // Check if the user has at least one common interest with the logged-in user
            return user.uId != loggedID && user.interests!.any(loggedUserInterests.contains);
          }).toList();

          return BlocConsumer<SocialCubit, SocialStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return ConditionalBuilder(
                condition: usersWithCommonInterests.isNotEmpty,
                builder: (context) => ListView.separated(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final user = usersWithCommonInterests[index];
                    return buildChatItem(user, context);
                  },
                  separatorBuilder: (context, index) => myDivider(),
                  itemCount: usersWithCommonInterests.length,
                ),
                fallback: (context) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Sorry, Can\'t find someone with the same interests.'),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading interests'),
          );
        } else {
          // Handle other states if needed
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget buildChatItem(SocialUserModel model, context) => InkWell(
    onTap: () {
      navigateTo(
        context,
        ChatDetailsScreen(
          userModel: model,
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.0,
            backgroundImage: NetworkImage('${model.image}'),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Text(
            '${model.name}',
            style: const TextStyle(
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}
