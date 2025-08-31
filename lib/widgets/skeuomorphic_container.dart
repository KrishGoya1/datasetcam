import 'package:flutter/material.dart';

class SkeuomorphicContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const SkeuomorphicContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.grey[850], // Base color
          borderRadius: borderRadius ?? BorderRadius.circular(15.0),
          boxShadow: [
            // Darker shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
            // Lighter shadow for a highlight effect
            BoxShadow(
              color: Colors.white.withOpacity(0.15),
              offset: const Offset(-4, -4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[800]!,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}