import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Image.asset('Logo', width: 107, height: 48, fit: BoxFit.cover),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
