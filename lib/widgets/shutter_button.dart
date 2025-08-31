import 'package:flutter/material.dart';

class ShutterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShutterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.camera_alt),
    );
  }
}