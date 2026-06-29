import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.color = Colors.black54, this.size = 50});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(child: LoadingAnimationWidget.threeArchedCircle(color: color, size: size));
  }
}
