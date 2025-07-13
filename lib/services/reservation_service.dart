import 'package:flutter/widgets.dart';
import 'package:health_care/models/reservation.dart';
import 'package:health_care/providers/reservation_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class ReservationService {
  Future<void> findReservationById(
    BuildContext context,
    String reservationId,
    VoidCallback onDone,
  ) async {
    ReservationProvider reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    void findReservationByIdWithUpdate() {
      socket.emit('findReservationById', {"_id": reservationId});
    }

    socket.off('findReservationByIdReturn');
    socket.on('findReservationByIdReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final reservationData = data['reservation'];

        final reservation = Reservation.fromMap(reservationData);
        reservationProvider.setReservation(reservation);
        onDone();
      }
    });

    socket.off("updateReservationById");
    socket.on("updateReservationById", (_) => findReservationByIdWithUpdate());

    findReservationByIdWithUpdate();
  }
}
