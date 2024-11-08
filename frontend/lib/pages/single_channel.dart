// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:frontend/models/notice.model.dart';
import 'package:frontend/utils.dart';

class SingleChannel extends StatefulWidget {
  const SingleChannel({Key? key, this.channelId}) : super(key: key);
  final String? channelId;

  @override
  _SingleChannelState createState() => _SingleChannelState();
}

class _SingleChannelState extends State<SingleChannel> {
  late String? _channelId;

  @override
  void initState() {
    super.initState();
    _channelId = widget.channelId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Channel',
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: getNotices(_channelId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Unable to fetch notices');
                } else if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied,
                            size: 100.0, color: Colors.grey),
                        Text('No notice found',
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.grey)),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> notice = snapshot.data![index];
                      return noticeCard(
                        notice['date'],
                        notice['title'],
                        notice['body'],
                        notice['resources'],
                        notice['importance'],
                        notice['issuer'],
                        notice['audience'],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget importanceChip(int importance) {
  String label;
  Color color;
  switch (importance) {
    case 0:
      label = 'Low';
      color = Colors.green;
      break;
    case 1:
      label = 'Medium';
      color = Colors.yellow;
      break;
    case 2:
      label = 'High';
      color = Colors.red;
      break;
    default:
      label = 'Unknown';
      color = Colors.black;
  }

  return Chip(
    backgroundColor: color,
    label: Text(label, style: TextStyle(color: Colors.white)),
    shape: StadiumBorder(),
  );
}

Widget noticeCard(
  String date,
  String title,
  String body,
  List<dynamic> attachments,
  int importance,
  String issuer,
  String audience,
) {
  return Card(
    margin: const EdgeInsets.all(10),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text('🗓️ $date'),
          ),
          SizedBox(height: 12),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(body),
          ),
          SizedBox(height: 8),
          if (attachments.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔗 Attachments:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (String attachment in attachments)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(attachment),
                  ),
              ],
            ),
          SizedBox(height: 8),
          Row(
            children: [
              Text('🚨 Importance: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              importanceChip(importance),
            ],
          ),
          Row(
            children: [
              Text(
                'Issuer: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(issuer),
            ],
          ),
          Row(
            children: [
              Text(
                'Issued to: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(audience),
            ],
          ),
        ],
      ),
    ),
  );
}
