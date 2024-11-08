// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EllipseImageFromDatabase extends StatefulWidget {
  final String imageUrl; 

  const EllipseImageFromDatabase({required this.imageUrl});

  @override
  _EllipseImageFromDatabaseState createState() =>
      _EllipseImageFromDatabaseState();
}

class _EllipseImageFromDatabaseState extends State<EllipseImageFromDatabase> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 20.0),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: 150.0, 
              height: 150.0, 
              fit: BoxFit.cover, 
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Add your edit image logic here
                
                print('Edit image tapped');
              },
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
