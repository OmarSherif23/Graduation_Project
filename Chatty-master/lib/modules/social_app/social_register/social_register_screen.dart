import 'package:Chatty/modules/social_app/social_register/waiting_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:Chatty/modules/social_app/social_register/cubit/cubit.dart';
import 'package:Chatty/modules/social_app/social_register/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/components/components.dart';


class RegisterScreen  extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();

  RegisterScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (BuildContext context) => SocialRegisterCubit(),
      child: BlocConsumer<SocialRegisterCubit,SocialRegisterStates>(
        listener: (context,state)
        {
          if (state is SocialCreateUserSuccessState) {
            // Navigate to the waiting verification screen
            navigateTo(context, WaitingVerificationScreen(email: emailController.text,password: passwordController.text,));

          }
        },
        builder: (context,state){
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
                            'REGISTER',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Register now to communicate with friends',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          defaultTextForm(
                            controller: nameController,
                            type: TextInputType.name,
                            validate: (value){
                              if(value!.isEmpty){
                                return 'PLease enter your name';
                              }
                              return null;
                            },
                            label: 'User Name',
                            prefix: Icons.person,
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          defaultTextForm(
                            controller: emailController,
                            type: TextInputType.emailAddress,
                            validate: (value){
                              if(value!.isEmpty){
                                return 'PLease enter your email address';
                              }
                              return null;
                            },
                            label: 'email address',
                            prefix: Icons.email_outlined,
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          defaultTextForm(
                            controller: passwordController,
                            type: TextInputType.emailAddress,
                            validate: (String? value){
                              if(value!.isEmpty){
                                return 'PLease enter your password';
                              }
                              return null;
                            },
                            label: 'Password',
                            prefix: Icons.lock_outline,
                            suffix: SocialRegisterCubit.get(context).suffix,
                            ispassword: SocialRegisterCubit.get(context).isPassword,
                            suffixPressed: (){
                              SocialRegisterCubit.get(context).changePasswordVisibility();
                            },
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          defaultTextForm(
                            controller: phoneController,
                            type: TextInputType.phone,
                            validate: (value){
                              if(value!.isEmpty){
                                return 'PLease enter your phone number';
                              }
                              return null;
                            },
                            label: 'Phone',
                            prefix: Icons.phone,
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          ConditionalBuilder(
                            condition: state is! SocialRegisterLoadingState,
                            builder: (context) => defaultButton(
                              function: (){
                                if(formKey.currentState!.validate()) {
                                  SocialRegisterCubit.get(context).userRegister(
                                    name: nameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    phone: phoneController.text,
                                  );

                                }
                              },
                              text: 'register',
                              upper: true,
                            ),
                            fallback:(context) => const Center(child: CircularProgressIndicator()),
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
