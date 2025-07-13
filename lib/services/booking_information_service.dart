import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/booking_information_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BookingInformationService {
  Future<void> getBookingPageInformation(BuildContext context, String doctorId, VoidCallback onDone) async {
    BookingInformationProvider bookingInformationProvider = Provider.of<BookingInformationProvider>(context, listen: false);

    void getBookingPageInformationWithUpdate() {
      socket.emit('getBookingPageInformation', {"doctorId": doctorId});
    }

    socket.off('getBookingPageInformationReturn');
    socket.on('getBookingPageInformationReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final bookingInformationList = data['bookingInformation'];
        if (bookingInformationList is List) {
          final bookingInformation = BookingInformation.fromMap(bookingInformationList.first);
          bookingInformationProvider.setBookingInformation(bookingInformation);
          onDone();
        }
      }
    });

    socket.off("updateGetBookingPageInformation");
    socket.on("updateGetBookingPageInformation", (_) => getBookingPageInformationWithUpdate());

    getBookingPageInformationWithUpdate();
  }

  Future<String> createOccupyTime(BuildContext context, Map<String, dynamic> occupyTime) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return '';
    final completer = Completer<String>();

    socket.emit('createOccupyTime', occupyTime);
    socket.once('createOccupyTimeReturn', (data) {
      if (data['status'] == 409) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        if (!completer.isCompleted) {
          completer.complete('');
        }
      }
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, '${data['reason']}');
        }
        if (!completer.isCompleted) {
          completer.complete('');
        }
      } else {
        completer.complete(data['newOccupy']["_id"]);
      }
    });

    return completer.future;
  }

  Future<bool> deleteOccupyTime(BuildContext context, List<String> deleteIds) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return false;

    final completer = Completer<bool>();
    socket.emit('deleteOccupyTime', {"deleteIds": deleteIds});
    socket.once('deleteOccupyTimeReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['reason']);
        }
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      } else {
        completer.complete(true);
      }
    });

    return completer.future;
  }

  Future<void> findOccupyTimeForCheckout(BuildContext context, String occupyId, String patientId, VoidCallback onDone) async {
    BookingInformationProvider bookingInformationProvider = Provider.of<BookingInformationProvider>(context, listen: false);

    socket.emit('findOccupyTimeForCheckout', {"occupyId": occupyId, "patientId": patientId});

    socket.off('findOccupyTimeForCheckoutReturn');
    socket.once('findOccupyTimeForCheckoutReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final checkoutData = data['checkoutData'];
        if (checkoutData is List) {
          final checkOutInformation = OccupyTime.fromMap(checkoutData.first);
          bookingInformationProvider.setOccypyTime(checkOutInformation);
          onDone();
        }
      }
    });
  }

  Future<String> reserveAppointment(
    BuildContext context,
    Map<String, dynamic> serverParams,
    bool updateMyInfo,
    Map<String, dynamic> newProfileInfo,
    String ocuppyId,
  ) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return '';
    final completer = Completer<String>();

    socket.emit('reserveAppointment', {
      "serverParams": serverParams,
      "updateMyInfo": updateMyInfo,
      "newProfileInfo": newProfileInfo,
      "ocuppyId": ocuppyId,
    });
    socket.once('reserveAppointmentReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, '${data['reason']}');
        }
        if (!completer.isCompleted) {
          completer.complete('');
        }
      } else {
        completer.complete(data["newReservationId"]);
      }
    });

    return completer.future;
  }
}
