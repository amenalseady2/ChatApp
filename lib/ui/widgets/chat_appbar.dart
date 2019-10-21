import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget chatAppbar(User user, BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    title: Row(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(left: 8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(80),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Row(
              children: <Widget>[
                Icon(Icons.arrow_back),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // Where the linear gradient begins and ends
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blueAccent, Colors.deepOrangeAccent],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider('${user.photoUrl}'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${user.name}',
          ),
        ),
      ],
    ),
  );
}
