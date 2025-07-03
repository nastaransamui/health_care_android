import 'package:easy_localization/easy_localization.dart';

import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';

class DoctorsTimeSlot {
  final List<AvailableType> availableSlots;
  final double? averageHourlyPrice;
  final DateTime createDate;
  final String doctorId;
  final bool? isThisMonthAvailable;
  final bool? isThisWeekAvailable;
  final bool? isTodayAvailable;
  final bool? isTommorowAvailable;
  final DateTime updateDate;
  final String? id;
  final int? totalReservation;
  final List<AppointmentReservation>? reservations;

  DoctorsTimeSlot({
    this.id,
    required this.doctorId,
    required this.createDate,
    required this.updateDate,
    required this.availableSlots,
    this.averageHourlyPrice,
    this.isTodayAvailable,
    this.isTommorowAvailable,
    this.isThisWeekAvailable,
    this.isThisMonthAvailable,
    this.totalReservation,
    this.reservations,
  });

  factory DoctorsTimeSlot.fromJson(Map<String, dynamic> json) {
    return DoctorsTimeSlot(
      id: json['_id'],
      doctorId: json['doctorId'],
      createDate: DateTime.parse(json['createDate']),
      updateDate: DateTime.parse(json['updateDate']),
      averageHourlyPrice: (json['averageHourlyPrice'] as num?)?.toDouble(),
      availableSlots: (json['availableSlots'] as List<dynamic>).map((e) => AvailableType.fromJson(e)).toList(),
      isTodayAvailable: json['isTodayAvailable'],
      isTommorowAvailable: json['isTommorowAvailable'],
      isThisWeekAvailable: json['isThisWeekAvailable'],
      isThisMonthAvailable: json['isThisMonthAvailable'],
      totalReservation: json['totalReservation'],
      reservations: (json['reservations'] as List<dynamic>?)?.map((e) => AppointmentReservation.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'doctorId': doctorId,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate.toIso8601String(),
      'availableSlots': availableSlots.map((e) => e.toJson()).toList(),
      'isTodayAvailable': isTodayAvailable,
      'isTommorowAvailable': isTommorowAvailable,
      'isThisWeekAvailable': isThisWeekAvailable,
      'isThisMonthAvailable': isThisMonthAvailable,
      'totalReservation': totalReservation,
      'reservations': reservations?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  static Map<String, dynamic> createJsonForSave(String doctorId, DoctorsTimeSlot slot) {
    return {
      "doctorId": doctorId,
      'createDate': slot.createDate.toIso8601String(),
      'updateDate': slot.updateDate.toIso8601String(),
      'availableSlots': slot.availableSlots.map((e) => e.jsonForCreateDb()).toList(),
    };
  }

    static Map<String, dynamic> createJsonForUpdate(String doctorId, DoctorsTimeSlot slot) {
    return {
      "_id": slot.id,
      "doctorId": doctorId,
      'createDate': slot.createDate.toIso8601String(),
      'updateDate': slot.updateDate.toIso8601String(),
      'availableSlots': slot.availableSlots
        .map((e) => e.jsonForUpdateDb())
        .where((json) => json.isNotEmpty) // Filter out empty JSON objects
        .toList(),
    };
  }

  static Map<String, dynamic> cleanDoctorsTimeSlotJson(DoctorsTimeSlot slot) {
    final json = slot.toJson();

    // Rename 'id' to '_id' if it exists (just to be sure)
    if (json.containsKey('id')) {
      json['_id'] = json['id'];
      json.remove('id');
    }

    // Remove null values from the map
    json.removeWhere((key, value) => value == null);

    return json;
  }

  factory DoctorsTimeSlot.fromMap(Map<String, dynamic> map) {
    return DoctorsTimeSlot(
      id: map['_id'], // If `id` is null in the map, it will be assigned as null
      doctorId: map['doctorId'] ?? '',
      createDate: map['createDate'] != null
          ? DateTime.parse(map['createDate']) // Parse DateTime if not null
          : DateTime.now(), // Default to current DateTime if null
      updateDate: map['updateDate'] != null
          ? DateTime.parse(map['updateDate']) // Parse DateTime if not null
          : DateTime.now(), // Default to current DateTime if null
      availableSlots: map['availableSlots'] != null
          ? List<AvailableType>.from(map['availableSlots']?.map((x) => AvailableType.fromMap(x)) ?? [])
          : [], // If null, default to an empty list
      isTodayAvailable: map['isTodayAvailable'],
      isTommorowAvailable: map['isTommorowAvailable'],
      isThisWeekAvailable: map['isThisWeekAvailable'],
      isThisMonthAvailable: map['isThisMonthAvailable'],
      totalReservation: map['totalReservation'],
      averageHourlyPrice: (map['averageHourlyPrice'] as num?)?.toDouble() ?? 0.0,
      reservations: map['reservations'] != null
          ? List<AppointmentReservation>.from(map['reservations']?.map((x) => AppointmentReservation.fromMap(x)) ?? [])
          : [], // If null, default to an empty list
    );
  }

  @override
  String toString() {
    return 'DoctorsTimeSlot(id: $id, doctorId: $doctorId, createDate: $createDate, updateDate: $updateDate, availableSlots: $availableSlots, isTodayAvailable: $isTodayAvailable, isTommorowAvailable: $isTommorowAvailable, isThisWeekAvailable: $isThisWeekAvailable, isThisMonthAvailable: $isThisMonthAvailable, totalReservation: $totalReservation, reservations: $reservations)';
  }

  DoctorsTimeSlot copyWith({
    String? id,
    String? doctorId,
    DateTime? createDate,
    DateTime? updateDate,
    List<AvailableType>? availableSlots,
    int? totalReservation,
    List<AppointmentReservation>? reservations,
  }) {
    return DoctorsTimeSlot(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      availableSlots: this.availableSlots.map((e) => e.copyWith()).toList(),
      totalReservation: totalReservation ?? this.totalReservation,
      reservations: reservations ?? this.reservations,
    );
  }
}

class AvailableType {
  final List<TimeType> afternoon;
  final List<TimeType> evening;
  final DateTime finishDate;
  final List<TimeType> morning;
  final DateTime startDate;
  final int timeSlot;
  final int? index;
  bool isNew;

  AvailableType({
    required this.afternoon,
    required this.evening,
    required this.finishDate,
    required this.morning,
    required this.startDate,
    required this.timeSlot,
    this.index,
    this.isNew = false,
  });

  factory AvailableType.fromJson(Map<String, dynamic> json) {
    return AvailableType(
      afternoon: (json['afternoon'] as List<dynamic>).map((e) => TimeType.fromJson(e)).toList(),
      evening: (json['evening'] as List<dynamic>).map((e) => TimeType.fromJson(e)).toList(),
      finishDate: DateTime.parse(json['finishDate']),
      morning: (json['morning'] as List<dynamic>).map((e) => TimeType.fromJson(e)).toList(),
      startDate: DateTime.parse(json['startDate']),
      timeSlot: json['timeSlot'],
      index: json['index'] is int ? json['index'] : int.tryParse(json['index'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'afternoon': afternoon.map((e) => e.toJson()).toList(),
      'evening': evening.map((e) => e.toJson()).toList(),
      'finishDate': finishDate.toIso8601String(),
      'morning': morning.map((e) => e.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'timeSlot': timeSlot,
      'index': index,
    };
  }

  Map<String, dynamic> jsonForCreateDb() {
    return {
      'morning': morning.map((e) => e.toJson()).toList(),
      'afternoon': afternoon.map((e) => e.toJson()).toList(),
      'evening': evening.map((e) => e.toJson()).toList(),
      'finishDate': finishDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'timeSlot': timeSlot,
      "index": index,
    };
  }
Map<String, dynamic> jsonForUpdateDb() {
  bool allInactive = morning.every((e) => !e.active) &&
                      afternoon.every((e) => !e.active) &&
                      evening.every((e) => !e.active);

  if (allInactive) {
    return {}; // Return an empty map to represent "nothing"
  } else {
    return {
      'morning': morning.every((e) => !e.active) ? [] : morning.map((e) => e.toJson()).toList(),
      'afternoon': afternoon.every((e) => !e.active) ? [] : afternoon.map((e) => e.toJson()).toList(),
      'evening': evening.every((e) => !e.active) ? [] : evening.map((e) => e.toJson()).toList(),
      'finishDate': finishDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'timeSlot': timeSlot,
      "index": index,
    };
  }
}

  factory AvailableType.fromMap(Map<String, dynamic> map) {
    return AvailableType(
      afternoon: map['afternoon'] != null ? List<TimeType>.from(map['afternoon']?.map((x) => TimeType.fromMap(x)) ?? []) : [],
      evening: map['evening'] != null ? List<TimeType>.from(map['evening']?.map((x) => TimeType.fromMap(x)) ?? []) : [],
      finishDate: map['finishDate'] != null ? DateTime.parse(map['finishDate']) : DateTime.now(), // Default to current DateTime if null
      morning: map['morning'] != null ? List<TimeType>.from(map['morning']?.map((x) => TimeType.fromMap(x)) ?? []) : [],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : DateTime.now(), // Default to current DateTime if null
      timeSlot: map['timeSlot'] ?? 0, // Default to 0 if null
      index: map['index'],
    );
  }

  AvailableType copyWith(
      {List<TimeType>? morning,
      List<TimeType>? afternoon,
      List<TimeType>? evening,
      DateTime? startDate,
      DateTime? finishDate,
      int? timeSlot,
      bool? isNew,
      int? index}) {
    return AvailableType(
      morning: morning ?? this.morning.map((e) => e.copyWith()).toList(),
      afternoon: afternoon ?? this.afternoon.map((e) => e.copyWith()).toList(),
      evening: evening ?? this.evening.map((e) => e.copyWith()).toList(),
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      timeSlot: timeSlot ?? this.timeSlot,
      index: index ?? this.index,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  String toString() {
    return 'AvailableType(afternoon: $afternoon, evening: $evening, finishDate: $finishDate, morning: $morning, startDate: $startDate, timeSlot: $timeSlot, index: $index, isNew: $isNew)';
  }
}

class TimeType {
  final bool active;
  final double bookingsFee;
  final double bookingsFeePrice;
  final String currencySymbol;
  final String? id;
  final bool isReserved;
  final String period;
  final double price;
  final List<AppointmentReservation> reservations;
  final double total;

  TimeType({
    required this.active,
    required this.bookingsFee,
    required this.bookingsFeePrice,
    required this.currencySymbol,
    this.id,
    required this.isReserved,
    required this.period,
    required this.price,
    required this.reservations,
    required this.total,
  });
  factory TimeType.fromJson(Map<String, dynamic> json) {
    return TimeType(
      active: json['active'],
      bookingsFee: json['bookingsFee'].toDouble(),
      bookingsFeePrice: json['bookingsFeePrice'].toDouble(),
      currencySymbol: json['currencySymbol'],
      id: json['id'],
      isReserved: json['isReserved'],
      period: json['period'],
      price: json['price'].toDouble(),
      reservations: (json['reservations'] as List?)
        ?.map((e) => e is AppointmentReservation
            ? e
            : AppointmentReservation.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
      total: json['total'].toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    final data = {
      'active': active,
      'bookingsFee': bookingsFee,
      'bookingsFeePrice': bookingsFeePrice,
      'currencySymbol': currencySymbol,
      'isReserved': isReserved,
      'period': period,
      'price': price,
      'reservations': reservations, // or serialize if needed
      'total': total,
      // Don't include 'id' if null
    };

    if (id != null) {
      data['id'] = id!;
    }

    return data;
  }

  factory TimeType.fromMap(Map<String, dynamic> map) {
    return TimeType(
      active: map['active'] ?? false, // Default to false if null
      bookingsFee: map['bookingsFee']?.toDouble() ?? 0.0, // Default to 0.0 if null
      bookingsFeePrice: map['bookingsFeePrice']?.toDouble() ?? 0.0, // Default to 0.0 if null
      currencySymbol: map['currencySymbol'] ?? '', // Default to empty string if null
      id: map['id'],
      isReserved: map['isReserved'] ?? false, // Default to false if null
      period: map['period'] ?? '', // Default to empty string if null
      price: map['price']?.toDouble() ?? 0.0, // Default to 0.0 if null
      reservations:
          map['reservations'] != null ? List<AppointmentReservation>.from(map['reservations']?.map((x) => AppointmentReservation.fromMap(x))) : [],
      total: map['total']?.toDouble() ?? 0.0, // Default to 0.0 if null
    );
  }

  static List<TimeType> generateTimeSlots({
    required int startHour,
    required int totalHours,
    required int slotDuration,
    required DoctorUserProfile userProfile,
  }) {
    final numSlots = totalHours ~/ slotDuration;
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');

    return List.generate(numSlots, (index) {
      final startTime = DateTime(now.year, now.month, now.day, startHour).add(Duration(minutes: slotDuration * index));
      final endTime = DateTime(now.year, now.month, now.day, startHour).add(Duration(minutes: slotDuration * (index + 1)));

      return TimeType(
        active: false,
        period: '${formatter.format(startTime)} - ${formatter.format(endTime)}',
        isReserved: false,
        price: 0,
        bookingsFee: userProfile.bookingsFee,
        bookingsFeePrice: 0,
        total: 0,
        currencySymbol: userProfile.currency.first.currency,
        reservations: [],
      );
    });
  }

  @override
  String toString() {
    return 'TimeType(active: $active, bookingsFee: $bookingsFee, bookingsFeePrice: $bookingsFeePrice, currencySymbol: $currencySymbol, id: $id, isReserved: $isReserved, period: $period, price: $price, reservations: $reservations, total: $total, )';
  }

  TimeType copyWith({
    bool? active,
    double? bookingsFee,
    double? bookingsFeePrice,
    String? currencySymbol,
    String? id,
    bool? isReserved,
    String? period,
    double? price,
    List<AppointmentReservation>? reservations,
    double? total,
  }) {
    return TimeType(
      active: active ?? this.active,
      bookingsFee: bookingsFee ?? this.bookingsFee,
      bookingsFeePrice: bookingsFeePrice ?? this.bookingsFeePrice,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      id: id ?? this.id,
      isReserved: isReserved ?? this.isReserved,
      period: period ?? this.period,
      price: price ?? this.price,
      reservations: reservations ?? this.reservations,
      total: total ?? this.total,
    );
  }
}
