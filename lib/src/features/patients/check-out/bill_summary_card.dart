import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:health_care/src/utils/is_due_date_passed.dart';

class BillSummaryCard extends StatelessWidget {
  const BillSummaryCard({
    super.key,
    required this.bill,
  });

  final Bills bill;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String dueDate = DateFormat("dd MMM yyyy").format(bill.dueDate.toLocal());
    final String paymentDate = bill.paymentDate != '' ? DateFormat("dd MMM yyyy").format(bill.paymentDate.toLocal()) : '';

    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  context.tr('billSummary'),
                  style: TextStyle(fontSize: 20, color: theme.primaryColorLight),
                ),
              ),
              MyDivider(theme: theme),
              // date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('date'),
                      style: TextStyle(fontSize: 18, color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy').format(bill.createdAt),
                  ),
                ],
              ),
              // date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('invoiceId'),
                      style: TextStyle(fontSize: 18, color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(bill.invoiceId),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bill.status == 'Paid' ? context.tr('paymentDate') : context.tr('dueDate'),
                      style: TextStyle(fontSize: 18, color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bill.status == 'Paid' ? paymentDate : dueDate,
                    style: TextStyle(
                      color: bill.status != 'Paid' && isDueDatePassed(dueDate) ? Colors.red : textColor,
                    ),
                  ),
                  if (bill.status != 'Paid' && isDueDatePassed(dueDate))
                    const Text(
                      ' (OD)',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ],
              ),
              Center(
                child: Text(
                  context.tr('items'),
                  style: TextStyle(fontSize: 20, color: theme.primaryColorLight),
                ),
              ),
              MyDivider(theme: theme),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('title'),
                        style: TextStyle(fontSize: 18, color: theme.primaryColor),
                        textAlign: TextAlign.left,
                        softWrap: true,
                        maxLines: null,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          context.tr('price'),
                          style: TextStyle(fontSize: 18, color: theme.primaryColor),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...bill.billDetailsArray.map<Widget>(
                (detail) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Text(
                              detail.title,
                              textAlign: TextAlign.left,
                              softWrap: true,
                              maxLines: null,
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: NumberFormat("#,##0.00", "en_US").format(detail.total),
                                    ),
                                    TextSpan(text: ' ${bill.currencySymbol}', style: TextStyle(color: theme.primaryColorLight)),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                maxLines: null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              MyDivider(theme: theme),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('total'),
                        style: TextStyle(fontSize: 18, color: theme.primaryColorLight),
                        textAlign: TextAlign.left,
                        softWrap: true,
                        maxLines: null,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: NumberFormat("#,##0.00", "en_US").format(bill.total),
                                style: TextStyle(fontSize: 16, color: theme.primaryColor),
                              ),
                              TextSpan(
                                text: ' ${bill.currencySymbol}',
                                style: TextStyle(color: theme.primaryColorLight),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
