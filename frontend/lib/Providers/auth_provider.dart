import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/pages/edit_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        'http://localhost:5006/api/user/register',
        data: userData,
      );

      if (response.statusCode == 200) {
        debugPrint('User registration successful: $response');
        return true;
      } else {
        debugPrint('Error during user registration: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      debugPrint('Error during user registration: $error');
      return false;
    }
  }
}

final authService = AuthService();

final registrationProvider =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, userData) async {
  try {
    final success = await authService.registerUser(userData);
    return success;
  } catch (error) {
    debugPrint('Error during user registration: $error');
    return false;
  }
});

final sharedPrefsProvider = FutureProvider((ref) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  return sharedPrefs;
});

final formDataProvider = Provider<Map<String, dynamic>>((ref) {
  final sharedPrefs = ref.watch(sharedPrefsProvider);

  return sharedPrefs.when(
      data: (sharedPrefs) {
        return {
          'firstName': sharedPrefs.getString('firstName'),
          'lastName': sharedPrefs.getString('lastName'),
          'userName': sharedPrefs.getString('userName'),
          'email': sharedPrefs.getString('email'),
          'department': sharedPrefs.getInt('department'),
          'year': sharedPrefs.getInt('year'),
          'phoneNumber': sharedPrefs.getString('phoneNumber'),
          'password': sharedPrefs.getString('password'),
          'avatar': sharedPrefs.getString('avatar'),
        };
      },
      loading: () => {},
      error: (error, stackTrace) => {});
});

final imageFileProvider =
    StateNotifierProvider<ImageFileNotifier, File?>((ref) {
  return ImageFileNotifier();
});

class ImageFileNotifier extends StateNotifier<File?> {
  ImageFileNotifier() : super(null);

  final ImagePicker _imagePicker = ImagePicker();
  String imageUrl = 'https://picsum.photos/250?image=9';

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      state = File(pickedFile.path);
    }
  }

  void clearImage() {
    state = null;
  }
}

final channelImageProvider =
    StateNotifierProvider<ChannelImageNotifier, File?>((ref) {
  return ChannelImageNotifier();
});

class ChannelImageNotifier extends StateNotifier<File?> {
  ChannelImageNotifier() : super(null);

  final ImagePicker _imagePicker = ImagePicker();
  String imageUrl = 'https://picsum.photos/250?image=9';

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      state = File(pickedFile.path);
    }
  }

  void clearImage() {
    state = null;
  }
}

final EditProfileImageProvider =
    StateNotifierProvider<EditProfileImageNotifier, File?>((ref) {
  return EditProfileImageNotifier();
});

class EditProfileImageNotifier extends StateNotifier<File?> {
  EditProfileImageNotifier() : super(null);

  final ImagePicker _imagePicker = ImagePicker();
  String imageUrl = 'https://picsum.photos/250?image=9';

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      state = File(pickedFile.path);
    }
  }

  void clearImage() {
    state = null;
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationListState, List<dynamic>>((ref) {
  return NotificationListState();
});

class NotificationListState extends StateNotifier<List<dynamic>> {
  NotificationListState() : super(const []);

  void addNotification(dynamic newNotification) {
    state = [...state, newNotification];
  }

  void clearNotifications() {
    state = [];
  }

  void removeNotification(dynamic notification) {
    debugPrint("Notification to remove: $notification['content']");
    debugPrint('State before: $state');
    state =
        state.where((n) => n['channelId'] != notification['channelId']).toList();
    debugPrint('State after: $state');
  }
}










// final isSubscribedSelectedProvider = StateNotifierProvider<IsSubscribedSelectedNotifier, bool>((ref) {
//   return IsSubscribedSelectedNotifier();
// });

// class IsSubscribedSelectedNotifier extends StateNotifier<bool> {
//   IsSubscribedSelectedNotifier() : super(false);

//   void toggle() {
//     state = !state;
//   }
// }
