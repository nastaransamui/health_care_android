
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class PatientAppointmentReservation {
  final String id;
  final int appointmentId;
  final TimeType timeSlot;
  final DateTime selectedDate;
  final String dayPeriod;
  final String doctorId;
  final DateTime startDate;
  final DateTime finishDate;
  final String slotId;
  final String patientId;
  final String paymentToken;
  final String paymentType;
  final String invoiceId;
  final String doctorPaymentStatus;
  final dynamic paymentDate;
  final DateTime createdDate;
  final DoctorUserProfile doctorProfile;

  PatientAppointmentReservation({
    required this.id,
    required this.appointmentId,
    required this.timeSlot,
    required this.selectedDate,
    required this.dayPeriod,
    required this.doctorId,
    required this.startDate,
    required this.finishDate,
    required this.slotId,
    required this.patientId,
    required this.paymentToken,
    required this.paymentType,
    required this.invoiceId,
    required this.doctorPaymentStatus,
    this.paymentDate,
    required this.createdDate,
    required this.doctorProfile,
  });

  factory PatientAppointmentReservation.fromJson(Map<String, dynamic> json) {
    dynamic rawProfile = json['doctorProfile'];

    DoctorUserProfile profile = DoctorUserProfile.empty();

    if (rawProfile != null) {
      if (rawProfile is String) {
        try {
          profile = DoctorUserProfile.stringToJson(rawProfile); // it's a JSON string
        // ignore: empty_catches
        } catch (e) {}
      } else if (rawProfile is Map<String, dynamic>) {
        try {
          profile = DoctorUserProfile.fromMap(rawProfile);
        // ignore: empty_catches
        } catch (e) {}
      } 
    }
    return PatientAppointmentReservation(
      id: json['_id'],
      appointmentId: json['id'],
      timeSlot: TimeType.fromJson(json['timeSlot']),
      selectedDate: DateTime.parse(json['selectedDate']),
      dayPeriod: json['dayPeriod'],
      doctorId: json['doctorId'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      slotId: json['slotId'],
      patientId: json['patientId'],
      paymentToken: json['paymentToken'],
      paymentType: json['paymentType'],
      invoiceId: json['invoiceId'],
      doctorPaymentStatus: json['doctorPaymentStatus'],
      paymentDate: json['paymentDate'] != "" ? DateTime.parse(json['paymentDate']) : '',
      createdDate: DateTime.parse(json['createdDate']),
      doctorProfile: profile,
    );
  }

  factory PatientAppointmentReservation.empty() {
    return PatientAppointmentReservation(
      id: '',
      appointmentId: 0,
      timeSlot: TimeType(
        active: false,
        bookingsFee: 0,
        bookingsFeePrice: 0,
        currencySymbol: '',
        isReserved: false,
        period: '',
        price: 0,
        reservations: [],
        total: 0,
      ),
      selectedDate: DateTime.now(),
      dayPeriod: '',
      doctorId: '',
      startDate: DateTime.now(),
      finishDate: DateTime.now(),
      slotId: '',
      patientId: '',
      paymentToken: '',
      paymentType: '',
      invoiceId: '',
      doctorPaymentStatus: '',
      createdDate: DateTime.now(),
      doctorProfile: DoctorUserProfile.empty(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': appointmentId,
      'timeSlot': timeSlot.toJson(),
      'selectedDate': selectedDate.toIso8601String(),
      'dayPeriod': dayPeriod,
      'doctorId': doctorId,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'slotId': slotId,
      'patientId': patientId,
      'paymentToken': paymentToken,
      'paymentType': paymentType,
      'invoiceId': invoiceId,
      'doctorPaymentStatus': doctorPaymentStatus,
      'paymentDate': paymentDate?.toIso8601String() ?? "",
      'createdDate': createdDate.toIso8601String(),
      'patientProfile': doctorProfile.toJson(),
    };
  }

  factory PatientAppointmentReservation.fromMap(Map<String, dynamic> map) {
    return PatientAppointmentReservation(
      id: map['_id'],
      appointmentId: map['id'] ?? 0, // Default to 0 if null
      timeSlot: TimeType.fromMap(map['timeSlot'] ?? {}),
      selectedDate: map['selectedDate'] != null ? DateTime.parse(map['selectedDate']) : DateTime.now(),
      dayPeriod: map['dayPeriod'] ?? '', // Default to empty string if null
      doctorId: map['doctorId'] ?? '', // Default to empty string if null
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : DateTime.now(),
      finishDate: map['finishDate'] != null ? DateTime.parse(map['finishDate']) : DateTime.now(),
      slotId: map['slotId'] ?? '', // Default to empty string if null
      patientId: map['patientId'] ?? '', // Default to empty string if null
      paymentToken: map['paymentToken'] ?? '', // Default to empty string if null
      paymentType: map['paymentType'] ?? '', // Default to empty string if null
      invoiceId: map['invoiceId'] ?? '', // Default to empty string if null
      doctorPaymentStatus: map['doctorPaymentStatus'] ?? "Pending", // Default to pending if null
      paymentDate: map['paymentDate'],
      createdDate: map['createdDate'] != null ? DateTime.parse(map['createdDate']) : DateTime.now(),
      doctorProfile: DoctorUserProfile.fromMap(map['doctorProfile']),
    );
  }

  @override
  String toString() {
    return 'AppointmentReservation(id: $id, appointmentId: $appointmentId, timeSlot: $timeSlot, selectedDate: $selectedDate, dayPeriod: $dayPeriod, doctorId: $doctorId, startDate: $startDate, finishDate: $finishDate, slotId: $slotId, patientId: $patientId, paymentToken: $paymentToken, paymentType: $paymentType, invoiceId: $invoiceId, doctorPaymentStatus: $doctorPaymentStatus, paymentDate: $paymentDate, createdDate: $createdDate, doctorProfile: $doctorProfile)';
  }
}


PatientAppointmentReservation convertRowToAppointment(DataGridRow row) {
  T getValue<T>(String name) => row.getCells().firstWhere((e) => e.columnName == name).value as T;

  final selectedDateMap = getValue<Map<String, dynamic>>('selectedDate');
  final priceMap = getValue<Map<String, dynamic>>('timeSlot.price');
  final bookingsFeePriceMap = getValue<Map<String, dynamic>>('timeSlot.bookingsFeePrice');
  final totalMap = getValue<Map<String, dynamic>>('timeSlot.total');
  final invoiceMap = getValue<Map<String, dynamic>>('invoiceId');

  return PatientAppointmentReservation(
    id: getValue<String>('select'),
    appointmentId: getValue<int>('id'),
    createdDate: getValue<DateTime>('createdDate'),
    dayPeriod: getValue<String>('dayPeriod'),
    selectedDate: selectedDateMap['date'] as DateTime,
    timeSlot: TimeType(
      active: true, // Use real value if available
      bookingsFee: getValue<double>('timeSlot.bookingsFee'),
      bookingsFeePrice: bookingsFeePriceMap['bookingsFeePrice'],
      currencySymbol: priceMap['currencySymbol'],
      id: null,
      isReserved: false, // Use real value if available
      period: selectedDateMap['period'],
      price: priceMap['price'],
      reservations: const [],
      total: totalMap['total'],
    ),
    invoiceId: invoiceMap['invoiceId'],
    paymentType: getValue<String>('paymentType'),
    paymentToken: getValue<String>('paymentToken'),
    paymentDate: getValue<dynamic>('paymentDate'),
    doctorProfile: getValue<DoctorUserProfile>('doctorProfile.fullName'),

    // Below fields are not available in the grid row but required in the model
    doctorId: '', // You may need to extend the grid to include this
    slotId: '',
    patientId: '',
    doctorPaymentStatus: getValue<String>('doctorPaymentStatus'),
    startDate: DateTime.now(), // Dummy, override if needed
    finishDate: DateTime.now(), // Dummy, override if needed
  );
}
