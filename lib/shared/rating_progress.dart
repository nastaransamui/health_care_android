import 'package:flutter/material.dart';

class RatingProgress extends StatelessWidget {
  const RatingProgress({
    super.key,
    required this.theme,
    required this.star,
    required this.value,
  });

  final ThemeData theme;
  final int star;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Text("$star"),
              const SizedBox(width: 4), // Small spacing between number and stars
              // Loop to display star icons
              ...List.generate(
                star, // Generate 'star' number of icons
                (index) => const Icon(
                  Icons.star,
                  size: 12, // Keep the size small for multiple stars
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 9,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: theme.primaryColorLight,
                  borderRadius: BorderRadius.circular(7),
                  valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
