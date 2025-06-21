import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/shared/bill_buttom_sheet.dart';
import 'package:health_care/shared/gradient_button.dart';

import 'package:health_care/shared/sort_icon_widget.dart';

import 'package:health_care/src/features/doctors/invoice/doctor_invoice_preview_screen.dart';
import 'package:health_care/src/utils/build_bill_pdf.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/src/utils/is_due_date_passed.dart';
import 'package:provider/provider.dart';

import 'package:timezone/timezone.dart' as tz;

class BillsShowBox extends StatefulWidget {
  final Bills singleBill;
  final VoidCallback getDataOnUpdate;
  final String userType;
  final List<String> deleteBillsId;
  final void Function(String) tougleBillIdTodeleteBillsId;
  const BillsShowBox({
    super.key,
    required this.singleBill,
    required this.getDataOnUpdate,
    required this.userType,
    required this.deleteBillsId,
    required this.tougleBillIdTodeleteBillsId,
  });

  @override
  State<BillsShowBox> createState() => _BillsShowBoxState();
}

class _BillsShowBoxState extends State<BillsShowBox> {
  late String roleName;
  DoctorsProfile? doctorsProfile;
  bool _isProvidersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      doctorsProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
      _isProvidersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Bills bill = widget.singleBill;
    final String userType = widget.userType;
    final PatientUserProfile? patientProfile = bill.patientProfile;
    final DoctorUserProfile doctorProfile = bill.doctorProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final Color cardColor = userType != 'doctors' ? theme.canvasColor : theme.cardTheme.color!;
    final bangkok = tz.getLocation('Asia/Bangkok');
    final String gender = patientProfile?.gender ?? "";
    final String patientName = "$gender${gender != '' ? '. ' : ''}${patientProfile?.fullName}";
    final String patientProfileImage = patientProfile?.profileImage ?? "";
    final String doctorName = "Dr. ${doctorProfile.fullName}";
    final String doctorProfileImage = doctorProfile.profileImage;
    final String dueDate = DateFormat("dd MMM yyyy").format(bill.dueDate.toLocal());
    final bool isSameDoctor = roleName == 'doctors' && doctorsProfile?.userId == bill.doctorId;
    final ImageProvider<Object> finalImage = userType == 'doctors'
        ? patientProfileImage.isEmpty
            ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
            : CachedNetworkImageProvider(patientProfileImage)
        : doctorProfileImage.isEmpty
            ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
            : CachedNetworkImageProvider(doctorProfileImage);
    final double price = bill.price;
    final formattedPrice = NumberFormat("#,##0.00", "en_US").format(price);
    final double bookingsFeePrice = bill.bookingsFeePrice;
    final formattedBookingsFeePrice = NumberFormat("#,##0.00", "en_US").format(bookingsFeePrice);
    final double total = bill.total;
    final formattedTotal = NumberFormat("#,##0.00", "en_US").format(total);
    final encodedpatientId = base64.encode(utf8.encode(bill.patientId.toString()));
    final encodeddoctorId = base64.encode(utf8.encode(bill.doctorId.toString()));
    final encodedInvoiceId = base64.encode(utf8.encode(bill.id.toString()));
    late Color statusColor;
    if (userType == 'doctors') {
      statusColor = patientProfile?.idle ?? false
          ? const Color(0xFFFFA812)
          : patientProfile!.online
              ? const Color(0xFF44B700)
              : const Color.fromARGB(255, 250, 18, 2);
    } else {
      statusColor = doctorProfile.idle ?? false
          ? const Color(0xFFFFA812)
          : doctorProfile.online
              ? const Color(0xFF44B700)
              : const Color.fromARGB(255, 250, 18, 2);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        color: userType == 'doctors' ? theme.canvasColor : cardColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //profile row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          if (userType == 'doctors') {
                            context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedpatientId').toString());
                          }
                          if (userType == 'patient') {
                            context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: theme.primaryColorLight),
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(fit: BoxFit.contain, image: finalImage),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.primaryColor, width: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (roleName == 'doctors') {
                                    context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedpatientId').toString());
                                  }
                                  if (roleName == 'patient') {
                                    context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                                  }
                                },
                                child: Text(
                                  roleName == 'doctors' ? patientName : doctorName,
                                  style: TextStyle(
                                    color: theme.primaryColorLight,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: userType == 'doctors' ? 'patientProfile.fullName' : 'doctorProfile.fullName',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                roleName == 'doctors' ? patientProfile?.userName ?? "" : doctorProfile.userName,
                                style: TextStyle(color: textColor),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: roleName == 'doctors' ? 'patientProfile.userName' : 'doctorProfile.userName',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '#${bill.billId}',
                                style: TextStyle(color: theme.primaryColorLight),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(columnName: 'id', getDataOnUpdate: widget.getDataOnUpdate),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 1,
                  color: theme.primaryColorLight,
                ),
              ),
              if(roleName == 'doctors' && !isSameDoctor) ...[
                //InvoiceId
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    //  Invoice
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12), // Common style
                                children: [
                                  TextSpan(
                                    text: '${context.tr("doctorName")}: ',
                                    style: TextStyle(color: textColor), // Normal colored text
                                  ),
                                  TextSpan(
                                    text: doctorName,
                                    style: TextStyle(
                                      color: theme.primaryColorLight, // Clickable text color
                                      decoration: TextDecoration.underline, // Optional: shows it's clickable
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (roleName == 'doctors') {
                                          context.push(
                                            Uri(path: '/doctors/profile/$encodeddoctorId').toString(),
                                          );
                                        } 
                                      },
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: SortIconWidget(columnName: 'doctorProfile.fullName', getDataOnUpdate: widget.getDataOnUpdate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 1,
                  color: theme.primaryColorLight,
                ),
              ),
              
              ],
              //InvoiceId
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    //  Invoice
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12), // Common style
                                children: [
                                  TextSpan(
                                    text: '${context.tr("invoiceId")}: ',
                                    style: TextStyle(color: textColor), // Normal colored text
                                  ),
                                  TextSpan(
                                    text: bill.invoiceId,
                                    style: TextStyle(
                                      color: theme.primaryColorLight, // Clickable text color
                                      decoration: TextDecoration.underline, // Optional: shows it's clickable
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (roleName == 'doctors') {
                                          context.push(
                                            Uri(path: '/doctors/dashboard/bill-view/$encodedInvoiceId').toString(),
                                          );
                                        } else if (roleName == 'patient') {
                                          context.push(
                                            Uri(path: '/patient/dashboard/bill-view/$encodedInvoiceId').toString(),
                                          );
                                        }
                                      },
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: SortIconWidget(columnName: 'invoiceId', getDataOnUpdate: widget.getDataOnUpdate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 1,
                  color: theme.primaryColorLight,
                ),
              ),
              //Due date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [

                    // Due Date
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // RichText for dueDate
                          Expanded(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: '${context.tr("dueDate")}: ',
                                    style: TextStyle(color: textColor),
                                  ),
                                  TextSpan(
                                    text: dueDate,
                                    style: TextStyle(
                                      color: bill.status != 'Paid' && isDueDatePassed(dueDate) ? Colors.red : textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (bill.status != 'Paid' && isDueDatePassed(dueDate))
                                    const TextSpan(
                                      text: ' (OD)',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SortIconWidget(
                            columnName: 'dueDate',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              //Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 1,
                  color: theme.primaryColorLight,
                ),
              ),
              
              
              // Price and Fee
              if (roleName == 'doctors') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      // Price
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12),
                                  children: [
                                    TextSpan(
                                      text: '${context.tr("price")}: $formattedPrice ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: bill.currencySymbol,
                                      style: TextStyle(
                                        color: theme.primaryColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 2.0),
                              child: SortIconWidget(
                                columnName: 'price',
                                getDataOnUpdate: widget.getDataOnUpdate,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Second half
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${context.tr("bookingsFee")} : ${bill.bookingsFee} %',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            SortIconWidget(
                              columnName: 'bookingsFee',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), //Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 1,
                    color: theme.primaryColorLight,
                  ),
                ),
              ],
              // fee price and total
              if (roleName == 'doctors') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      // Price
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12),
                                  children: [
                                    TextSpan(
                                      text: '${context.tr("bookingsFeePrice")}: $formattedBookingsFeePrice ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: bill.currencySymbol,
                                      style: TextStyle(
                                        color: theme.primaryColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 2.0),
                              child: SortIconWidget(
                                columnName: 'bookingsFeePrice',
                                getDataOnUpdate: widget.getDataOnUpdate,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Second half
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12),
                                  children: [
                                    TextSpan(
                                      text: '${context.tr("total")}: $formattedTotal ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: bill.currencySymbol,
                                      style: TextStyle(
                                        color: theme.primaryColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SortIconWidget(
                              columnName: 'total',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), //Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 1,
                    color: theme.primaryColorLight,
                  ),
                ),
              ],
              // Patient Total single row total
              if (roleName == 'patient') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      // Second half
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12),
                                  children: [
                                    TextSpan(
                                      text: '${context.tr("total")}: $formattedTotal ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: bill.currencySymbol,
                                      style: TextStyle(
                                        color: theme.primaryColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SortIconWidget(
                              columnName: 'total',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 1,
                    color: theme.primaryColorLight,
                  ),
                ),
              ],
              // createdAt and updateAt
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    // createdAt
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${context.tr("createdAt")}: ',
                                  style: TextStyle(color: textColor, fontSize: 12),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy').format(tz.TZDateTime.from(bill.createdAt, bangkok)),
                                      style: TextStyle(color: textColor, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('HH:mm').format(tz.TZDateTime.from(bill.createdAt, bangkok)),
                                      style: TextStyle(color: theme.primaryColorLight, fontSize: 12),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                            child: SortIconWidget(
                              columnName: 'createdAt',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Update
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${context.tr("updateAt")}: ',
                                  style: TextStyle(color: textColor, fontSize: 12),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy').format(tz.TZDateTime.from(bill.updateAt, bangkok)),
                                      style: TextStyle(color: textColor, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('HH:mm').format(tz.TZDateTime.from(bill.updateAt, bangkok)),
                                      style: TextStyle(color: theme.primaryColorLight, fontSize: 12),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                            child: SortIconWidget(
                              columnName: 'updateAt',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 1,
                  color: theme.primaryColorLight,
                ),
              ),
              //Items and status
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    //  Items view
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12), // Common style
                                children: [
                                  TextSpan(
                                    text: '${context.tr("items")}: ',
                                    style: TextStyle(color: textColor), // Normal colored text
                                  ),
                                  TextSpan(
                                    text: "${bill.billDetailsArray.length}",
                                    style: TextStyle(
                                      color: theme.primaryColorLight,
                                    ),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    useSafeArea: true,
                                    showDragHandle: true,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    enableDrag: true,
                                    context: context,
                                    builder: (context) {
                                      return DraggableScrollableSheet(
                                        expand: false,
                                        initialChildSize: 0.9,
                                        minChildSize: 0.5,
                                        maxChildSize: 0.95,
                                        builder: (context, scrollController) {
                                          return BillButtomSheet(
                                              bill: bill, userType: userType, scrollController: scrollController, isSameDoctor: isSameDoctor);
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Icon(Icons.visibility, size: 16, color: theme.primaryColor)),
                          ),
                        ],
                      ),
                    ),

                    // Status
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // RichText for Status
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '${context.tr("status")} ',
                                  style: TextStyle(color: textColor),
                                ),
                                Chip(
                                  label: Text(
                                    bill.status,
                                    style: TextStyle(color: textColor, fontSize: 12),
                                  ),
                                  backgroundColor: bill.status == "Paid" ? hexToColor('#5BC236') : hexToColor('#ffa500'), // Chip background
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), // Rounded corners
                                    side: BorderSide.none, // optional: border color/width
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                )
                              ],
                            ),
                          ),
                          SortIconWidget(
                            columnName: 'status',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              //Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 1,
                  color: theme.primaryColorLight,
                ),
              ),
              //View button
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
                            if (roleName == 'doctors') {
                              if (isSameDoctor) {
                                context.push(
                                  Uri(path: '/doctors/dashboard/edit-billing/$encodedInvoiceId').toString(),
                                );
                              } else {
                                context.push(
                                  Uri(path: '/doctors/dashboard/see-billing/$encodedInvoiceId').toString(),
                                );
                              }
                            } else if (roleName == 'patient') {
                              context.push(
                                Uri(path: '/patient/dashboard/see-billing/$encodedInvoiceId').toString(),
                              );
                            }
                          },
                          colors: [
                            Theme.of(context).primaryColorLight,
                            Theme.of(context).primaryColor,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(isSameDoctor ? FontAwesomeIcons.edit : FontAwesomeIcons.eye, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr(isSameDoctor ? "edit" : "view"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            Future.delayed(Duration.zero, () async {
                              if (!context.mounted) return;

                              try {
                                final pdf = await buildBillPdf(context, bill, isSameDoctor);
                                final bytes = await pdf.save();

                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                await showModalBottomSheet<Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder: (context) => FractionallySizedBox(
                                    heightFactor: 1,
                                    child: DoctorInvoicePreviewScreen(
                                      pdfBytes: bytes,
                                      title: Text(context.tr('billPreview')),
                                    ),
                                  ),
                                );
                                // });
                              } catch (e) {
                                debugPrint('PDF Error: $e');
                              }
                            });
                          },
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColorLight,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.print, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr("print"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (roleName == 'doctors') ...[
                      const SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.pink,
                                  Colors.red,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.07,
                                ),
                              ),
                              onPressed: (userType == 'doctors' && bill.status == 'Paid') || (userType == 'patient' && bill.status == 'Paid')
                                  ? null
                                  : !isSameDoctor
                                      ? null
                                      : () {
                                          if (roleName == 'doctors') {
                                            widget.tougleBillIdTodeleteBillsId(bill.id);
                                          } else if (roleName == 'patient') {
                                            context.push(
                                              Uri(path: '/patient/check-out/$encodedInvoiceId').toString(),
                                            );
                                          }
                                        },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete, size: 13, color: !isSameDoctor ? Colors.black : textColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    context.tr("delete"),
                                    style: TextStyle(fontSize: 12, color: !isSameDoctor ? Colors.black : textColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (roleName == 'patient' && bill.status != 'Paid') ...[
                      const SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColorLight,
                                  theme.primaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.07,
                                ),
                              ),
                              onPressed: () {
                                Uri(path: '/patient/check-out/$encodedInvoiceId').toString();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.credit_card, size: 13, color: textColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    context.tr("pay"),
                                    style: TextStyle(fontSize: 12, color: textColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
