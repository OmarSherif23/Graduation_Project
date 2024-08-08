import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/modules/social_app/edit_profile/edit_profile_screen.dart';
import 'package:Chatty/shared/components/components.dart';
import 'package:Chatty/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../layout/social_app/cubit/states.dart';

class MyProfileScreen extends StatelessWidget {
  final Map<String, IconData> interestIcons = {
    'Sports': Icons.sports,
    'Music': Icons.music_note,
    'Travel': Icons.flight,
    'Art': Icons.palette,
    'Technology': Icons.computer,
    'Food': Icons.restaurant,
    'Fashion': Icons.shopping_bag,
    'Movies': Icons.movie,
  };

  MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var userModel = SocialCubit.get(context).userModel;
        var interests = userModel.interests ?? [];

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 190.0,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Container(
                            height: 140.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4.0),
                                topRight: Radius.circular(4.0),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(userModel.cover ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 64.0,
                          backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                          child: CircleAvatar(
                            radius: 60.0,
                            backgroundImage: NetworkImage('${userModel.image}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    '${userModel.name}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${userModel.bio}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            navigateTo(context, EditProfileScreen());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Edit Profile'),
                              SizedBox(width: 20.0),
                              Icon(IconBroken.Edit),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Interests Section
                  Text(
                    'Interests',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10.0),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: interests
                        .map((interest) => _buildInterestWidget(interest))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInterestWidget(String interest) {
    final iconData = interestIcons[interest];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData ?? Icons.label, size: 18.0),
          const SizedBox(width: 4.0),
          Text(
            interest,
            style: const TextStyle(
              fontSize: 14.0, // Adjust the font size as needed
              color: Colors.black, // Set the font color to black
              decoration: TextDecoration.none, // Remove underline
            ),
          ),
        ],
      ),
    );
  }

}
