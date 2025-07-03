import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_care/models/reviews.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/review_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class ReviewService {
  Future<void> getDoctorReviews(BuildContext context, String doctorId) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
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
    socket.on('updateGetDoctorReviews', (data) {
      getDoctorReviewsWidthUpdate();
    });

    getDoctorReviewsWidthUpdate();
  }

  Future<void> updateReply(BuildContext context, Map<String, dynamic> payload) async {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    reviewProvider.setLoading(true);

    socket.emit('updateReply', payload);
    socket.off('updateReplyReturn');
    socket.on('updateReplyReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? data['reason']);
        }
        return;
      }
    });
  }

  Future<void> getAuthorReviews(BuildContext context) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    String patientId = authProvider.patientProfile!.userId;
    reviewProvider.setLoading(true);

    void getAuthorReviewsWidthUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getAuthorReviews', {
        "patientId": patientId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getAuthorReviewsReturn');
    socket.on('getAuthorReviewsReturn', (data) {
      reviewProvider.setLoading(false);
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? data['reason']);
        }
        return;
      }
      if (data['status'] == 200) {
        final authorReviews = data['authorReviews'];
        final int totalReviews = data['totalReviews'];
        if (authorReviews is List && authorReviews.isNotEmpty) {
          reviewProvider.setPatientReviews([]);
          final authorReviewList = authorReviews.map((json) => PatientReviews.fromMap(json)).toList();
          reviewProvider.setPatientReviews(authorReviewList);
          reviewProvider.setTotal(totalReviews);
        } else {
          reviewProvider.setReviews([]);
          reviewProvider.setTotal(0);
        }
      }
    });
    socket.off('updateGetAuthorReviews');
    socket.on('updateGetAuthorReviews', (_) => getAuthorReviewsWidthUpdate());

    getAuthorReviewsWidthUpdate();
  }

  Future<bool> deleteReview(BuildContext context, List<String> deleteIds) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return false;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String patientId = authProvider.patientProfile!.userId;

    final completer = Completer<bool>();
    void deleteReviewWithUpdate() {
      socket.emit('deleteReview', {"patientId": patientId, "deleteIds": deleteIds});
    }

    socket.off('deleteReviewReturn');
    socket.on('deleteReviewReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      } else {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    deleteReviewWithUpdate();

    return completer.future;
  }

  Future<bool> updateReview(BuildContext context, Map<String, dynamic> payload) async {
    final completer = Completer<bool>();
    socket.emit('updateReview', payload);
    socket.once('updateReviewReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      } else {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });
    return completer.future;
  }
}
