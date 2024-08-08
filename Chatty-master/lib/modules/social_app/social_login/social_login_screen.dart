import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:Chatty/layout/social_app/social_layout.dart';
import 'package:Chatty/modules/social_app/social_login/cubit/cubit.dart';
import 'package:Chatty/modules/social_app/social_login/cubit/states.dart';
import 'package:Chatty/modules/social_app/social_register/social_register_screen.dart';
import 'package:Chatty/shared/components/components.dart';
import 'package:Chatty/shared/network/local/chache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialLoginScreen  extends StatelessWidget {

  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  SocialLoginScreen({super.key});


  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return BlocProvider(
      create: (BuildContext context) => SocialLoginCubit(),
      child: BlocConsumer<SocialLoginCubit,SocialLoginStates>(
        listener: (context,state) {
          if(state is SocialLoginErrorState) {
            showToast(
              text: state.error,
              state: ToastStates.ERROR,
            );
          }
          if(state is SocialLoginSuccessState){
            CacheHelper.saveData(
                key: 'uId',
                value: state.uId,
            ).then(
                    (value){
                      navigateAndfFinish(
                          context,
                          const SocialLayout(),
                      );
                    });
          }
        },
        builder: (context,state) {
          return
            Theme(
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
            ),
            child: Scaffold(
              appBar: AppBar(),
              body: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOGIN',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Login now to communicate with friends',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value){
                              if(value!.isEmpty){
                                return 'PLease enter your email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'email address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value){
                              if(value!.isEmpty){
                                return 'PLease enter your password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: (){
                                  SocialLoginCubit.get(context).changePasswordVisibilty();
                                },
                                icon: Icon(
                                  SocialLoginCubit.get(context).suffix,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            obscureText: SocialLoginCubit.get(context).isPassword,
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          ConditionalBuilder(
                            condition: state is! SocialLoginLoadingState,
                            builder: (context) => defaultButton(
                              function: (){
                                if(formKey.currentState!.validate()) {
                                  SocialLoginCubit.get(context).userLogin(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    context: context,
                                  );
                                }
                              },
                              text: 'login',
                              upper: true,
                            ),
                            fallback:(context) => const Center(child: CircularProgressIndicator()),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account?',
                              ),
                              defaultTextButton(
                                function: ()
                                {
                                  navigateTo(
                                    context,
                                    RegisterScreen(),
                                  );
                                },
                                text: 'register',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
