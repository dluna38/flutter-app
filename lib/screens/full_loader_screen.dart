import 'package:flutter/material.dart';

class FullScreenLoader extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const FullScreenLoader({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  State<FullScreenLoader> createState() => _FullScreenLoaderState();
}

class _FullScreenLoaderState extends State<FullScreenLoader> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Container(
            color: Colors.black.withValues(
              alpha: 0.5,
            ), // Fondo semi-transparente
            child: Center(
              child: Image.asset(
                'resources/plant-heart.gif',
                width: 300,
                height: 300,
              ),
            ),
          ),
      ],
    );
  }
}
