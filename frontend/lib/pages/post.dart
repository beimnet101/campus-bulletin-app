// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:frontend/components/Button.dart';
import 'package:frontend/utils.dart';
import 'package:motion_toast/motion_toast.dart';

class Post extends StatefulWidget {
  final String channelId;
  Post({super.key, required this.channelId});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController attachmentsController = TextEditingController();
  TextEditingController issuedFromController = TextEditingController();
  TextEditingController issuedToController = TextEditingController();

  List<bool> isSelected = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Post an announcement',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.0),
              SingleChildScrollView(
                child: TextField(
                  controller: bodyController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Body',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: attachmentsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Attachments',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: issuedFromController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Issued from',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: issuedToController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Issued to',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: <Widget>[
                    // RoundedChip(
                    //   label: 'Low',
                    //   color: Colors.green,
                    //   index: 0,
                    // ),
                    // RoundedChip(
                    //   label: 'Medium',
                    //   color: Colors.yellow,
                    //   index: 1,
                    // ),
                    // RoundedChip(
                    //   label: 'High',
                    //   color: Colors.red,
                    //   index: 2,
                    // )
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected.fillRange(0, isSelected.length, false);
                          isSelected[0] = !isSelected[0];
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Chip(
                          label: Text('Low'),
                          shape: StadiumBorder(
                            side: BorderSide.none,
                          ),
                          side: BorderSide(
                            color: isSelected[0]
                                ? Colors.green
                                : Theme.of(context).dividerColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected.fillRange(0, isSelected.length, false);
                          isSelected[1] = !isSelected[1];
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Chip(
                          label: Text('Medium'),
                          shape: StadiumBorder(
                            side: BorderSide.none,
                          ),
                          side: BorderSide(
                            color: isSelected[1]
                                ? Colors.yellow
                                : Theme.of(context).dividerColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected.fillRange(0, isSelected.length, false);
                          isSelected[2] = !isSelected[2];
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Chip(
                          label: Text('High'),
                          shape: StadiumBorder(
                            side: BorderSide.none,
                          ),
                          side: BorderSide(
                            color: isSelected[2]
                                ? Colors.red
                                : Theme.of(context).dividerColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),
              Center(
                  child: Button('Post', 0, () async {
                bool isSuccess = await createNotice(
                    titleController.text,
                    bodyController.text,
                    attachmentsController.text,
                    issuedFromController.text,
                    issuedToController.text,
                    isSelected.indexOf(true),
                    widget.channelId);

                if (isSuccess) {
                  Future.delayed(Duration.zero, () {
                    MotionToast.success(
                      title: Text("Success"),
                      description: Text('Notice posted successfully'),
                    ).show(context);
                    Navigator.pop(context);
                  });
                } else {
                  Future.delayed(Duration.zero, () {
                    MotionToast.error(
                      title: Text("Error"),
                      description: Text('Failed to post notice'),
                    ).show(context);
                  });
                }
              })),
            ],
          ),
        ),
      ),
    );
  }
}

// class RoundedChip extends StatefulWidget {
//   final String label;
//   final Color color;
//   final int index;

//   RoundedChip({
//     Key? key,
//     required this.label,
//     required this.color,
//     required this.index,
//   }) : super(key: key);

//   @override
//   _RoundedChipState createState() => _RoundedChipState();
// }

// class _RoundedChipState extends State<RoundedChip> {
//   // bool isSelected = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 8.0),
//         child: Chip(
//           label: Text(widget.label),
//           shape: StadiumBorder(
//             side: BorderSide.none,
//           ),
//           side: BorderSide(
//             color: widget.isSelected
//                 ? widget.color
//                 : Theme.of(context).dividerColor,
//             width: 2.0,
//           ),
//         ),
//       ),
//     );
//   }
// }
