import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function? onLeadingPressed;
  final Function? onActionPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onLeadingPressed,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'BebasNeue-Regular',
          // other text style properties...
        ),
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Get.back(); // Add Get.back() here for navigation
          if (onLeadingPressed != null) {
            onLeadingPressed!(); // Call onLeadingPressed callback if provided
          }
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: onActionPressed as void Function()?,
        ),
      ],
    );
  }
}
