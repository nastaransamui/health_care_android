import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/doctors_time_slot.dart';


class ViewTimeSlots extends StatefulWidget {
  final List<TimeType> periodArray;
  final String period;
  const ViewTimeSlots({
    super.key,
    required this.periodArray,
    required this.period,
  });

  @override
  State<ViewTimeSlots> createState() => _ViewTimeSlotsState();
}

class _ViewTimeSlotsState extends State<ViewTimeSlots> {
  @override
  Widget build(BuildContext context) {
    final capitalPeriod = widget.period[0].toUpperCase() + widget.period.substring(1);
    var brightness = Theme.of(context).brightness;
    return widget.periodArray.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        context.tr(capitalPeriod),
                        style: TextStyle(color: brightness == Brightness.dark ? Colors.white : Colors.black, fontSize: 16),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: widget.periodArray.asMap().entries.map((entry) {
                        // final i = entry.key;
                        final item = entry.value;
                        final priceFormatter = NumberFormat('#,##0.00');
                        if (item.active) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Card(
                                elevation: 12,
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Theme.of(context).primaryColorLight),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 100, // or MediaQuery.of(context).size.height * 0.5
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(color: Theme.of(context).primaryColorLight),
                                                    bottom: BorderSide(color: Theme.of(context).primaryColorLight),
                                                  ),
                                                ),
                                                child: Row(children: [Text(context.tr("time")), const Text(": "), Text(item.period)]),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(color: Theme.of(context).primaryColorLight),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(context.tr("price")),
                                                      const Text(": "),
                                                      Text("${priceFormatter.format(item.price)} ${item.currencySymbol}")
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(color: Theme.of(context).primaryColorLight),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(context.tr("bookingsFee")),
                                                    const Text(": "),
                                                    Text("${priceFormatter.format(item.bookingsFeePrice)} ${item.currencySymbol}"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Text(context.tr("totalPrice")),
                                                    const Text(": "),
                                                    Text("${priceFormatter.format(item.total)} ${item.currencySymbol}")
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        }

                        return const SizedBox.shrink(); // Return empty widget if inactive
                      }).toList(),
                    ),
                  ),
                ],
              )
            ],
          )
        : const SizedBox();
  }
}
