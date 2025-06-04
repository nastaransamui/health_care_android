double calculateAverageRating(List<double> rateArray) {
  if (rateArray.isEmpty) {
    return 0.0; // Avoid division by zero if the array is empty
  }

  double sum = 0.0;
  for (double rating in rateArray) {
    sum += rating;
  }

  double rawAverage = sum / rateArray.length;

  // Round to one decimal place first
  double roundedAverage = (rawAverage * 10).roundToDouble() / 10;

  // Ceiling it up to the nearest 0.5
  // Example:
  // 3.1 -> 3.5
  // 3.5 -> 3.5
  // 3.6 -> 4.0
  double steppedAverage = (roundedAverage * 2).ceilToDouble() / 2;

  // Ensure it doesn't exceed 5.0 (though unlikely with average of 5.0 max values)
  return steppedAverage.clamp(0.0, 5.0);
}
