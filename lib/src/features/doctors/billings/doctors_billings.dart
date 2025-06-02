import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/billing_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/bills_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/shared/status_badge_avatar.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/invoice/doctor_invoice_preview_screen.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';

class DoctorsBillings extends StatefulWidget {
  static const String routeName = "/doctors/dashboard/billings";
  const DoctorsBillings({super.key});

  @override
  State<DoctorsBillings> createState() => _DoctorsBillingsState();
}

class _DoctorsBillingsState extends State<DoctorsBillings> {
  final ScrollController doctorsBillingsScrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final BillsService billsService = BillsService();
  late final BillingProvider billingProvider;
  late List<String> deleteBillsId;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    await billsService.getBillingRecord(context);
    setState(() {
      deleteBillsId.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    deleteBillsId = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      billingProvider = Provider.of<BillingProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    billingProvider.setDoctorsBills([], notify: false);
    billingProvider.setTotal(0, notify: false);
    doctorsBillingsScrollController.dispose();
    super.dispose();
  }

  void tougleBillIdTodeleteBillsId(String billId) {
    if (deleteBillsId.contains(billId)) {
      setState(() {
        deleteBillsId.remove(billId);
      });
    } else {
      setState(() {
        deleteBillsId.add(billId);
      });
    }
  }

  Future<void> deleteBillRequestSubmit(BuildContext context, List<String> deleteArray) async {
    bool success = await billsService.deleteBillingRecord(context, deleteArray);

    if (success) {
      if (context.mounted) {
        showErrorSnackBar(context, "${deleteArray.length} Bill(s) was deleted.");
      }
      setState(() {
        deleteBillsId.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, value, _) {
        final doctorsBills = billingProvider.bills;
        bool isLoading = billingProvider.isLoading;
        final int totalBills = billingProvider.total;
        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        List<String> unpaidIds = doctorsBills.where((bill) => bill.status != 'Paid').map((bill) => bill.id.toString()).toList();
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'invoiceId', label: Text(context.tr('invoiceId'))), dataType: 'string'),
          FilterableGridColumn(
              column: GridColumn(
                  columnName: roleName == 'patient' ? 'doctorProfile.fullName' : 'patientProfile.fullName',
                  label: Text(context.tr(roleName == 'patient' ? 'patientName' : "doctorName"))),
              dataType: 'string'),
          if (roleName == 'doctors')
            FilterableGridColumn(
              column: GridColumn(columnName: 'price', label: Text(context.tr('price'))),
              dataType: 'number',
            ),
            if (roleName == 'doctors')
            FilterableGridColumn(
              column: GridColumn(columnName: 'bookingsFee', label: Text(context.tr('bookingsFee'))),
              dataType: 'number',
            ),
             if (roleName == 'doctors')
            FilterableGridColumn(
              column: GridColumn(columnName: 'bookingsFeePrice', label: Text(context.tr('bookingsFeePrice'))),
              dataType: 'number',
            ),
          FilterableGridColumn(column: GridColumn(columnName: 'total', label: Text(context.tr('total'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'dueDate', label: Text(context.tr('dueDate'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'status', label: Text(context.tr('status'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'createdAt', label: Text(context.tr('createdAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'updateAt', label: Text(context.tr('updateAt'))), dataType: 'date'),
        ];
        return ScaffoldWrapper(
          title: context.tr('billings'),
          children: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double per = 0;
                  if (doctorsBillingsScrollController.hasClients) {
                    per = ((doctorsBillingsScrollController.offset / doctorsBillingsScrollController.position.maxScrollExtent));
                  }
                  if (per >= 0) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        setState(() {
                          scrollPercentage = 307 * per;
                        });
                      }
                    });
                  }
                  return false;
                },
                child: Column(
                  children: [
                    FadeinWidget(
                      isCenter: true,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: theme.primaryColorLight),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'totalBillings',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ).plural(
                                totalBills,
                                format: NumberFormat.compact(
                                  locale: context.locale.toString(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // confirmed delete
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.vertical,
                          child: child,
                        );
                      },
                      child: deleteBillsId.isNotEmpty
                          ? Padding(
                              key: const ValueKey("buttonVisible"),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: GradientButton(
                                  onPressed: () async {
                                    final result = await showModalBottomSheet<List<String>>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => FractionallySizedBox(
                                        heightFactor: 0.4,
                                        child: Scaffold(
                                          appBar: AppBar(
                                            backgroundColor: theme.primaryColorLight,
                                            title: const Text("billForDelete").plural(
                                              deleteBillsId.length,
                                              format: NumberFormat.compact(
                                                locale: context.locale.toString(),
                                              ),
                                            ),
                                            automaticallyImplyLeading: false, // Removes the back button
                                            actions: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: theme.primaryColor,
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                          body: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                FadeinWidget(
                                                  isCenter: true,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Card(
                                                      elevation: 6,
                                                      color: Theme.of(context).canvasColor,
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Center(
                                                          child: Text(
                                                            "billDeleteConfirm",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.normal,
                                                              color: Theme.of(context).primaryColor,
                                                            ),
                                                          ).plural(
                                                            deleteBillsId.length,
                                                            format: NumberFormat.compact(
                                                              locale: context.locale.toString(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context, deleteBillsId);
                                                    },
                                                    child: Text(context.tr("submit")),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    if (!context.mounted) return;

                                    if (result != null) {
                                      deleteBillRequestSubmit(context, result);
                                    }
                                  },
                                  colors: [
                                    Theme.of(context).primaryColorLight,
                                    Theme.of(context).primaryColor,
                                  ],
                                  child: Center(
                                    child: Text(
                                      "paymentRequest",
                                      style: TextStyle(fontSize: 12, color: textColor),
                                    ).plural(
                                      deleteBillsId.length,
                                      format: NumberFormat.compact(
                                        locale: context.locale.toString(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey("buttonHidden")),
                    ),

                    //Sized box
                    const SizedBox(height: 10),
                    CustomPaginationWidget(
                      count: totalBills,
                      getDataOnUpdate: getDataOnUpdate,
                    ),
                    // const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          splashRadius: 0,
                          checkColor: theme.primaryColorLight,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          value: deleteBillsId.isNotEmpty,
                          onChanged: (bool? value) {
                            log('$value');
                            if (value == false) {
                              setState(() {
                                deleteBillsId.clear();
                              });
                            } else {
                              setState(() {
                                deleteBillsId = unpaidIds;
                              });
                            }
                          },
                        ),
                        Text('tuggleBillForDelete',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.primaryColorLight,
                            )).plural(
                          unpaidIds.length,
                          format: NumberFormat.compact(
                            locale: context.locale.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: doctorsBillingsScrollController,
                            shrinkWrap: true,
                            restorationId: 'doctorsBills',
                            key: const ValueKey('doctorsBills'),
                            physics: const BouncingScrollPhysics(),
                            itemCount: doctorsBills.length,
                            itemBuilder: (context, index) {
                              final bill = doctorsBills[index];
                              return BillsShowBox(
                                  singleBill: bill,
                                  getDataOnUpdate: getDataOnUpdate,
                                  userType: 'doctors',
                                  deleteBillsId: deleteBillsId,
                                  tougleBillIdTodeleteBillsId: tougleBillIdTodeleteBillsId);
                            },
                          ),
                          if (isLoading) ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          ],
                          ScrollButton(scrollController: doctorsBillingsScrollController, scrollPercentage: scrollPercentage),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: FloatingActionButton(
                    tooltip: context.tr('filter'),
                    mini: true,
                    onPressed: () async {
                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.9,
                          child: SfDataGridFilterWidget(columns: filterableColumns, columnName: 'id'),
                        ),
                      );

                      if (result != null) {
                        dataGridProvider.setPaginationModel(0, 10);
                        dataGridProvider.setMongoFilterModel({...result});
                        await getDataOnUpdate();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 25,
                          color: theme.primaryColor,
                        ),
                        if (isFilterActive)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
    final Bills bill = widget.singleBill;
    final String userType = widget.userType;
    final PatientUserProfile patientProfile = bill.patientProfile;
    final DoctorUserProfile doctorProfile = bill.doctorProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final bangkok = tz.getLocation('Asia/Bangkok');
    final String gender = patientProfile.gender;
    final String patientName = "$gender${gender != '' ? '. ' : ''}${patientProfile.fullName}";
    final String patientProfileImage = patientProfile.profileImage;
    final String doctorName = "Dr. ${doctorProfile.fullName}";
    final String doctorProfileImage = doctorProfile.profileImage;
    final String dueDate = DateFormat("dd MMM yyyy").format(bill.dueDate.toLocal());
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
      statusColor = patientProfile.idle ?? false
          ? const Color(0xFFFFA812)
          : patientProfile.online
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
                                  if (userType == 'doctors') {
                                    context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedpatientId').toString());
                                  }
                                  if (userType == 'patient') {
                                    context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                                  }
                                },
                                child: Text(
                                  userType == 'doctors' ? patientName : doctorName,
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
                                getDataOnUpdate: widget.getDataOnUpdate)
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                patientProfile.userName,
                                style: TextStyle(color: textColor),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: userType == 'doctors' ? 'patientProfile.userName' : 'doctorProfile.userName',
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
              //Invoice and due Date
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
                                        if (userType == 'doctors') {
                                          context.push(
                                            Uri(path: '/doctors/dashboard/bill-view/$encodedInvoiceId').toString(),
                                          );
                                        } else if (userType == 'patient') {
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
                                      color: bill.status != 'Paid' && _isDueDatePassed(dueDate) ? Colors.red : textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (bill.status != 'Paid' && _isDueDatePassed(dueDate))
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
              if (userType == 'doctors') ...[
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
              if (userType == 'doctors') ...[
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
              if (userType == 'patient') ...[
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
                                            bill: bill,
                                            userType: userType,
                                            scrollController: scrollController,
                                          );
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
              // Icon buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      // Show loading dialog
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
                          final pdf = await buildBillPdf(context, bill);
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
                    icon: FaIcon(
                      FontAwesomeIcons.print,
                      size: 20,
                      color: theme.primaryColorLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (userType == 'doctors') {
                        context.push(
                          Uri(path: '/doctors/dashboard/edit-billing/$encodedInvoiceId').toString(),
                        );
                      } else if (userType == 'patient') {
                        context.push(
                          Uri(path: '/patient/dashboard/see-billing/$encodedInvoiceId').toString(),
                        );
                      }
                    },
                    icon: FaIcon(
                      userType == 'doctors' ? FontAwesomeIcons.edit : FontAwesomeIcons.eye,
                      size: 20,
                      color: theme.primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: (userType == 'doctors' && bill.status == 'Paid') || (userType == 'patient' && bill.status == 'Paid')
                        ? null
                        : () {
                            if (userType == 'doctors') {
                              widget.tougleBillIdTodeleteBillsId(bill.id);
                            } else if (userType == 'patient') {
                              context.push(
                                Uri(path: '/patient/check-out/$encodedInvoiceId').toString(),
                              );
                            }
                          },
                    icon: userType == 'doctors'
                        ? Icon(
                            Icons.delete_forever,
                            color: bill.status == 'Paid' ? theme.disabledColor : Colors.red,
                          )
                        : Icon(
                            Icons.payment,
                            color: bill.status == 'Paid' ? theme.disabledColor : theme.primaryColorLight,
                          ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

bool _isDueDatePassed(String dueDateStr) {
  try {
    final date = DateFormat('dd MMM yyyy').parse(dueDateStr);
    return date.isBefore(DateTime.now());
  } catch (e) {
    log('Date parse error: $e');
    return false;
  }
}

class BillButtomSheet extends StatefulWidget {
  final Bills bill;
  final String userType;
  final ScrollController scrollController;
  const BillButtomSheet({
    super.key,
    required this.bill,
    required this.userType,
    required this.scrollController,
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
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final PatientUserProfile patientProfile = bill.patientProfile;
    final DoctorUserProfile doctorProfile = bill.doctorProfile;
    final String gender = patientProfile.gender;
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
                      Padding(
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
                      Padding(
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
                      Padding(
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

Future<pw.Document> buildBillPdf(BuildContext context, Bills bill) async {
  final theme = Theme.of(context);

  var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;

  final robotoRegular = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Regular.ttf'));
  final robotoBold = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Bold.ttf'));
  final sarabunLight = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Light.ttf'));
  final sarabunBold = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Bold.ttf'));

  final pdf = pw.Document();
  final dateFormat = DateFormat('dd MMM yyyy');
  final bangkok = tz.getLocation('Asia/Bangkok');

  final imageBytes = await rootBundle.load('assets/icon/icon.png');
  final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
  final PatientUserProfile patientUserProfile = bill.patientProfile;
  final DoctorUserProfile doctorUserProfile = bill.doctorProfile;

  final String issueDay = dateFormat.format(tz.TZDateTime.from(bill.createdAt, bangkok));
  final String dueDate = dateFormat.format(tz.TZDateTime.from(bill.dueDate, bangkok));
  final String invoiceId = bill.invoiceId;
  final String paymentType = bill.paymentType;
  final String paymentToken = bill.paymentToken;
  final String drName = "Dr.${doctorUserProfile.fullName}";
  final String drAddress = "${doctorUserProfile.address1}${doctorUserProfile.address1 != '' ? ', ' : ''} ${doctorUserProfile.address2}";
  final String drCity = doctorUserProfile.city.trim().isNotEmpty ? doctorUserProfile.city : '---';
  final String drState = doctorUserProfile.state.trim().isNotEmpty ? doctorUserProfile.state : '---';
  final String drCountry = doctorUserProfile.country.trim().isNotEmpty ? doctorUserProfile.country : '---';
  final String paName = "${patientUserProfile.gender}${patientUserProfile.gender != '' ? '.' : ''} ${patientUserProfile.fullName}";
  final String paAddress = "${patientUserProfile.address1} ${patientUserProfile.address1 != '' ? ', ' : ''} ${patientUserProfile.address2}";
  final String paCity = patientUserProfile.city.trim().isNotEmpty ? patientUserProfile.city : '---';
  final String paState = patientUserProfile.state.trim().isNotEmpty ? patientUserProfile.state : '---';
  final String paCountry = patientUserProfile.country.trim().isNotEmpty ? patientUserProfile.country : '---';

// List of available keys in your BillingsDetails class
  final List<String> allKeys = [
    'title',
    'price',
    'bookingsFee',
    'bookingsFeePrice',
    'total',
  ];

// Filtered based on role
  final List<String> filteredKeys = allKeys.where((key) {
    if (roleName == 'patient') {
      return key == 'title' || key == 'total';
    } else {
      return key != 'amount';
    }
  }).toList();

// Column widths map dynamically based on number of columns
  final Map<int, pw.TableColumnWidth> columnWidths = {
    for (int i = 0; i < filteredKeys.length; i++) i: const pw.FlexColumnWidth(2),
  };
  columnWidths[0] = const pw.FlexColumnWidth(4); // Make first column wider

  pw.Widget buildDoctorPaymentStamp(String status) {
    // Normalize status (e.g., remove case sensitivity or trim)
    final normalized = status.trim().toLowerCase();

    // Define color and label
    PdfColor borderColor;
    String text;

    switch (normalized) {
      case 'paid':
        borderColor = PdfColors.green600; // Similar to #5BC236
        text = 'PAID';
        break;
      case 'over due':
        borderColor = PdfColors.red600; // Similar to #f44336
        text = 'Over Due';
        break;
      case 'pending':
        borderColor = PdfColors.orange600; // Similar to #ffa500
        text = 'PENDING';
        break;
      default:
        borderColor = PdfColors.grey;
        text = status.toUpperCase();
    }

    return pw.Container(
      width: 328,
      child: pw.Transform.rotateBox(
        angle: 0.17,
        child: pw.Align(
          alignment: pw.Alignment.center, // or center, if you want it centered
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor, width: 3),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: borderColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(6.0),
      build: (pwContext) {
        final fontBold = context.locale.toString() == 'th_TH' ? sarabunBold : robotoBold;
        final fontReqular = context.locale.toString() == 'th_TH' ? sarabunLight : robotoRegular;

        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromInt(theme.primaryColorLight.toARGB32()), width: 2),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              //Logo row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Logo
                  pw.ClipOval(
                    child: pw.Image(image, width: 60, height: 60),
                  ),
                  // Right: Column with invoice info
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      //Invoice Number
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 16.0),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              '${context.tr('invoiceId')} :',
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(
                                  theme.primaryColor.toARGB32(),
                                ),
                                font: fontBold,
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(invoiceId, style: pw.TextStyle(font: fontReqular))
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 6),
                      //Issue day
                      pw.Row(
                        children: [
                          pw.Text(
                            '${context.tr('issued')} :',
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(
                                theme.primaryColor.toARGB32(),
                              ),
                              font: fontBold,
                            ),
                          ),
                          pw.SizedBox(width: context.locale.toString() == 'th_TH' ? 58 : 28),
                          pw.Text(issueDay, style: pw.TextStyle(font: fontReqular))
                        ],
                      ),

                      pw.SizedBox(height: 6),
                      //Issue day
                      pw.Row(
                        children: [
                          pw.Text(
                            '${context.tr('dueDate')} :',
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(
                                theme.primaryColor.toARGB32(),
                              ),
                              font: fontBold,
                            ),
                          ),
                          pw.SizedBox(width: context.locale.toString() == 'th_TH' ? 28 : 28),
                          pw.Text(dueDate, style: pw.TextStyle(font: fontReqular))
                        ],
                      )
                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // First Colum Dr information
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                          context.tr('drInformation'),
                          style: pw.TextStyle(
                            color: PdfColor.fromInt(
                              theme.primaryColor.toARGB32(),
                            ),
                            fontSize: 18,
                            font: fontBold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        //Dr name
                        pw.Text('${context.tr('name')} : $drName', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('address')} : $drAddress', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('city')} : $drCity', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('state')} : $drState', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('country')} : $drCountry', style: pw.TextStyle(font: fontReqular)),
                      ],
                    ),
                  ),
                  //Second column patient information
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          context.tr('patientInformation'),
                          style: pw.TextStyle(color: PdfColor.fromInt(theme.primaryColor.toARGB32()), fontSize: 18, font: fontBold),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('${context.tr('name')} : $paName', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('address')} : $paAddress', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('city')} : $paCity', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('state')} : $paState', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('country')} : $paCountry', style: pw.TextStyle(font: fontReqular)),
                      ],
                    ),
                  ),
                  //Third column payment information
                  // Payment Information
                  if (bill.status == 'Paid') ...[
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            context.tr('paymentMethod'),
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                              fontSize: 18,
                              font: fontBold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(paymentType, style: pw.TextStyle(font: fontReqular)),
                          pw.Text(paymentToken, style: pw.TextStyle(font: fontReqular)),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Column(
                children: [
                  // Invoice Items Table
                  pw.Table(
                    border: pw.TableBorder(
                      horizontalInside: pw.BorderSide(
                        color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                        width: 0.5,
                      ),
                    ),
                    columnWidths: columnWidths,
                    children: [
                      pw.TableRow(
                        children: filteredKeys.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final String key = entry.value;

                          // Convert key to display label
                          final String label = key == 'bookingsFee'
                              ? 'Percent'
                              : key == 'bookingsFeePrice'
                                  ? 'Fee Price'
                                  : '${key[0].toUpperCase()}${key.substring(1)}';

                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                            child: pw.Text(
                              context.tr(label),
                              textAlign: index == 0 ? pw.TextAlign.left : pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                                font: fontBold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      ...bill.billDetailsArray.map(
                        (item) {
                          // Filter keys again (in case reused separately)
                          final filteredKeys =
                              roleName == 'patient' ? ['title', 'total'] : ['title', 'price', 'bookingsFee', 'bookingsFeePrice', 'total'];

                          return pw.TableRow(children: [
                            ...filteredKeys.asMap().entries.map(
                              (entry) {
                                final int index = entry.key;
                                final String key = entry.value;
                                // Extract value based on key
                                String value = '';
                                switch (key) {
                                  case 'title':
                                    value = item.title;
                                    break;
                                  case 'price':
                                    value = "${NumberFormat("#,##0.00", "en_US").format(item.price)} ${bill.currencySymbol}";
                                    break;
                                  case 'bookingsFee':
                                    value = '${item.bookingsFee.toStringAsFixed(0)} %';
                                    break;
                                  case 'bookingsFeePrice':
                                    value = "${NumberFormat("#,##0.00", "en_US").format(item.bookingsFeePrice)} ${bill.currencySymbol}";
                                    break;
                                  case 'total':
                                    value = "${NumberFormat("#,##0.00", "en_US").format(item.total)} ${bill.currencySymbol}";
                                    break;
                                  default:
                                    value = '-';
                                }
                                return pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 6.0, bottom: 6.0, left: 8.0),
                                    child: pw.Text(
                                      value,
                                      textAlign: index == 0 ? pw.TextAlign.left : pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: fontReqular,
                                        fontFallback: [sarabunLight],
                                        color: PdfColor.fromInt(theme.primaryColorDark.toARGB32()),
                                      ),
                                    ));
                              },
                            )
                          ]);
                        },
                      )
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left: Stamp (if doctor)
                      if (roleName == 'doctors')
                        pw.Positioned(
                          top: 50,
                          child: buildDoctorPaymentStamp(bill.status != 'Paid' && _isDueDatePassed(dueDate) ? 'Over Due' : bill.status),
                        )
                      else
                        pw.Expanded(child: pw.SizedBox(height: 100)),

                      // Right: Summary Table
                      pw.Expanded(
                        child: pw.Container(
                          alignment: pw.Alignment.topRight,
                          child: pw.Table(
                            border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(color: PdfColor.fromInt(theme.primaryColor.toARGB32()), width: 0.5),
                            ),
                            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                            children: [
                              if (roleName == 'doctors') ...[
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${context.tr('totalPrice')} :',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(bill.price)} ${bill.currencySymbol} ',
                                            style: pw.TextStyle(font: fontReqular)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (roleName == 'doctors') ...[
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${context.tr('totalFeePrice')} :',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(bill.bookingsFeePrice)} ${bill.currencySymbol} ',
                                            style: pw.TextStyle(font: fontReqular)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${context.tr('totalAmount')} :',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                    ),
                                  ),
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Padding(
                                      padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                      child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(bill.total)} ${bill.currencySymbol} ',
                                          style: pw.TextStyle(font: fontReqular)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: context.locale.toString() == 'th_TH' ? 100 : 200),
                  //Footer
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        context.tr('otherInformation'),
                        style: pw.TextStyle(
                          fontSize: 16,
                          font: fontBold,
                          color: PdfColor.fromInt(
                            theme.primaryColor.toARGB32(),
                          ),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        context.tr('invoiceFooter'),
                        style: pw.TextStyle(
                          font: fontReqular,
                        ),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }));
  return pdf;
}
