// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/Providers/auth_provider.dart';
import 'package:frontend/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/Photoviewer.dart';
import '../components/viewProfileTextfield.dart';
import '../components/Button.dart';

class EditProfile extends ConsumerWidget {
  EditProfile({Key? key}) : super(key: key);

  final imageUrl = 'https://picsum.photos/250?image=9';
  String? imageStr;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool isHomeSelected = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onSave() async {
      if (!_formKey.currentState!.validate()) {
        Future.delayed(Duration.zero, () {
          MotionToast.error(
            title: Text("Error"),
            description: Text('Invalid input'),
          ).show(context);
        });
      } else {
        Dio dio = Dio();
        String token = await getToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? currUserId = prefs.getString('currUserId');

        final String firstName = firstNameController.text;
        final String lastName = lastNameController.text;
        final String email = emailController.text;
        final int year = int.parse(yearController.text);
        final String phoneNumber = phoneNumberController.text;
        final String username = usernameController.text;

        final Map<String, dynamic> profileData = {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'department': 3,
          'year': year,
          'phoneNumber': phoneNumber,
          'userName': username,
          'avatar': imageStr,
          // 'avatar': base64Encode(File(imageStr!).readAsBytesSync()),
          'id': currUserId
        };

        try {
          final response = await dio.put('http://localhost:5006/api/user',
              options: Options(headers: {'Authorization': 'Bearer $token'}),
              data: profileData);

          if (response.statusCode == 200) {
            Future.delayed(Duration.zero, () {
              MotionToast.success(
                title: Text("Success"),
                description: Text('Profile updated successfully'),
              ).show(context);
            });
          }
        } catch (e) {
          Future.delayed(Duration.zero, () {
            MotionToast.error(
              title: Text("Error"),
              description: Text('Profile update failed'),
            ).show(context);
          });
        }
      }
    }

    File? imageFile = ref.watch(EditProfileImageProvider);
    EditProfileImageNotifier editProfileImageNotifier =
        ref.watch(EditProfileImageProvider.notifier);

    Map<String, dynamic>? profileData;
    Future<Map<String, dynamic>?> fillprofileData() async {
      Map<String, dynamic>? profileData = await getProfileDetails();
      debugPrint('Profile profileData: $profileData');
      if (profileData != null) {
        firstNameController.text = profileData['firstName'];
        lastNameController.text = profileData['lastName'];
        emailController.text = profileData['email'];
        yearController.text = "${profileData['year']}";
        phoneNumberController.text = profileData['phoneNumber'];
        usernameController.text = profileData['userName'];
        imageStr = profileData['avatar'];
      }

      return profileData;
    }

    fillprofileData();

    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            );
          })
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        surfaceTintColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: isHomeSelected ? 0 : 1,
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/channels');
              break;
            case 1:
              Navigator.pushNamed(context, '/editProfile');
              break;
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                imageFile != null
                    // ? Image(image: FileImage(imageFile))
                    ? CircleAvatar(
                        radius: 50.0,
                        backgroundImage: FileImage(imageFile),
                      )
                    : EllipseImageFromDatabase(imageUrl: imageUrl),
                Positioned(
                  bottom: 16.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Choose an option"),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await editProfileImageNotifier
                                      .pickImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                                child: Text("Gallery"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // await _pickImage(ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                                child: Text("Camera"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: "First Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: "Last Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // final emailRegex = RegExp(
                        //   r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$',
                        // );
                        // if (!emailRegex.hasMatch(value)) {
                        //   return 'Please enter a valid email address';
                        // }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: yearController,
                      decoration: InputDecoration(labelText: "Year"),
                      // make the validator to check if the year is a number between 1 and 4
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your year';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 1 || year > 4) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(labelText: "Phone Number"),
                      validator: (value) =>
                          value == null || value.isEmpty || value.length != 10
                              ? 'Invalid phone number'
                              : null,
                    ),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(labelText: "Username"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        } else if (value.length < 8) {
                          return 'Username must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            Button("Save", 0.0, onSave)
          ],
        ),
      ),
    );
  }
}
