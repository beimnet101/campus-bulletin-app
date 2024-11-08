// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:frontend/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signalr_netcore2/signalr_client.dart';
import 'pages/channels.dart';
import 'pages/edit_profile.dart';
import 'pages/login.dart';
import 'pages/post.dart';
import 'pages/single_channel.dart';
import 'pages/view_profile.dart';
import 'pages/signup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Bulleting Board',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Home Page'),
      routes: {
        '/login': (context) => Login(),
        '/channels': (context) => Channels(),
        '/editProfile': (context) => EditProfile(),
        '/post': (context) => Post(
              channelId: 'hhhhh',
            ),
        '/singleChannel': (context) => const SingleChannel(),
        '/viewProfile': (context) => const ViewProfile(),
        '/signup': (context) => Signup(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> routeNames = [
    '/login',
    '/channels',
    '/editProfile',
    '/post',
    '/singleChannel',
    '/viewProfile',
    '/signup',
  ];

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Home Page',
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
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildButtons(context),
        ),
      ),
    );
  }

  List<Widget> buildButtons(BuildContext context) {
    return routeNames.map((routeName) {
      return TextButton(
        onPressed: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Text(routeName.substring(1)), // Removing the leading '/'
      );
    }).toList();
  }
}
