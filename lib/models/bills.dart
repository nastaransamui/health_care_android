import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:health_care/models/users.dart';

class Bills {
  final String id;
  final int billId;
  final String doctorId;
  final String patientId;
  final double price;
  final double bookingsFee;
  final double bookingsFeePrice;
  final double total;
  final String currencySymbol;
  final String paymentToken;
  final String paymentType;
  final List<BillingsDetails> billDetailsArray;
  final DateTime createdAt;
  final DateTime updateAt;
  final String status;
  final String invoiceId;
  final dynamic paymentDate;
  final DateTime dueDate;
  final PatientUserProfile patientProfile;
  final DoctorUserProfile doctorProfile;

  Bills({
    required this.id,
    required this.billId,
    required this.doctorId,
    required this.patientId,
    required this.price,
    required this.bookingsFee,
    required this.bookingsFeePrice,
    required this.total,
    required this.currencySymbol,
    required this.paymentToken,
    required this.paymentType,
    required this.billDetailsArray,
    required this.createdAt,
    required this.updateAt,
    required this.status,
    required this.invoiceId,
    required this.paymentDate,
    required this.dueDate,
    required this.doctorProfile,
    required this.patientProfile,
  });

  Bills copyWith({
    String? id,
    int? billId,
    String? doctorId,
    String? patientId,
    double? price,
    double? bookingsFee,
    double? bookingsFeePrice,
    double? total,
    String? currencySymbol,
    String? paymentToken,
    String? paymentType,
    List<BillingsDetails>? billDetailsArray,
    DateTime? createdAt,
    DateTime? updateAt,
    String? status,
    String? invoiceId,
    dynamic paymentDate,
    DateTime? dueDate,
    DoctorUserProfile? doctorProfile,
    PatientUserProfile? patientProfile,
  }) {
    return Bills(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      price: price ?? this.price,
      bookingsFee: bookingsFee ?? this.bookingsFee,
      bookingsFeePrice: bookingsFeePrice ?? this.bookingsFeePrice,
      total: total ?? this.total,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      paymentToken: paymentToken ?? this.paymentToken,
      paymentType: paymentType ?? this.paymentType,
      billDetailsArray: billDetailsArray ?? this.billDetailsArray,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
      status: status ?? this.status,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentDate: paymentDate ?? this.paymentDate,
      dueDate: dueDate ?? this.dueDate,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      patientProfile: patientProfile ?? this.patientProfile,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'billId': billId});
    result.addAll({'doctorId': doctorId});
    result.addAll({'patientId': patientId});
    result.addAll({'price': price});
    result.addAll({'bookingsFee': bookingsFee});
    result.addAll({'bookingsFeePrice': bookingsFeePrice});
    result.addAll({'total': total});
    result.addAll({'currencySymbol': currencySymbol});
    result.addAll({'paymentToken': paymentToken});
    result.addAll({'paymentType': paymentType});
    result.addAll({'billDetailsArray': billDetailsArray.map((x) => x.toMap()).toList()});
    result.addAll({'createdAt': createdAt});
    result.addAll({'updateAt': updateAt});
    result.addAll({'status': status});
    result.addAll({'invoiceId': invoiceId});
    result.addAll({'paymentDate': paymentDate});
    result.addAll({'dueDate': dueDate});
    result.addAll({'patientProfile': patientProfile});
    result.addAll({'doctorProfile': doctorProfile});

    return result;
  }

  factory Bills.fromMap(Map<String, dynamic> map) {
    return Bills(
      id: map['_id']?.toString() ?? '', // safer: cast to string or default
      billId: map['id']?.toInt() ?? 0,
      doctorId: map['doctorId']?.toString() ?? '',
      patientId: map['patientId']?.toString() ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      bookingsFee: map['bookingsFee']?.toDouble() ?? 0.0,
      bookingsFeePrice: map['bookingsFeePrice']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      currencySymbol: map['currencySymbol']?.toString() ?? '',
      paymentToken: map['paymentToken']?.toString() ?? '',
      paymentType: map['paymentType']?.toString() ?? '',
      billDetailsArray: List<BillingsDetails>.from(
        (map['billDetailsArray'] ?? []).map((x) => BillingsDetails.fromMap(x)),
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updateAt: DateTime.tryParse(map['updateAt'] ?? '') ?? DateTime.now(),
      status: map['status']?.toString() ?? '',
      invoiceId: map['invoiceId']?.toString() ?? '',
      paymentDate: map['paymentDate'] != null && map['paymentDate'] != '' ? DateTime.tryParse(map['paymentDate']) ?? '' : '',
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      doctorProfile: DoctorUserProfile.fromMap(map['doctorProfile']),
      patientProfile: PatientUserProfile.fromMap(map['patientProfile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Bills.fromJson(String source) => Bills.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Bills(id: $id, billId: $billId, doctorId: $doctorId, patientId: $patientId, price: $price, bookingsFee: $bookingsFee, bookingsFeePrice: $bookingsFeePrice, total: $total, currencySymbol: $currencySymbol, paymentToken: $paymentToken, paymentType: $paymentType, billDetailsArray: $billDetailsArray, createdAt: $createdAt, updateAt: $updateAt, status: $status, invoiceId: $invoiceId, paymentDate: $paymentDate, dueDate: $dueDate, patientProfile: $patientProfile, doctorProfile: $doctorProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Bills &&
        other.id == id &&
        other.billId == billId &&
        other.doctorId == doctorId &&
        other.patientId == patientId &&
        other.price == price &&
        other.bookingsFee == bookingsFee &&
        other.bookingsFeePrice == bookingsFeePrice &&
        other.total == total &&
        other.currencySymbol == currencySymbol &&
        other.paymentToken == paymentToken &&
        other.paymentType == paymentType &&
        listEquals(other.billDetailsArray, billDetailsArray) &&
        other.createdAt == createdAt &&
        other.updateAt == updateAt &&
        other.status == status &&
        other.invoiceId == invoiceId &&
        other.paymentDate == paymentDate &&
        other.dueDate == dueDate&&
        other.doctorProfile == doctorProfile &&
        other.patientProfile == patientProfile;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        billId.hashCode ^
        doctorId.hashCode ^
        patientId.hashCode ^
        price.hashCode ^
        bookingsFee.hashCode ^
        bookingsFeePrice.hashCode ^
        total.hashCode ^
        currencySymbol.hashCode ^
        paymentToken.hashCode ^
        paymentType.hashCode ^
        billDetailsArray.hashCode ^
        createdAt.hashCode ^
        updateAt.hashCode ^
        status.hashCode ^
        invoiceId.hashCode ^
        paymentDate.hashCode ^
        dueDate.hashCode^
        patientProfile.hashCode^
        doctorProfile.hashCode;
  }
}

class BillingsDetails {
  final String title;
  final double price;
  final double bookingsFee;
  final double bookingsFeePrice;
  final double total;

  BillingsDetails({
    required this.title,
    required this.price,
    required this.bookingsFee,
    required this.bookingsFeePrice,
    required this.total,
  });

  BillingsDetails copyWith({
    String? title,
    double? price,
    double? bookingsFee,
    double? bookingsFeePrice,
    double? total,
  }) {
    return BillingsDetails(
      title: title ?? this.title,
      price: price ?? this.price,
      bookingsFee: bookingsFee ?? this.bookingsFee,
      bookingsFeePrice: bookingsFeePrice ?? this.bookingsFeePrice,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'price': price});
    result.addAll({'bookingsFee': bookingsFee});
    result.addAll({'bookingsFeePrice': bookingsFeePrice});
    result.addAll({'total': total});

    return result;
  }

  factory BillingsDetails.fromMap(Map<String, dynamic> map) {
    return BillingsDetails(
      title: map['title'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      bookingsFee: map['bookingsFee']?.toDouble() ?? 0.0,
      bookingsFeePrice: map['bookingsFeePrice']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BillingsDetails.fromJson(String source) => BillingsDetails.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BillingsDetails(title: $title, price: $price, bookingsFee: $bookingsFee, bookingsFeePrice: $bookingsFeePrice, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BillingsDetails &&
        other.title == title &&
        other.price == price &&
        other.bookingsFee == bookingsFee &&
        other.bookingsFeePrice == bookingsFeePrice &&
        other.total == total;
  }

  @override
  int get hashCode {
    return title.hashCode ^ price.hashCode ^ bookingsFee.hashCode ^ bookingsFeePrice.hashCode ^ total.hashCode;
  }
}
