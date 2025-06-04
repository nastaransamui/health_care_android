double getStarRatingProportion(List<double> rateArray, double starRating) {
  if (rateArray.isEmpty) {
    return 0.0;
  }

  int count = 0;
  for (double rating in rateArray) {
    // This counts ratings that are exactly equal to the starRating.
    // For example, if starRating is 5.0, it counts ratings that are exactly 5.0.
    if (rating == starRating) {
      count++;
    }
    // If you want to count ratings within a range (e.g., 4.0 to 4.9 for "4-star" category),
    // you would use a range check here.
    // Example for a 4-star category (4.0 to <5.0):
    // if (starRating == 4.0 && rating >= 4.0 && rating < 5.0) { count++; }
    // Example for a 3-star category (3.0 to <4.0):
    // if (starRating == 3.0 && rating >= 3.0 && rating < 4.0) { count++; }
  }

  return count / rateArray.length;
}
