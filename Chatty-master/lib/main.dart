import 'package:firebase_core/firebase_core.dart';
import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/layout/social_app/social_layout.dart';
import 'package:Chatty/modules/social_app/social_login/social_login_screen.dart';
import 'package:Chatty/shared/bloc_observer.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:Chatty/shared/network/local/chache_helper.dart';
import 'package:Chatty/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'modules/social_app/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();

  Widget widget;
  loggedID = CacheHelper.getData(key: 'uId');
  if(loggedID != null){
    widget = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: defaultColor,
          unselectedItemColor: Colors.grey,
          elevation: 20.0,
          backgroundColor: Colors.white,
        ) ,
      ),
      title: 'My Chat App',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/chat': (context) => const SocialLayout(),
        '/social_login_screen': (context) => SocialLoginScreen(),
      },
    );
  }
  else{
    widget = SocialLoginScreen();
  }

  runApp(MyApp(
    startWidget: widget,
  ));
}
class MyApp extends StatelessWidget
{
  final Widget startWidget;

  const MyApp({super.key,
    required this.startWidget,
  });
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => SocialCubit()..getUserData()..getUsers(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: startWidget,
      ),
    );
  }
}
