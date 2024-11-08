// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/Providers/auth_provider.dart';
import 'package:frontend/components/Button.dart';
import 'package:frontend/pages/post.dart';
import 'package:frontend/pages/single_channel.dart';
import 'package:frontend/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:badges/src/badge.dart' as badges;
import 'package:signalr_netcore2/signalr_client.dart' as signalr;

final isToggledProvider = StateNotifierProvider<ToggleController, bool>(
  (ref) => ToggleController(),
);

Color? primaryColor;

class ToggleController extends StateNotifier<bool> {
  ToggleController() : super(true); // Initial state is true

  void toggle() {
    state = !state;
  }
}

final isSubscribedSelectedProvider = StateProvider<bool>((ref) => true);

class Channels extends ConsumerWidget {
  Channels({super.key});
  TextEditingController channelNameController = TextEditingController();
  TextEditingController channelDescriptionController = TextEditingController();
  TextEditingController searchBarController = TextEditingController();

  bool isJoined = false;
  bool isHomeSelected = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count = 0;

    void handleChannelRegistration(List<Object?>? parameters) {
      debugPrint('Received Notification: ${parameters![0]}');
      count++;

      ref.read(notificationProvider.notifier).addNotification(parameters[0]!);
    }

    // Future.delayed(Duration(seconds: 1), () {
    //   ref.read(notificationProvider.notifier).clearNotifications();
    // });
    // {channelId: c0c04e83-f5b5-4fe0-b173-0cc0cedbc1a8, content: 4744ef0c-1c31-4fca-98db-bd528de5488f}

    void startHubConnection() async {
      debugPrint('Starting hub connection');
      try {
        final serverUrl = "http://localhost:5109/notificationHub";
        final hubConnection =
            signalr.HubConnectionBuilder().withUrl(serverUrl).build();
        await hubConnection.start();
        hubConnection.on('ReceiveNotification', handleChannelRegistration);

        if (!isJoined) {
          List<dynamic> subscribedChannels = await getMyChannels();
          List<String> subscribedChannelsIds = [];

          for (var channel in subscribedChannels) {
            subscribedChannelsIds.add(channel['id']);
          }

          debugPrint('Subscribed Channels: $subscribedChannelsIds');
          hubConnection
              .invoke('JoinGroup', args: <Object>[subscribedChannelsIds]);
          isJoined = true;
        }
      } catch (e) {
        debugPrint('Failed to start hub connection: $e');
      }
    }

    startHubConnection();

    List<dynamic> notifications =
        ref.watch(notificationProvider.notifier).state;
    debugPrint('Notifications from Riverpod: $notifications');
    debugPrint('Notifications count: $count');

    File? imageFile = ref.watch(channelImageProvider);
    ChannelImageNotifier channelImageNotifier =
        ref.watch(channelImageProvider.notifier);

    StateController<bool> isSubscribedSelectedContoller =
        ref.watch(isSubscribedSelectedProvider.notifier);
    bool isSubscribeSelected = isSubscribedSelectedContoller.state;
    List<dynamic> searchResults = [];

    final isToggled = ref.watch(isToggledProvider);
    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Builder(builder: (context) {
              return badges.Badge(
                badgeContent: Text(
                  '${notifications.length}',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                badgeStyle: BadgeStyle(
                  badgeColor: Colors.white,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              );
            }),
            SizedBox(width: 15.0),
          ],
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Channels',
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
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Text('Notifications',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              FutureBuilder(
                future: getNotificationDetails(notifications),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Column(
                      children: (snapshot.data as List).map((n) {
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(notificationProvider.notifier)
                                .removeNotification(n);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SingleChannel(channelId: n['channelId'])),
                            );
                          },
                          child: notificationCard(
                            n['channelName'],
                            n['title'],
                            n['importance'],
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Text('No notifications found.');
                  }
                },
              ),
            ],
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
        body: Builder(builder: (context) {
          return Column(
            children: [
              Row(
                children: [
                  Spacer(),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.plus,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      // Create channel
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                'Create Channel',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: SingleChildScrollView(
                                padding: EdgeInsets.all(0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 15.0),
                                      child: TextButton(
                                        onPressed: () async {
                                          await channelImageNotifier
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
                                    Form(
                                        child: Column(
                                      children: [
                                        TextFormField(
                                          controller: channelNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Channel Name',
                                          ),
                                        ),
                                        TextFormField(
                                          controller:
                                              channelDescriptionController,
                                          decoration: const InputDecoration(
                                            labelText: 'Channel Description',
                                          ),
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    channelImageNotifier.clearImage();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    bool isSuccess = await createChannel(
                                        channelNameController.text,
                                        channelDescriptionController.text,
                                        imageFile!);

                                    if (isSuccess) {
                                      Future.delayed(Duration.zero, () {
                                        MotionToast.success(
                                          title: Text("Success"),
                                          description: Text(
                                              'Channel created successfully'),
                                        ).show(context);
                                      });
                                    } else {
                                      Future.delayed(Duration.zero, () {
                                        MotionToast.error(
                                          title: Text("Error"),
                                          description:
                                              Text('Unable to create channel'),
                                        ).show(context);
                                      });
                                    }
                                    channelImageNotifier.clearImage();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Create'),
                                ),
                              ],
                            );
                          });
                    },
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                  ),
                ],
              ),
              // searchBar(),
              // SearchBar
              Container(
                margin:
                    const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        30.0), // Adjust the radius for pill shape
                    // color: Colors.grey[200],
                    color: Theme.of(context).colorScheme.secondaryContainer),
                child: Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchBarController,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              fontSize: 18.0),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            debugPrint(
                                'Search Query: ${searchBarController.text}');
                            // searchChannels(searchBarController.text);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      'Search Results',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    ),
                                    content: FutureBuilder(
                                        future: searchChannels(
                                            searchBarController.text),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            Future.delayed(Duration.zero, () {
                                              MotionToast.error(
                                                title: Text("Error"),
                                                description: Text(
                                                    'Unable to load channels'),
                                              ).show(context);
                                            });
                                            return Container();
                                          } else if (!snapshot.hasData) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons
                                                        .sentiment_dissatisfied,
                                                    size: 100.0,
                                                    color: Colors.grey),
                                                Text('No channels found',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.grey)),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              children: [
                                                searchResult(
                                                    context!,
                                                    snapshot.data['id'],
                                                    snapshot.data['name'],
                                                    snapshot.data['logo'])
                                              ],
                                            );
                                          }
                                        }),
                                  );
                                });
                          }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      if (!isToggled) {
                        ref.read(isToggledProvider.notifier).toggle();
                      }
                      debugPrint('isSubscribedSelected: $isSubscribeSelected');
                    },
                    child: Text(
                      'Subscribed',
                      style: TextStyle(
                        fontWeight:
                            isToggled ? FontWeight.bold : FontWeight.normal,
                        color: isToggled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        if (isToggled) {
                          ref.read(isToggledProvider.notifier).toggle();
                        }
                        debugPrint(
                            '>> isSubscribedSelected: $isSubscribeSelected');
                      },
                      child: Text(
                        'My Channels',
                        style: TextStyle(
                            fontWeight:
                                isToggled ? FontWeight.normal : FontWeight.bold,
                            color: isToggled
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary),
                      )),
                ],
              ),

              // Subscribed and My Channels list
              Expanded(
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FutureBuilder(
                        future: isToggled
                            ? getSubscribedChannels()
                            : getMyChannels(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            Future.delayed(Duration.zero, () {
                              MotionToast.error(
                                title: Text("Error"),
                                description: Text('Unable to load channels'),
                              ).show(context);
                            });
                            return Container();
                          } else if (snapshot.data!.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_dissatisfied,
                                    size: 100.0, color: Colors.grey),
                                Text('No channels found',
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.grey)),
                              ],
                            );
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> channel =
                                      snapshot.data![index];

                                  return postCard(
                                      context,
                                      channel['id'],
                                      channel['name'],
                                      channel['description'],
                                      channel['logo'],
                                      isToggled);
                                });
                          }
                        })),
              ),
            ],
          );
        }));
  }

  Widget searchBar() {
    return Container(
      margin: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30.0), // Adjust the radius for pill shape
        color: Colors.grey[200],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 28.0, right: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchBarController,
                style: TextStyle(color: Colors.grey, fontSize: 18.0),
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget postCard(BuildContext context, String id, String channelName,
      String channelDescription, String logoStr, isSubscribed) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SingleChannel(channelId: id)),
        );
      },
      child: Card(
        child: Column(children: [
          ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: MemoryImage(base64Decode(logoStr)),
            ),
            trailing: isSubscribed
                ? GestureDetector(
                    onTap: () async {
                      String? msg = await unsubscribeFromChannel(id);
                      if (msg != null) {
                        Future.delayed(Duration.zero, () {
                          MotionToast.error(
                            title: Text("Error"),
                            description: Text(msg),
                          ).show(context);
                        });
                      } else {
                        Future.delayed(Duration.zero, () {
                          MotionToast.success(
                            title: Text("Success"),
                            description: Text('Unsubscribed from $channelName'),
                          ).show(context);
                        });
                      }
                    },
                    child: FaIcon(FontAwesomeIcons.trash,
                        color: Colors.red, size: 18),
                  )
                : GestureDetector(
                    onTap: () {
                      debugPrint('Post to channel: $channelName');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Post(channelId: id)),
                      );
                    },
                    child: FaIcon(
                      FontAwesomeIcons.pen,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
            title: Text(channelName,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColor)),
            subtitle: Text(
              channelDescription,
              style: TextStyle(color: primaryColor),
            ),
            tileColor: Colors.white,
          ),
        ]),
      ),
    );
  }
}

Widget searchResult(
    BuildContext context, channelId, channelName, String logoStr) {
  return Card(
    child: Column(children: [
      ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: MemoryImage(base64Decode(logoStr)),
        ),
        title: Text(channelName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.primary),
          ),
          onPressed: () async {
            bool isSuccess = await subscribeToChannel(channelId);
            if (isSuccess) {
              Future.delayed(Duration.zero, () {
                MotionToast.success(
                  title: Text("Success"),
                  description: Text('Subscribed to $channelName'),
                ).show(context);
              });
              Navigator.pop(context);
            } else {
              Future.delayed(Duration.zero, () {
                MotionToast.error(
                  title: Text("Error"),
                  description: Text('Unable to subscribe to $channelName'),
                ).show(context);
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Subscribe'),
        ),
        tileColor: Colors.white,
      ),
    ]),
  );
}

Widget notificationCard(
    String channelName, String noticeTitle, int importance) {
  debugPrint(
      'Debugging notificaitonCard: $channelName, $noticeTitle, $importance');
  return Card(
    child: Column(children: [
      ListTile(
        trailing: Icon(
          Icons.circle,
          color: importance == 0
              ? Colors.green
              : importance == 1
                  ? Colors.yellow
                  : Colors.red,
        ),
        title: Text(channelName,
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        subtitle: Text(
          noticeTitle,
          style: TextStyle(color: primaryColor),
        ),
        tileColor: Colors.white,
      ),
    ]),
  );
}
