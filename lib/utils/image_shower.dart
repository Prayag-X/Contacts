import 'package:flutter/material.dart';

class ImageShower extends StatelessWidget {
  const ImageShower({
    Key? key,
    required this.image,
    required this.size,
    this.curve,
  }) : super(key: key);

  final String image;
  final double size;
  final BorderRadiusGeometry? curve;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: curve,
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.contain),
      ),
    );
  }
}
