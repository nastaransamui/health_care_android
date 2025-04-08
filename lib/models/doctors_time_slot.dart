import 'package:health_care/models/appointment_reservation.dart';

class DoctorsTimeSlot {
  final String? id;
  final String doctorId;
  final DateTime createDate;
  final DateTime updateDate;
  final List<AvailableType> availableSlots;
  final bool? isTodayAvailable;
  final bool? isTommorowAvailable;
  final bool? isThisWeekAvailable;
  final bool? isThisMonthAvailable;
  final int? totalReservation;
  final List<AppointmentReservation>? reservations;

  DoctorsTimeSlot({
    this.id,
    required this.doctorId,
    required this.createDate,
    required this.updateDate,
    required this.availableSlots,
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

  factory DoctorsTimeSlot.fromMap(Map<String, dynamic> map) {
    return DoctorsTimeSlot(
      id: map['id'], // If `id` is null in the map, it will be assigned as null
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
      reservations: map['reservations'] != null
          ? List<AppointmentReservation>.from(map['reservations']?.map((x) => AppointmentReservation.fromMap(x)) ?? [])
          : [], // If null, default to an empty list
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

  AvailableType({
    required this.afternoon,
    required this.evening,
    required this.finishDate,
    required this.morning,
    required this.startDate,
    required this.timeSlot,
    this.index,
  });

  factory AvailableType.fromJson(Map<String, dynamic> json) {
    return AvailableType(
      afternoon: (json['afternoon'] as List<dynamic>).map((e) => TimeType.fromJson(e)).toList(),
      evening: (json['evening'] as List<dynamic>).map((e) => TimeType.fromJson(e)).toList(),
      finishDate: DateTime.parse(json['finishDate']),
      morning: (json['morning'] as List<dynamic>).map((e) => TimeType.fromJson(e)).toList(),
      startDate: DateTime.parse(json['startDate']),
      timeSlot: json['timeSlot'],
      index: json['index'],
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

  factory AvailableType.fromMap(Map<String, dynamic> map) {
  return AvailableType(
    afternoon: map['afternoon'] != null
        ? List<TimeType>.from(
            map['afternoon']?.map((x) => TimeType.fromMap(x)) ?? [])
        : [],
    evening: map['evening'] != null
        ? List<TimeType>.from(
            map['evening']?.map((x) => TimeType.fromMap(x)) ?? [])
        : [],
    finishDate: map['finishDate'] != null
        ? DateTime.parse(map['finishDate'])
        : DateTime.now(), // Default to current DateTime if null
    morning: map['morning'] != null
        ? List<TimeType>.from(
            map['morning']?.map((x) => TimeType.fromMap(x)) ?? [])
        : [],
    startDate: map['startDate'] != null
        ? DateTime.parse(map['startDate'])
        : DateTime.now(), // Default to current DateTime if null
    timeSlot: map['timeSlot'] ?? 0, // Default to 0 if null
    index: map['index'],
  );
}
}

class TimeType {
  final bool active;
  final double bookingsFee;
  final double bookingsFeePrice;
  final double? bookingsFeePriceSystem;
  final String currencySymbol;
  final Map<String, double>? exchangeRate;
  final String? id;
  final bool isReserved;
  final String period;
  final double price;
  final double? priceSystem;
  final List<AppointmentReservation> reservations;
  final double total;
  final double? totalSystem;

  TimeType({
    required this.active,
    required this.bookingsFee,
    required this.bookingsFeePrice,
    this.bookingsFeePriceSystem,
    required this.currencySymbol,
    this.exchangeRate,
    this.id,
    required this.isReserved,
    required this.period,
    required this.price,
    this.priceSystem,
    required this.reservations,
    required this.total,
    this.totalSystem,
  });
  factory TimeType.fromJson(Map<String, dynamic> json) {
    return TimeType(
      active: json['active'],
      bookingsFee: json['bookingsFee'].toDouble(),
      bookingsFeePrice: json['bookingsFeePrice'].toDouble(),
      bookingsFeePriceSystem: json['bookingsFeePriceSystem']?.toDouble(),
      currencySymbol: json['currencySymbol'],
      exchangeRate: (json['exchangeRate'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toDouble()),
      ),
      id: json['id'],
      isReserved: json['isReserved'],
      period: json['period'],
      price: json['price'].toDouble(),
      priceSystem: json['priceSystem']?.toDouble(),
      reservations: (json['reservations'] as List<dynamic>?)
            ?.map((e) => AppointmentReservation.fromJson(e))
            .toList() ??
        [],
      total: json['total'].toDouble(),
      totalSystem: json['totalSystem']?.toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'bookingsFee': bookingsFee,
      'bookingsFeePrice': bookingsFeePrice,
      'bookingsFeePriceSystem': bookingsFeePriceSystem,
      'currencySymbol': currencySymbol,
      'exchangeRate': exchangeRate,
      'id': id,
      'isReserved': isReserved,
      'period': period,
      'price': price,
      'priceSystem': priceSystem,
      'reservations': reservations.map((e) => e.toJson()).toList(),
      'total': total,
      'totalSystem': totalSystem,
    };
  }

  factory TimeType.fromMap(Map<String, dynamic> map) {
  return TimeType(
    active: map['active'] ?? false, // Default to false if null
    bookingsFee: map['bookingsFee']?.toDouble() ?? 0.0, // Default to 0.0 if null
    bookingsFeePrice: map['bookingsFeePrice']?.toDouble() ?? 0.0, // Default to 0.0 if null
    bookingsFeePriceSystem: map['bookingsFeePriceSystem']?.toDouble(),
    currencySymbol: map['currencySymbol'] ?? '', // Default to empty string if null
    exchangeRate: map['exchangeRate'] != null
        ? Map<String, double>.from(map['exchangeRate'])
        : null,
    id: map['id'],
    isReserved: map['isReserved'] ?? false, // Default to false if null
    period: map['period'] ?? '', // Default to empty string if null
    price: map['price']?.toDouble() ?? 0.0, // Default to 0.0 if null
    priceSystem: map['priceSystem']?.toDouble(),
    reservations: map['reservations'] != null
        ? List<AppointmentReservation>.from(
            map['reservations']?.map((x) => AppointmentReservation.fromMap(x)))
        : [],
    total: map['total']?.toDouble() ?? 0.0, // Default to 0.0 if null
    totalSystem: map['totalSystem']?.toDouble(),
  );
}
}
