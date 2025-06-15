import 'package:flutter/widgets.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:provider/provider.dart';

class AvailableTimeService {
  Future<void> getDoctorAvailableTime(BuildContext context, DateTime startDate, DateTime endDate) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
    final String roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    AppointmentProvider appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    String userId = "";
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }
    void getDoctorAvailableTimeWithUpdate(DateTime startDate, DateTime endDate) {
      Map<String, dynamic> mongoFilterModel;
      if (startDate.isAtSameDayAs(endDate)) {
        mongoFilterModel = buildMongoDBFilter(startDate, endDate, 'day');
      } else {
        mongoFilterModel = buildMongoDBFilter(startDate, endDate, '');
      }
      socket.emit('getDoctorAvailableTime', {
        "userId": userId,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getDoctorAvailableTimeReturn');
    socket.on('getDoctorAvailableTimeReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final myAppointment = data['myAppointment'];
        if (myAppointment is List && myAppointment.isNotEmpty) {
          appointmentProvider.setAppointmentReservations([]);
          try {
            appointmentProvider.setAppointmentReservations([]);
            final myAppointmentList = (myAppointment).map((json) => AppointmentReservation.fromMap(json)).toList();
            appointmentProvider.setAppointmentReservations(myAppointmentList);
            appointmentProvider.setLoading(false);
            // ignore: empty_catches
          } catch (e) {}
        } else {
          appointmentProvider.setAppointmentReservations([]);
          appointmentProvider.setLoading(false, notify: false);
        }
      }
    });

    getDoctorAvailableTimeWithUpdate(startDate, endDate);
  }
}

Map<String, dynamic> buildMongoDBFilter(DateTime startDate, DateTime endDate, String currentView) {
  final start = startDate;
  final end = endDate;

  String toISOString(DateTime dt) {
    final localMidnight = DateTime(dt.year, dt.month, dt.day);
    return "${DateFormat('yyyy-MM-dd').format(localMidnight)}T00:00:00.000Z";
  }

  final String utcStartDate = toISOString(start);
  final String utcEndDate = toISOString(end);
  Map<String, dynamic> conditionExpr = {
    r'$cond': {
      'if': {
        r'$ne': [
          {r'$type': r'$selectedDate'},
          'string',
        ],
      },
      'then': {
        r'$dateToString': {
          'format': '%Y-%m-%d',
          'date': r'$selectedDate',
        },
      },
      'else': null,
    },
  };

  if (currentView == 'day') {
    return {
      r'$expr': {
        r'$eq': [
          conditionExpr,
          {
            r'$dateToString': {
              'format': '%Y-%m-%d',
              'date': {
                r'$dateFromString': {'dateString': utcStartDate}
              }
            }
          }
        ]
      }
    };
  } else {
    return {
      r'$expr': {
        r'$and': [
          {
            r'$gte': [
              conditionExpr,
              {
                r'$dateToString': {
                  'format': '%Y-%m-%d',
                  'date': {
                    r'$dateFromString': {'dateString': utcStartDate}
                  }
                }
              }
            ]
          },
          {
            r'$lte': [
              conditionExpr,
              {
                r'$dateToString': {
                  'format': '%Y-%m-%d',
                  'date': {
                    r'$dateFromString': {'dateString': utcEndDate}
                  }
                }
              }
            ]
          }
        ]
      }
    };
  }
}
