
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/status_badge_avatar.dart';

class BillButtomSheet extends StatefulWidget {
  final Bills bill;
  final String userType;
  final bool isSameDoctor;
  final ScrollController scrollController;
  const BillButtomSheet({
    super.key,
    required this.bill,
    required this.userType,
    required this.scrollController,
    required this.isSameDoctor,
  });

  @override
  State<BillButtomSheet> createState() => _BillButtomSheetState();
}

class _BillButtomSheetState extends State<BillButtomSheet> {
  @override
  Widget build(BuildContext context) {
    final Bills bill = widget.bill;
    final String userType = widget.userType;
    final ScrollController scrollController = widget.scrollController;
    final bool isSameDoctor = widget.isSameDoctor;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final PatientUserProfile? patientProfile = bill.patientProfile;
    final DoctorUserProfile doctorProfile = bill.doctorProfile;
    final String gender = patientProfile!.gender;
    final String patientName = "$gender${gender != '' ? '. ' : ''}${patientProfile.fullName}";
    final String patientProfileImage = patientProfile.profileImage;
    final String doctorName = "Dr. ${doctorProfile.fullName}";
    final String doctorProfileImage = doctorProfile.profileImage;
    final String finalImage = userType == 'doctors'
        ? patientProfileImage.isEmpty
            ? 'assets/images/default-avatar.png'
            : patientProfileImage
        : doctorProfileImage.isEmpty
            ? 'assets/images/doctors_profile.jpg'
            : doctorProfileImage;

    final encodedpatientId = base64.encode(utf8.encode(bill.patientId.toString()));
    final encodeddoctorId = base64.encode(utf8.encode(bill.doctorId.toString()));
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusBadgeAvatar(
                    imageUrl: finalImage,
                    online: patientProfile.online,
                    idle: patientProfile.idle ?? false,
                    userType: 'patient',
                    onTap: () {
                      if (userType == 'doctors') {
                        context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedpatientId').toString());
                      }
                      if (userType == 'patient') {
                        context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 200, // Constrain this
                    child: GestureDetector(
                      onTap: () {
                        if (userType == 'doctors') {
                          context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedpatientId').toString());
                        }
                        if (userType == 'patient') {
                          context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                        }
                      },
                      child: Text(
                        userType == 'doctors' ? patientName : doctorName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: theme.primaryColor, decoration: TextDecoration.underline, fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 1,
              color: theme.primaryColorLight,
            ),
            ...bill.billDetailsArray.map<Widget>(
              (detail) {
                final double price = detail.price;
                final formattedPrice = NumberFormat("#,##0.00", "en_US").format(price);
                final double bookingsFeePrice = detail.bookingsFeePrice;
                final formattedBookingsFeePrice = NumberFormat("#,##0.00", "en_US").format(bookingsFeePrice);
                final double total = detail.total;
                final formattedTotal = NumberFormat("#,##0.00", "en_US").format(total);
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text('${context.tr("title")}:'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                detail.title,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                     if(userType == 'doctors' && isSameDoctor) Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text('${context.tr("price")}:', style: TextStyle(color: textColor)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                textAlign: TextAlign.end,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$formattedPrice ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: bill.currencySymbol,
                                      style: TextStyle(color: theme.primaryColorLight),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                       if(userType == 'doctors' && isSameDoctor) Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text('${context.tr("bookingsFee")}:'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${detail.bookingsFee} %',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                       if(userType == 'doctors' && isSameDoctor) Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text('${context.tr("bookingsFeePrice")}:', style: TextStyle(color: textColor)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                textAlign: TextAlign.end,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$formattedBookingsFeePrice ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: bill.currencySymbol,
                                      style: TextStyle(color: theme.primaryColorLight),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text('${context.tr("total")}:', style: TextStyle(color: textColor)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                textAlign: TextAlign.end,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$formattedTotal ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: bill.currencySymbol,
                                      style: TextStyle(color: theme.primaryColorLight),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: theme.primaryColorLight,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
