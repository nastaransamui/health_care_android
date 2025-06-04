import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class StarReviewWidget extends StatelessWidget {
  const StarReviewWidget({
    super.key,
    required this.rate,
    required this.textColor,
    required this.starSize,
  });

  final double rate;
  final Color textColor;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return RatingStars(
      value: rate,
      onValueChanged: (v) {},
      starCount: 5,
      starSize: starSize,
      valueLabelVisibility: false,
      starBuilder: (index, color) {
        return Icon(
          Icons.star,
          color: color, // Use the color provided by the builder
          size: starSize, // Match your starSize, or adjust as needed
        );
      },
      maxValue: 5,
      starSpacing: 2,
      maxValueVisibility: true,
      animationDuration: const Duration(milliseconds: 1000),
      starOffColor: textColor,
      starColor: Colors.amber,
    );
  }
}
