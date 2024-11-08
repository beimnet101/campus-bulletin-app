// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/Providers/auth_provider.dart';
import 'package:frontend/pages/channels.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/TextField.dart';
import '../components/CustomAppBar.dart';
import '../components/Button.dart';
import 'signup.dart';

void main() {
  runApp(Login());
}

class Login extends ConsumerWidget {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onSubmit() async {
      Dio dio = Dio();
      String userName = userNameController.text.trim();
      String password = passwordController.text.trim();
      final sharedPrefs = ref.watch(sharedPrefsProvider);

      debugPrint('Credentials: $userName $password');

      Map<String, String> reqBody = {
        "userName": userName,
        "password": password,
      };

      try {
        final response = await dio.post(
          "http://localhost:5006/api/user/login",
          data: reqBody,
        );

        var responseObj = jsonDecode(response.toString());
        debugPrint('ResponseObj: $responseObj');

        if (responseObj['isSuccess'] == true) {
          Future.delayed(Duration.zero, () {
            MotionToast.success(
              title: Text("Success"),
              description: Text('Signed in successfully'),
            ).show(context);
          });
          debugPrint('Login successful: $response');
          sharedPrefs.whenData((sharedPrefs) {
            sharedPrefs.setString('token', responseObj['data']['token']);
            sharedPrefs.setString(
                'refreshToken', responseObj['data']['refreshToken']);
          });
        } else {
          debugPrint('Login failed: $response');
          Future.delayed(Duration.zero, () {
            MotionToast.error(
              title: Text("Error"),
              description: Text('Invalid credentials'),
            ).show(context);
          });
        }

        if (response.statusCode == 200) {
          debugPrint('Signin successful: $response');
        }

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Channels()));
      } catch (e) {
        debugPrint('Error: $e');
        Future.delayed(Duration.zero, () {
          MotionToast.error(
            title: Text("Error"),
            description: Text('Invalid credentials'),
          ).show(context);
        });
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: CustomAppBar(),
        body: Padding(
          padding: EdgeInsets.all(26),
          child: Center(
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF322828),
                          fontFamily: 'Poppins',
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CustomTextField(
                      controller: userNameController,
                      hintText: 'Username',
                      bottomMargin: 20.0,
                    ),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      bottomMargin: 30.0,
                    ),
                    Button("Sign in", 100.0, onSubmit),
                    Column(
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF322828),
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Signup()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
