// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/Providers/auth_provider.dart';
import 'package:frontend/models/student.model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import '../components/TextField.dart';
import '../components/CustomAppBar.dart';
import '../components/Button.dart';
import 'login.dart';

class Signup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Student student = Student();

    Map<String, int> deptToIndex = {
      'Computer Science': 0,
      'Biology': 1,
      'Chemistry': 2,
      'Physics': 3,
      'Mathematics': 4,
      'Statistics': 5,
    };

    File? imageFile = ref.watch(imageFileProvider);
    ImageFileNotifier imageFileNotifier = ref.watch(imageFileProvider.notifier);

    GlobalKey<FormState> signupKey = GlobalKey<FormState>();
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController userNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    final sharedPrefs = ref.watch(sharedPrefsProvider);

    Future<void> onSubmit() async {
      if (signupKey.currentState!.validate()) {
        String imgString =
            base64Encode(File(imageFile!.path).readAsBytesSync());
        student.avatar = imgString;
      }
      Dio dio = Dio();
      try {
        final response = await dio.post(
          'http://localhost:5006/api/user/register',
          data: student.toJson(),
        );

        Map<String, dynamic> responseObj = jsonDecode(response.toString());

        if (response.statusCode == 201) {
          debugPrint('User registration successful: $response');
          sharedPrefs.whenData((sharedPrefs) async {
            await sharedPrefs.setString('firstName', student.firstName!);
            await sharedPrefs.setString('lastName', student.lastName!);
            await sharedPrefs.setString('userName', student.userName!);
            await sharedPrefs.setString('email', student.email!);
            await sharedPrefs.setString('phoneNumber', student.phoneNumber!);
            await sharedPrefs.setString('avatar', student.avatar!);
          });
          Future.delayed(Duration.zero, () {
            MotionToast.success(
                    description: Text('User registered successfully'))
                .show(context);
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        } else {
          debugPrint('Error during user registration: ${response.statusCode}');
          Future.delayed(Duration.zero, () {
            MotionToast.error(
                    description: Text(responseObj['message'].join(', ')))
                .show(context);
          });
        }
      } catch (e) {
        debugPrint('Error: $e');
        // debugPrint('Response: $response');
        debugPrint('Studentinfo: ${student.toJson()}');
        Future.delayed(Duration.zero, () {
          MotionToast.error(description: Text('Please enter valid details'))
              .show(context);
        });
      }
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(26),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Text(
                    "Signup",
                    style: TextStyle(
                      color: Color(0xFF322828),
                      fontFamily: 'Poppins',
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Form(
                    key: signupKey,
                    child: Column(children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 15.0),
                        child: TextButton(
                          onPressed: () async {
                            // await _pickImage(ImageSource.gallery);
                            await imageFileNotifier
                                .pickImage(ImageSource.gallery);
                          },
                          child: Text('Pick a profile image'),
                        ),
                      ),
                      if (imageFile != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(imageFile),
                        ),
                      SizedBox(height: 15.0),
                      CustomTextField(
                        controller: firstNameController,
                        hintText: 'First name',
                        bottomMargin: 15.0,
                        onChanged: (value) {
                          debugPrint('Full name: $value');
                          student.firstName = value;
                        },
                      ),
                      CustomTextField(
                        controller: lastNameController,
                        hintText: 'Last name',
                        bottomMargin: 15.0,
                        onChanged: (value) {
                          debugPrint('Last name: $value');
                          student.lastName = value;
                        },
                      ),
                      CustomTextField(
                        controller: userNameController,
                        hintText: 'User name',
                        bottomMargin: 15.0,
                        onChanged: (value) {
                          debugPrint('User name: $value');
                          student.userName = value;
                        },
                      ),
                      CustomTextField(
                        controller: emailController,
                        hintText: 'Email',
                        bottomMargin: 15.0,
                        onChanged: (value) {
                          debugPrint('Email: $value');
                          student.email = value;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: null,
                        items: List.generate(6, (index) {
                          return DropdownMenuItem<String>(
                            value: deptToIndex.keys.elementAt(index),
                            child: Text(deptToIndex.keys.elementAt(index)),
                          );
                        }),
                        onChanged: (value) {
                          debugPrint(
                              'Department: $value index: ${deptToIndex[value]}');
                          student.department = deptToIndex[value];
                        },
                        decoration: InputDecoration(
                          hintText: 'Department',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      DropdownButtonFormField<int>(
                        value: null,
                        items: List.generate(4, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text((index + 1).toString()),
                          );
                        }),
                        onChanged: (value) {
                          debugPrint('Year of study: $value');
                          student.year = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Year of study',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      CustomTextField(
                        controller: phoneNumberController,
                        hintText: 'Phone number',
                        bottomMargin: 15.0,
                        onChanged: (value) {
                          debugPrint('Phone number: $value');
                          student.phoneNumber = value;
                        },
                      ),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        bottomMargin: 15.0,
                        onChanged: (value) {
                          debugPrint('Password: $value');
                          student.passwordHash = value;
                        },
                      ),
                      CustomTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        bottomMargin: 30.0,
                        onChanged: (value) {
                          debugPrint('Confirm Password: $value');
                        },
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(bottom: 15.0),
                      //   child: TextButton(
                      //     onPressed: () async {
                      //       // await _pickImage(ImageSource.gallery);
                      //       await imageFileNotifier
                      //           .pickImage(ImageSource.gallery);
                      //     },
                      //     child: Text('Pick a profile image'),
                      //   ),
                      // ),
                      // if (imageFile != null)
                      //   CircleAvatar(
                      //     radius: 50,
                      //     backgroundImage: FileImage(imageFile),
                      //   ),
                      SizedBox(height: 15.0),
                      Button("Sign up", 50.0, onSubmit),
                      Column(
                        children: [
                          Text(
                            "Already have an account? ",
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
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Sign in",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
