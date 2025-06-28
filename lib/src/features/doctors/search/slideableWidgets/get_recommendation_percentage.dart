String getRecommendationPercentage(singleDoctor) {
  if (singleDoctor.recommendArray != null && singleDoctor.recommendArray.isNotEmpty) {
    int count = singleDoctor.recommendArray.where((vote) => vote == 1).length;
    double percentage = (count / singleDoctor.recommendArray.length) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  } else {
    return '0%';
  }
}
