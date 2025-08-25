import 'package:health_care/models/booking_information.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/models/users.dart';

String getRecommendationPercentageFromUserProfile(DoctorUserProfile singleDoctor) {
  if (singleDoctor.recommendArray.isNotEmpty) {
    int count = singleDoctor.recommendArray.where((vote) => vote == 1).length;
    double percentage = (count / singleDoctor.recommendArray.length) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  } else {
    return '0%';
  }
}

String getRecommendationPercentageFromBookingInformation(BookingInformationDoctorProfile singleDoctor) {
  if (singleDoctor.recommendArray.isNotEmpty) {
    int count = singleDoctor.recommendArray.where((vote) => vote == 1).length;
    double percentage = (count / singleDoctor.recommendArray.length) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  } else {
    return '0%';
  }
}

String getRecommendationPercentageFromSingleDoctors(Doctors singleDoctor){
  if (singleDoctor.recommendArray.isNotEmpty) {
    int count = singleDoctor.recommendArray.where((vote) => vote == 1).length;
    double percentage = (count / singleDoctor.recommendArray.length) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  } else {
    return '0%';
  }
}