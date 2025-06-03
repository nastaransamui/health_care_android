import 'dart:convert';

import 'package:flutter/foundation.dart';

class BankData {
  final String id;
  final String userId;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String accountName;
  final String swiftCode;
  final String bICcode;
  final dynamic createdAt;
  final dynamic updateAt;

  BankData({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.accountName,
    required this.swiftCode,
    required this.bICcode,
    required this.createdAt,
    required this.updateAt,
  });

  BankData copyWith({
    String? id,
    String? userId,
    String? bankName,
    String? branchName,
    String? accountNumber,
    String? accountName,
    String? swiftCode,
    String? bICcode,
    DateTime? createdAt,
    DateTime? updateAt,
  }) {
    return BankData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      swiftCode: swiftCode ?? this.swiftCode,
      bICcode: bICcode ?? this.bICcode,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'userId': userId});
    result.addAll({'bankName': bankName});
    result.addAll({'branchName': branchName});
    result.addAll({'accountNumber': accountNumber});
    result.addAll({'accountName': accountName});
    result.addAll({'swiftCode': swiftCode});
    result.addAll({'bICcode': bICcode});
    result.addAll({'createdAt': createdAt});
    result.addAll({'updateAt': updateAt});

    return result;
  }

  factory BankData.fromMap(Map<String, dynamic> map) {
    return BankData(
      id: map['_id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      bankName: map['bankName']?.toString() ?? '',
      branchName: map['branchName']?.toString() ?? '',
      accountNumber: map['accountNumber']?.toString() ?? '',
      accountName: map['accountName']?.toString() ?? '',
      swiftCode: map['swiftCode']?.toString() ?? '',
      bICcode: map['BICcode']?.toString() ?? '',
      createdAt: (map['createdAt'] == null || map['createdAt'] == '') ? '' : DateTime.parse(map['createdAt']),
      updateAt: (map['updateAt'] == null || map['updateAt'] == '') ? '' : DateTime.parse(map['updateAt']),
    );
  }

  factory BankData.empty() {
    return BankData(
      id: '',
      userId: '',
      bankName: '',
      branchName: '',
      accountNumber: '',
      accountName: '',
      swiftCode: '',
      bICcode: '',
      createdAt: '',
      updateAt: '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BankData.fromJson(String source) => BankData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Bank(id: $id, userId: $userId, bankName: $bankName, branchName: $branchName, accountNumber: $accountNumber, accountName: $accountName, swiftCode: $swiftCode, bICcode: $bICcode, createdAt: $createdAt, updateAt: $updateAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BankData &&
        other.id == id &&
        other.userId == userId &&
        other.bankName == bankName &&
        other.branchName == branchName &&
        other.accountNumber == accountNumber &&
        other.accountName == accountName &&
        other.swiftCode == swiftCode &&
        other.bICcode == bICcode &&
        other.createdAt == createdAt &&
        other.updateAt == updateAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        bankName.hashCode ^
        branchName.hashCode ^
        accountNumber.hashCode ^
        accountName.hashCode ^
        swiftCode.hashCode ^
        bICcode.hashCode ^
        createdAt.hashCode ^
        updateAt.hashCode;
  }
}

class ReservationsValueInners {
  final double totalAmount;
  final double totalPrice;
  final double totalBookingsFeePrice;
  final int totalBookings;

  ReservationsValueInners({
    required this.totalAmount,
    required this.totalPrice,
    required this.totalBookingsFeePrice,
    required this.totalBookings,
  });

  ReservationsValueInners copyWith({
    double? totalAmount,
    double? totalPrice,
    double? totalBookingsFeePrice,
    int? totalBookings,
  }) {
    return ReservationsValueInners(
      totalAmount: totalAmount ?? this.totalAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      totalBookingsFeePrice: totalBookingsFeePrice ?? this.totalBookingsFeePrice,
      totalBookings: totalBookings ?? this.totalBookings,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'totalAmount': totalAmount});
    result.addAll({'totalPrice': totalPrice});
    result.addAll({'totalBookingsFeePrice': totalBookingsFeePrice});
    result.addAll({'totalBookings': totalBookings});

    return result;
  }

  factory ReservationsValueInners.fromMap(Map<String, dynamic> map) {
    return ReservationsValueInners(
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      totalBookingsFeePrice: map['totalBookingsFeePrice']?.toDouble() ?? 0.0,
      totalBookings: map['totalBookings']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReservationsValueInners.fromJson(String source) => ReservationsValueInners.fromMap(json.decode(source));

  factory ReservationsValueInners.empty() {
    return ReservationsValueInners(totalAmount: 0, totalPrice: 0, totalBookingsFeePrice: 0, totalBookings: 0);
  }
  @override
  String toString() {
    return 'ReservationsValueInners(totalAmount: $totalAmount, totalPrice: $totalPrice, totalBookingsFeePrice: $totalBookingsFeePrice, totalBookings: $totalBookings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReservationsValueInners &&
        other.totalAmount == totalAmount &&
        other.totalPrice == totalPrice &&
        other.totalBookingsFeePrice == totalBookingsFeePrice &&
        other.totalBookings == totalBookings;
  }

  @override
  int get hashCode {
    return totalAmount.hashCode ^ totalPrice.hashCode ^ totalBookingsFeePrice.hashCode ^ totalBookings.hashCode;
  }
}

class BillingsValueInners {
  final double totalAmount;
  final double totalPrice;
  final double totalBookingsFeePrice;
  final int totalBillings;

  BillingsValueInners({
    required this.totalAmount,
    required this.totalPrice,
    required this.totalBookingsFeePrice,
    required this.totalBillings,
  });

  BillingsValueInners copyWith({
    double? totalAmount,
    double? totalPrice,
    double? totalBookingsFeePrice,
    int? totalBillings,
  }) {
    return BillingsValueInners(
      totalAmount: totalAmount ?? this.totalAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      totalBookingsFeePrice: totalBookingsFeePrice ?? this.totalBookingsFeePrice,
      totalBillings: totalBillings ?? this.totalBillings,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'totalAmount': totalAmount});
    result.addAll({'totalPrice': totalPrice});
    result.addAll({'totalBookingsFeePrice': totalBookingsFeePrice});
    result.addAll({'totalBillings': totalBillings});

    return result;
  }

  factory BillingsValueInners.fromMap(Map<String, dynamic> map) {
    return BillingsValueInners(
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      totalBookingsFeePrice: map['totalBookingsFeePrice']?.toDouble() ?? 0.0,
      totalBillings: map['totalBillings']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BillingsValueInners.fromJson(String source) => BillingsValueInners.fromMap(json.decode(source));

  factory BillingsValueInners.empty() {
    return BillingsValueInners(totalAmount: 0, totalPrice: 0, totalBookingsFeePrice: 0, totalBillings: 0);
  }
  @override
  String toString() {
    return 'BillingsValueInners(totalAmount: $totalAmount, totalPrice: $totalPrice, totalBookingsFeePrice: $totalBookingsFeePrice, totalBillings: $totalBillings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BillingsValueInners &&
        other.totalAmount == totalAmount &&
        other.totalPrice == totalPrice &&
        other.totalBookingsFeePrice == totalBookingsFeePrice &&
        other.totalBillings == totalBillings;
  }

  @override
  int get hashCode {
    return totalAmount.hashCode ^ totalPrice.hashCode ^ totalBookingsFeePrice.hashCode ^ totalBillings.hashCode;
  }
}

class ReservationTotalsType {
  final ReservationsValueInners? awaitingRequest;
  final ReservationsValueInners? pending;
  final ReservationsValueInners? paid;
  final int totalReservations;

  ReservationTotalsType({
    this.awaitingRequest,
    this.pending,
    this.paid,
    required this.totalReservations,
  });

  ReservationTotalsType copyWith({
    ReservationsValueInners? awaitingRequest,
    ReservationsValueInners? pending,
    ReservationsValueInners? paid,
    int? totalReservations,
  }) {
    return ReservationTotalsType(
      awaitingRequest: awaitingRequest ?? this.awaitingRequest,
      pending: pending ?? this.pending,
      paid: paid ?? this.paid,
      totalReservations: totalReservations ?? this.totalReservations,
    );
  }

Map<String, dynamic> toMap() {
  return {
    'awaitingRequest': ((awaitingRequest ?? ReservationsValueInners.empty) as ReservationsValueInners).toMap(),
    'pending': ((pending ?? ReservationsValueInners.empty) as ReservationsValueInners).toMap(),
    'paid': ((paid ?? ReservationsValueInners.empty) as ReservationsValueInners).toMap(),
    'totalReservations': totalReservations,
  };
}

  factory ReservationTotalsType.fromMap(Map<String, dynamic> map) {
    return ReservationTotalsType(
      awaitingRequest: map['awaitingRequest'] != null ? ReservationsValueInners.fromMap(map['awaitingRequest']) : null,
      pending: map['pending'] != null ? ReservationsValueInners.fromMap(map['pending']) : null,
      paid: map['paid'] != null ? ReservationsValueInners.fromMap(map['paid']) : null,
      totalReservations: map['totalReservations']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReservationTotalsType.fromJson(String source) => ReservationTotalsType.fromMap(json.decode(source));

  factory ReservationTotalsType.empty() {
    return ReservationTotalsType(
      totalReservations: 0,
      awaitingRequest: ReservationsValueInners(totalAmount: 0, totalPrice: 0, totalBookingsFeePrice: 0, totalBookings: 0),
      pending: ReservationsValueInners(totalAmount: 0, totalPrice: 0, totalBookingsFeePrice: 0, totalBookings: 0),
      paid: ReservationsValueInners(totalAmount: 0, totalPrice: 0, totalBookingsFeePrice: 0, totalBookings: 0),
    );
  }

  @override
  String toString() {
    return 'ReservationTotalsType(awaitingRequest: $awaitingRequest, pending: $pending, paid: $paid, totalReservations: $totalReservations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReservationTotalsType &&
        other.awaitingRequest == awaitingRequest &&
        other.pending == pending &&
        other.paid == paid &&
        other.totalReservations == totalReservations;
  }

  @override
  int get hashCode {
    return awaitingRequest.hashCode ^ pending.hashCode ^ paid.hashCode ^ totalReservations.hashCode;
  }
}

class BillingsTotalsType {
  final BillingsValueInners? pending;
  final BillingsValueInners? paid;
  final int totalBillings;

  BillingsTotalsType({
    this.pending,
    this.paid,
    required this.totalBillings,
  });

  BillingsTotalsType copyWith({
    BillingsValueInners? pending,
    BillingsValueInners? paid,
    int? totalBillings,
  }) {
    return BillingsTotalsType(
      pending: pending ?? this.pending,
      paid: paid ?? this.paid,
      totalBillings: totalBillings ?? this.totalBillings,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (pending != null) {
      result.addAll({'pending': pending!.toMap()});
    }
    if (paid != null) {
      result.addAll({'paid': paid!.toMap()});
    }
    result.addAll({'totalBillings': totalBillings});

    return result;
  }

  factory BillingsTotalsType.fromMap(Map<String, dynamic> map) {
    return BillingsTotalsType(
      pending: map['pending'] != null ? BillingsValueInners.fromMap(map['pending']) : null,
      paid: map['paid'] != null ? BillingsValueInners.fromMap(map['paid']) : null,
      totalBillings: map['totalBillings']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BillingsTotalsType.fromJson(String source) => BillingsTotalsType.fromMap(json.decode(source));

  factory BillingsTotalsType.empty() {
    return BillingsTotalsType(
      totalBillings: 0,
      paid: BillingsValueInners(totalAmount: 0, totalPrice: 0, totalBookingsFeePrice: 0, totalBillings: 0),
      pending: BillingsValueInners(totalAmount: 0, totalPrice: 0, totalBookingsFeePrice: 0, totalBillings: 0),
    );
  }

  @override
  String toString() => 'BillingsTotalsType(pending: $pending, paid: $paid, totalBillings: $totalBillings)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BillingsTotalsType && other.pending == pending && other.paid == paid && other.totalBillings == totalBillings;
  }

  @override
  int get hashCode => pending.hashCode ^ paid.hashCode ^ totalBillings.hashCode;
}

class BankWithReservations {
  final BankData bankData;
  final List<ReservationTotalsType> reservationsAndTotals;
  final List<BillingsTotalsType> billingsAndTotals;

  BankWithReservations({
    required this.bankData,
    required this.reservationsAndTotals,
    required this.billingsAndTotals,
  });

  BankWithReservations copyWith({
    BankData? bankData,
    List<ReservationTotalsType>? reservationsAndTotals,
    List<BillingsTotalsType>? billingsAndTotals,
  }) {
    return BankWithReservations(
      bankData: bankData ?? this.bankData,
      reservationsAndTotals: reservationsAndTotals ?? this.reservationsAndTotals,
      billingsAndTotals: billingsAndTotals ?? this.billingsAndTotals,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'bankData': bankData.toMap()});
    result.addAll({'reservationsAndTotals': reservationsAndTotals.map((x) => x.toMap()).toList()});
    result.addAll({'billingsAndTotals': billingsAndTotals.map((x) => x.toMap()).toList()});

    return result;
  }

  factory BankWithReservations.fromMap(Map<String, dynamic> map) {
    return BankWithReservations(
      reservationsAndTotals: List<ReservationTotalsType>.from(
        map['reservationsAndTotals']?.map((x) {
          final totals = x['totals'] ?? {};
          return ReservationTotalsType(
            pending: totals['Pending'] != null ? 
            ReservationsValueInners.fromMap(totals['Pending']) : 
            ReservationsValueInners.empty(),
            awaitingRequest: totals['AwaitingRequest'] != null ? ReservationsValueInners.fromMap(totals['AwaitingRequest']) : ReservationsValueInners.empty(),
            paid: totals['Paid'] != null ? ReservationsValueInners.fromMap(totals['Paid']) : ReservationsValueInners.empty(),
            totalReservations: x['totalReservations'] ?? 0,
          );
        }) ?? [],
      ),
      billingsAndTotals: List<BillingsTotalsType>.from(
        map['billingsAndTotals']?.map((x) {
          final totals = x['totals'] ?? {};
          return BillingsTotalsType(
            pending: totals['Pending'] != null ? BillingsValueInners.fromMap(totals['Pending']) : BillingsValueInners.empty(),
            paid: totals['Paid'] != null ? BillingsValueInners.fromMap(totals['Paid']) : BillingsValueInners.empty(),
            totalBillings: x['totalBillings'] ?? 0,
          );
        }) ?? [],
      ),
      bankData: map['bankData'] != null && map['bankData'] is Map
          ? BankData.fromMap(map['bankData'])
          : BankData.empty(),
    );
  }

  String toJson() => json.encode(toMap());

  factory BankWithReservations.fromJson(String source) => BankWithReservations.fromMap(json.decode(source));

  factory BankWithReservations.empty() {
    return BankWithReservations(
      bankData: BankData.empty(),
      reservationsAndTotals: [ReservationTotalsType.empty()],
      billingsAndTotals: [BillingsTotalsType.empty()],
    );
  }

  @override
  String toString() =>
      'BankWithReservations(bankData: $bankData, reservationsAndTotals: $reservationsAndTotals, billingsAndTotals: $billingsAndTotals)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BankWithReservations &&
        other.bankData == bankData &&
        listEquals(other.reservationsAndTotals, reservationsAndTotals) &&
        listEquals(other.billingsAndTotals, billingsAndTotals);
  }

  @override
  int get hashCode => bankData.hashCode ^ reservationsAndTotals.hashCode ^ billingsAndTotals.hashCode;
}
