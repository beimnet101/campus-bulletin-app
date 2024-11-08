// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

String imgToString(File imageFile) {
  String imgString = base64Encode(imageFile.readAsBytesSync());
  return imgString;
}

Future<String> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token != null) {
    return token;
  } else {
    throw Exception('Token not found');
  }
}

Future<bool> createChannel(String name, String description, File image) async {
  Dio dio = Dio();
  String token = await getToken();
  debugPrint('JWT Token: $token');
  String logo = imgToString(image);
  Map<String, dynamic> reqBody = {
    'name': name,
    'description': description,
    'logo': logo,
  };

  try {
    final response = await dio.post('http://localhost:5279/api/channels',
        data: reqBody,
        options: Options(headers: {'Authorization': 'Bearer $token'}));

    debugPrint('Create Channel Response: $response');
    if (response.statusCode == 201) {
      debugPrint('Channel Created');
      return true;
    } else {
      debugPrint('Channel Not Created');
    }
  } catch (e) {
    debugPrint('Channel Create Error: $e');
    return false;
  }
  return false;
}

Future<List<dynamic>> getSubscribedChannels() async {
  List<dynamic> channels = [];
  Dio dio = Dio();
  String token = await getToken();

  try {
    final response = await dio.get(
        'http://localhost:5279/api/channels/subscribed',
        options: Options(headers: {'Authorization': 'Bearer $token'}));

    Map<String, dynamic> responseObj = jsonDecode(response.toString());

    // debugPrint('Subscribed Channels Response: $response');
    if (response.statusCode == 200) {
      // debugPrint('Subscribed Channels Fetched');
      channels = responseObj['data'];
    } else {
      // debugPrint('Subscribed Channels Not Fetched');
    }
  } catch (e) {
    // debugPrint('Subscribed Channels Fetch Error: $e');
  }

  return channels;
}

Future<List<dynamic>> getMyChannels() async {
  String id = await getCurrUserId();
  // debugPrint('#[Inside utils] current user id: $id');
  Future.delayed(const Duration(seconds: 3));
  List<dynamic> channels = [];
  Dio dio = Dio();
  String token = await getToken();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    final response = await dio.get('http://localhost:5279/api/channels/admin',
        options: Options(headers: {'Authorization': 'Bearer $token'}));

    Map<String, dynamic> responseObj = jsonDecode(response.toString());

    // debugPrint('My Channels Response: $response');
    if (response.statusCode == 200) {
      debugPrint('My Channels Fetched wooohooooo');
      channels = responseObj['data'];
      debugPrint('Creator ID: ${responseObj['data'][0]['creatorId']}');
      prefs.setString('currUserId', responseObj['data'][0]['creatorId']);
    } else {
      // debugPrint('My Channels Not Fetched');
    }
  } catch (e) {
    debugPrint('My Channels Fetch Error: $e');
  }

  return channels;
}

Future<dynamic> searchChannels(String query) async {
  dynamic channelData;
  Dio dio = Dio();
  String token = await getToken();
  query = query.trim();

  try {
    final response = await dio.get(
      'http://localhost:5279/api/channels/search/:name=?name=$query',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    Map<String, dynamic> responseObj = jsonDecode(response.toString());

    if (response.statusCode == 200) {
      debugPrint('Search Channels Fetched');
      // Check if the 'data' key is present and it's a Map
      if (responseObj.containsKey('data') && responseObj['data'] is Map) {
        channelData = responseObj['data'];
      } else {
        // If 'data' key is not present or not a Map, handle the error case
        debugPrint('Invalid response structure');
      }
    } else {
      debugPrint('Search Channels Not Fetched');
    }
  } catch (e) {
    debugPrint('Search Channels Fetch Error: $e');
  }

  debugPrint('Channel Data: $channelData');
  return channelData;
}

Future<String> getCurrUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  Dio dio = Dio();

  try {
    final response = await dio.get('http://localhost:5279/api/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}));

    Map<String, dynamic> responseObj = jsonDecode(response.toString());
    if (response.statusCode == 200) {
      debugPrint('Current User Fetched');
      return responseObj['data']['id'];
    } else {
      debugPrint('User Not Fetched');
      return '';
    }
  } catch (e) {
    debugPrint('User Fetch Error: $e');
  }

  debugPrint('I should not arrive here');
  return '';
}

Future<bool> subscribeToChannel(String channelId) async {
  Dio dio = Dio();
  String token = await getToken();

  try {
    final response = await dio.post(
      'http://localhost:5279/api/channels/subscribe/$channelId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      debugPrint('Channel Subscribed');
      return true;
    } else {
      debugPrint('Channel Not Subscribed');
    }
  } catch (e) {
    debugPrint('Channel Subscribe Error: $e');
  }
  return false;
}

Future<String?> unsubscribeFromChannel(String channelId) async {
  Dio dio = Dio();
  String token = await getToken();

  try {
    final response = await dio.post(
      'http://localhost:5279/api/channels/unsubscribe/$channelId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    Map<String, dynamic> responseObj = jsonDecode(response.toString());
    debugPrint('Channel Unsubscribe Response: $response');

    if (response.statusCode == 200) {
      debugPrint('Channel Unsubscribed');
    } else {
      debugPrint('Channel Not Unsubscribed');
    }
    return responseObj['message'];
  } catch (e) {
    debugPrint('Channel Unsubscribe Error: $e');
  }
}

Future<List<dynamic>> getNotices(String channelId) async {
  List<dynamic> notices = [];
  Dio dio = Dio();
  String token = await getToken();

  try {
    final response = await dio.get(
      'http://localhost:5000/api/$channelId/notices/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    Map<String, dynamic> responseObj = jsonDecode(response.toString());

    if (response.statusCode == 200) {
      debugPrint('Notices Fetched');
      notices = responseObj['data'];
    } else {
      debugPrint('Notices Not Fetched');
    }
  } catch (e) {
    debugPrint('Notices Fetch Error: $e');
  }

  return notices;
}

Future<bool> createNotice(
  String title,
  String body,
  String attachments,
  String issuedFrom,
  String issuedTo,
  int priority,
  String channelId,
) async {
  debugPrint(
      'Creating Notice: $title, $body, $attachments, $issuedFrom, $issuedTo, $priority, $channelId');
  Dio dio = Dio();
  String token = await getToken();

  Map<String, dynamic> reqBody = {
    'title': title,
    'body': body,
    'date': '${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
    'resources': [attachments], // Make sure attachments is a list
    'categories': [3, 2],
    'importance': priority,
    'issuer': issuedFrom,
    'audience': issuedTo,
    'channelId': channelId,
  };

  try {
    final response = await dio.post(
      'http://localhost:5000/api/$channelId/notices/',
      data: jsonEncode(reqBody),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      debugPrint('Notice Created');
      return true;
    } else {
      debugPrint('Notice Not Created');
    }
  } catch (e) {
    debugPrint('Notice Create Error: $e');
    return false;
  }
  return false;
}

Future<Map<String, dynamic>?> getSingleChannel(String channelId) async {
  Dio dio = Dio();
  String token = await getToken();

  try {
    final response = await dio.get(
      'http://localhost:5279/api/channels/$channelId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    Map<String, dynamic> responseObj = jsonDecode(response.toString());

    if (response.statusCode == 200) {
      debugPrint('Channel Fetched');
      return responseObj['data'];
    } else {
      debugPrint('Channel Not Fetched');
    }
  } catch (e) {
    debugPrint('Channel Fetch Error: $e');
  }
}

Future<dynamic> getNotificationDetails(List<dynamic> notifications) async {
  Dio dio = Dio();
  String token = await getToken();
  String channelName = '';
  String channelId = '';
  String title = '';
  int importance = 0;

  List<Map<String, dynamic>> toBeReturned = [];

  for (Object notification in notifications) {
    Map<String, dynamic> notificationObj = notification as Map<String, dynamic>;

    try {
      final response = await dio.get(
          'http://localhost:5000/api/${notificationObj['channelId']}/notices/id?noticeId=${notificationObj['content']}',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      Map<String, dynamic> responseObj = jsonDecode(response.toString());
      debugPrint('Notification object Response: $responseObj');

      if (response.statusCode == 200) {
        debugPrint('Notifications Fetched');
        title = responseObj['data']['title'];
        importance = responseObj['data']['importance'];
        channelId = responseObj['data']['channelId'];
      } else {
        debugPrint('Notifications Not Fetched');
      }
    } catch (e) {
      debugPrint('Notifications Fetch Error: $e');
    }

    try {
      final response = await dio.get(
          'http://localhost:5279/api/channels/${notificationObj['channelId']}',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      Map<String, dynamic> responseObj = jsonDecode(response.toString());

      if (response.statusCode == 200) {
        debugPrint('Channel Fetched');
        channelName = responseObj['data']['name'];
      } else {
        debugPrint('Channel Not Fetched');
      }
    } catch (e) {
      debugPrint('Channel Fetch Error: $e');
    }

    toBeReturned.add({
      'channelName': channelName,
      'title': title,
      'importance': importance,
      'channelId': channelId,
    });
  }

  return toBeReturned;
}

Future<Map<String, dynamic>?> getSingleNotice(
    String channelId, String noticeId) async {
  Dio dio = Dio();
  String token = await getToken();

  try {
    final response = await dio.get(
      'http://localhost:5000/api/$channelId/notices/id?noticeId=$noticeId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    Map<String, dynamic> responseObj = jsonDecode(response.toString());

    if (response.statusCode == 200) {
      debugPrint('Notice Fetched');
      return responseObj['data'];
    } else {
      debugPrint('Notice Not Fetched');
    }
  } catch (e) {
    debugPrint('Notice Fetch Error: $e');
  }
}

Future<Map<String, dynamic>?> getProfileDetails() async {
  Dio dio = Dio();
  String token = await getToken();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? currUserId = prefs.getString('currUserId');

  debugPrint('Current User ID from getProfileDetails: $currUserId');

  try {
    final response = await dio.get('http://localhost:5006/api/user/$currUserId',
        options: Options(headers: {'Authorization': 'Bearer $token'}));

    Map<String, dynamic> responseObj = jsonDecode(response.toString());

    if (response.statusCode == 200) {
      debugPrint('Profile Fetched');
      return responseObj['data'];
    } else {
      debugPrint('Profile Not Fetched');
    }
  } catch (e) {
    debugPrint('Profile Fetch Error: $e');
  }
}
