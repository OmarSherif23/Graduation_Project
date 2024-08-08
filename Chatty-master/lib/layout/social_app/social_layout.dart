import 'package:firebase_auth/firebase_auth.dart';
import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/layout/social_app/cubit/states.dart';
import 'package:Chatty/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../modules/social_app/social_login/social_login_screen.dart';
import '../../shared/network/local/chache_helper.dart';

class SocialLayout extends StatelessWidget {
  const SocialLayout({super.key});


  @override
  Widget build(BuildContext buildContext) {

    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){

      },
      builder: (context,state){
        var cubit = SocialCubit.get(context);
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
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
        ),
          child: Scaffold(
            appBar:
            AppBar(
              title: Text(
                  cubit.titles[cubit.currentIndex]
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    CacheHelper.removeData(key: 'uId');
                    SocialCubit.get(context).clearUserModel();
                    await FirebaseAuth.instance.authStateChanges().firstWhere((user) => user == null);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SocialLoginScreen()),
                    );

                  },
                  icon: const Icon(Icons.logout),
                ),

              ],

            ),
            body: cubit.Screens[cubit.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
                onTap: (index){
                  cubit.changeBottomNav(index);
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(
                        IconBroken.Chat,
                      ),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person_outlined,
                      ),
                    label: 'Profile',
                  ),
                ],
            ),
          ),
        );
      },
    );
  }
}
