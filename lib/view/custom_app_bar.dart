import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'BebasNeue-Regular',
          // other text style properties...
        ),
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      leading:leading != null ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Get.back(); // Add Get.back() here for navigation
        },
      ) : null,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // do something
          },
        ),
      ],
    );
  }
}
