import 'package:flutter/material.dart';
import 'package:health_care/models/reviews.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/review_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class ReviewService {
  Future<void> getDoctorReviews(BuildContext context) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    String doctorId = authProvider.doctorsProfile!.userId;
    reviewProvider.setLoading(true);

    void getDoctorReviewsWidthUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getDoctorReviews', {
        "doctorId": doctorId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getDoctorReviewsReturn');
    socket.on('getDoctorReviewsReturn', (data) {
      reviewProvider.setLoading(false);
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? data['reason']);
        }
        return;
      }
      if (data['status'] == 200) {
        final doctorReviews = data['doctorReviews'];
        final int totalReviews = data['totalReviews'];
        if (doctorReviews is List && doctorReviews.isNotEmpty) {
          reviewProvider.setReviews([]);
          final dcotorsReviewList = doctorReviews.map((json) => Reviews.fromMap(json)).toList();
          reviewProvider.setReviews(dcotorsReviewList);
          reviewProvider.setTotal(totalReviews);
        } else {
          reviewProvider.setReviews([]);
          reviewProvider.setTotal(0);
        }
      }
    });
    socket.off('updateGetDoctorReviews');
    socket.on('updateGetDoctorReviews', (_) => getDoctorReviewsWidthUpdate());

    getDoctorReviewsWidthUpdate();
  }

  Future<void> updateReply(BuildContext context, Map<String, dynamic> payload) async {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    reviewProvider.setLoading(true);

    socket.emit('updateReply', payload);
    socket.off('updateReplyReturn');
    socket.on('updateReplyReturn', (data){
       if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? data['reason']);
        }
        return;
      }
    });
  }
}
