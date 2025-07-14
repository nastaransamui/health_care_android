import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/features/doctors/billings/bill_due_date_intput.dart';
import 'package:health_care/src/features/doctors/billings/bill_input.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/src/utils/is_due_date_passed.dart';
import 'package:timezone/timezone.dart' as tz;

class BillDetailsForm extends StatefulWidget {
  final String formType;
  final Future<void> Function(
    double price,
    double bookingsFee,
    double bookingsFeePrice,
    double total,
    String currencySymbol,
    String dueDate,
    List<BillingsDetails> billingDetailsList,
  ) onBillSubmit;
  final List<BillingsDetails> billsDetailsList;
  final DoctorUserProfile? doctorsProfile;
  final String? invoiceId;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final String status;
  const BillDetailsForm({
    super.key,
    required this.formType,
    required this.onBillSubmit,
    required this.billsDetailsList,
    this.doctorsProfile,
    this.invoiceId,
    this.createdAt,
    this.dueDate,
    this.status = 'Pending',
  });

  @override
  State<BillDetailsForm> createState() => _BillDetailsFormState();
}

class _BillDetailsFormState extends State<BillDetailsForm> {
  final billFormKey = GlobalKey<FormBuilderState>();
  late List<BillingsDetails> _localList;

  @override
  void initState() {
    super.initState();
    _localList = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localList.isEmpty) {
      _localList = List.from(widget.billsDetailsList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formType = widget.formType;
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final DoctorUserProfile? doctorUserProfile = widget.doctorsProfile;
    final String speciality = doctorUserProfile!.specialities.first.specialities;
    final String specialityImage = doctorUserProfile.specialities.first.image;
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    final String doctorName = "Dr. ${doctorUserProfile.fullName}";
    final String currency = doctorUserProfile.currency.first.currency;
    double sumPrice = _localList.fold(0.0, (sum, item) => sum + item.price);
    double sumFee = _localList.fold(0.0, (sum, item) => sum + item.bookingsFeePrice);
    double sumTotal = _localList.fold(0.0, (sum, item) => sum + item.total);
    return FormBuilder(
      key: billFormKey,
      child: Column(
        children: [
          Card(
            elevation: 12,
            color: theme.canvasColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.primaryColor),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BillDueDateIntput(formType: formType, theme: theme, textColor: textColor, dueDate: widget.dueDate),
                  if (formType != 'add') ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: 40,
                          width: constraints.maxWidth, // This makes the SizedBox take the full width
                          child: Chip(
                            label: Center(
                              // Center the text within the Chip
                              child: Text(
                                widget.dueDate == null ? widget.status : context.tr(widget.status),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            backgroundColor: widget.status == "Paid"
                                ? hexToColor('#5BC236')
                                : isDueDatePassed(
                                    widget.dueDate == null
                                        ? ''
                                        : DateFormat('dd MMM yyyy').format(
                                            tz.TZDateTime.from(widget.dueDate!, bangkok),
                                          ),
                                  )
                                    ? Colors.red
                                    : hexToColor('#ffa500'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          doctorName,
                          style: TextStyle(
                            color: theme.primaryColorLight,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (widget.invoiceId?.isEmpty ?? true) ? '#INV?????' : widget.invoiceId!,
                        style: TextStyle(color: textColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            imageIsSvg
                                ? SvgPicture.network(
                                    specialityImage,
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.fitHeight,
                                  )
                                : SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CachedNetworkImage(
                                      imageUrl: specialityImage,
                                      fadeInDuration: const Duration(milliseconds: 0),
                                      fadeOutDuration: const Duration(milliseconds: 0),
                                      errorWidget: (ccontext, url, error) {
                                        return Image.asset(
                                          'assets/images/default-avatar.png',
                                        );
                                      },
                                    ),
                                  ),
                            const SizedBox(width: 5),
                            Text(
                              speciality,
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy HH:mm').format(
                          tz.TZDateTime.from(widget.createdAt == null ? DateTime.now() : widget.createdAt!, bangkok),
                        ),
                        style: TextStyle(color: textColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          if (formType != 'view' && _localList.length < 5) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 35,
              child: GradientButton(
                onPressed: () {
                  setState(() {
                    _localList.add(BillingsDetails.empty());
                  });
                },
                colors: [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColor,
                ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.plus, size: 13, color: textColor),
                    const SizedBox(width: 5),
                    Text(
                      context.tr("addBillItem"),
                      style: TextStyle(fontSize: 12, color: textColor),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          ..._localList.asMap().entries.map((entry) {
            int index = entry.key;
            var detail = entry.value;
            detail.bookingsFee = doctorUserProfile.bookingsFee;
            return Card(
              key: ValueKey(detail.uniqueId),
              elevation: 12,
              color: theme.canvasColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.primaryColorLight),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    BillInput(
                      index: index,
                      detail: detail,
                      formType: formType,
                      theme: theme,
                      textColor: textColor,
                      name: 'title',
                      bookingsFee: doctorUserProfile.bookingsFee,
                      currencySymbol: currency,
                    ),
                    if (formType != 'view') ...[
                      BillInput(
                        index: index,
                        detail: detail,
                        formType: formType,
                        theme: theme,
                        textColor: textColor,
                        name: 'price',
                        bookingsFee: doctorUserProfile.bookingsFee,
                        currencySymbol: currency,
                      ),
                    ],
                    if (formType != 'view') ...[
                      BillInput(
                        index: index,
                        detail: detail,
                        formType: formType,
                        theme: theme,
                        textColor: textColor,
                        name: 'bookingsFee',
                        bookingsFee: doctorUserProfile.bookingsFee,
                        currencySymbol: currency,
                      ),
                    ],
                    if (formType != 'view') ...[
                      BillInput(
                        index: index,
                        detail: detail,
                        formType: formType,
                        theme: theme,
                        textColor: textColor,
                        name: 'bookingsFeePrice',
                        bookingsFee: doctorUserProfile.bookingsFee,
                        currencySymbol: currency,
                      ),
                    ],
                    BillInput(
                      index: index,
                      detail: detail,
                      formType: formType,
                      theme: theme,
                      textColor: textColor,
                      name: 'total',
                      bookingsFee: doctorUserProfile.bookingsFee,
                      currencySymbol: currency,
                    ),
                    if (formType != 'view')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              onPressed: () {
                                if (_localList.length > 1) {
                                  setState(() {
                                    _localList.removeAt(index);
                                  });
                                } else {
                                  // Bill should at least has 1 field
                                  showErrorSnackBar(context, context.tr('minBillError'));
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete, size: 13, color: textColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    context.tr("delete"),
                                    style: TextStyle(fontSize: 12, color: textColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Card(
            elevation: 12,
            color: theme.canvasColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.primaryColorLight),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  //TotalPrice
                  if (formType != 'view') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${context.tr("totalPrice")} :',
                              style: TextStyle(
                                color: theme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${NumberFormat("#,##0.00", "en_US").format(sumPrice)} $currency',
                            style: TextStyle(color: textColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
                  //totalFee
                  if (formType != 'view') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${context.tr("account_totalBookingsFeePrice")} :',
                              style: TextStyle(
                                color: theme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${NumberFormat("#,##0.00", "en_US").format(sumFee)} $currency',
                            style: TextStyle(color: textColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
                  //total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${context.tr("total")} :',
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${NumberFormat("#,##0.00", "en_US").format(sumTotal)} $currency',
                        style: TextStyle(color: textColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (formType != 'view')
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth, // this respects the width of the column
                  height: 35,
                  child: GradientButton(
                    onPressed: () {
                      if (billFormKey.currentState!.saveAndValidate()) {
                        final formValues = billFormKey.currentState!.value;
                        final dueDate = formValues['dueDate'];
                        widget.onBillSubmit(
                          sumPrice,
                          doctorUserProfile.bookingsFee,
                          sumFee,
                          sumTotal,
                          currency,
                          dueDate,
                          _localList,
                        );
                      }
                    },
                    colors: [theme.primaryColor, theme.primaryColorLight],
                    child: Text(
                      context.tr("submit"),
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
