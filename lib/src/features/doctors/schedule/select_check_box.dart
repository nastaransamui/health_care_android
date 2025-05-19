
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:health_care/models/doctors_time_slot.dart';


class SelectCheckBox extends StatefulWidget {
  final String period;
  final List<TimeType> periodArray;
  final Function(int index, TimeType time) updateFunction;
  final Function(List<TimeType> times) replaceFunction;
  final VoidCallback? removeGlobalError;
  const SelectCheckBox({
    super.key,
    required this.period,
    required this.periodArray,
    required this.updateFunction,
    required this.replaceFunction,
    this.removeGlobalError,
  });

  @override
  State<SelectCheckBox> createState() => _SelectCheckBoxState();
}

class _SelectCheckBoxState extends State<SelectCheckBox> {
  final TextEditingController sharedPriceController = TextEditingController();
  final List<TextEditingController> _controllers = [];
  final List<VoidCallback> _controllerListeners = [];
  final List<FocusNode> _focusNodes = [];

  bool get allSelected => widget.periodArray.every((e) => e.active);

  void selectAllToggle() {
    final updatedList = widget.periodArray.map((time) => time.copyWith(active: !allSelected)).toList();

    setState(() {
      widget.replaceFunction(updatedList);
    });
  }

  void updatePriceForAll(double value) {
    final updatedList = widget.periodArray.map((time) => time.copyWith(price: value)).toList();
    setState(() {
      widget.replaceFunction(updatedList);
    });
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
    final uniquePrices = widget.periodArray.map((e) => e.price).toSet();
    if (uniquePrices.length == 1 && widget.periodArray.first.price > 0) {
      sharedPriceController.text = toCurrencyString(
        widget.periodArray.first.price.toStringAsFixed(0),
        thousandSeparator: ThousandSeparator.Comma,
        mantissaLength: 0,
        trailingSymbol: '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant SelectCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.periodArray != widget.periodArray) {
      _initControllers(); // Refresh controllers if data changes
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _initControllers() {
    // If controllers already exist, update their text safely
    if (_controllers.length == widget.periodArray.length) {
      for (int i = 0; i < widget.periodArray.length; i++) {
        final price = widget.periodArray[i].price;
        final formatted = price > 0
            ? toCurrencyString(
                price.toString(),
                thousandSeparator: ThousandSeparator.Comma,
                mantissaLength: 0,
                trailingSymbol: '',
              )
            : '';

        if (_controllers[i].text != formatted) {
          // Update text without breaking focus
          final controller = _controllers[i];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            controller.value = controller.value.copyWith(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          });
        }
      }
      return;
    }

    // Dispose old controllers and remove listeners properly
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].removeListener(_controllerListeners[i]);
      _controllers[i].dispose();
    }

    _controllers.clear();
    _controllerListeners.clear();
// Create new controllers and listeners
    for (int i = 0; i < widget.periodArray.length; i++) {
      final price = widget.periodArray[i].price;
      final controller = TextEditingController(
        text: price > 0
            ? toCurrencyString(
                price.toString(),
                thousandSeparator: ThousandSeparator.Comma,
                mantissaLength: 0,
                trailingSymbol: '',
              )
            : '',
      );

      void listener() {
        if (!mounted) return;
        final text = controller.text;
        final parsed = double.tryParse(text.replaceAll(',', '')) ?? 0;
        //Schedule it after the current build complete
        Future.delayed(Duration.zero, () {
          if (mounted) {
            widget.updateFunction(i, widget.periodArray[i].copyWith(price: parsed));
          }
        });
      }

      controller.addListener(listener);

      _controllers.add(controller);
      _controllerListeners.add(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    final capitalPeriod = widget.period[0].toUpperCase() + widget.period.substring(1);
    final itemCount = widget.periodArray.length;
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: allSelected,
                      onChanged: (value) {
                        if (value == true) {
                          widget.removeGlobalError!();
                        }
                        selectAllToggle();
                      },
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      style: TextStyle(
                        color: brightness == Brightness.dark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      allSelected ? context.tr("deselectAll", args: [capitalPeriod]) : context.tr("selectAll", args: [capitalPeriod]),
                    ),
                  ],
                ),
              ),
              if (allSelected)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  child: TextFormField(
                    controller: sharedPriceController,
                    inputFormatters: [
                      CurrencyInputFormatter(
                        thousandSeparator: ThousandSeparator.Comma,
                        mantissaLength: 0,
                        trailingSymbol: '',
                      ),
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      labelText: context.tr("priceForAll"),
                      hintText: context.tr('enterPrice'),
                      suffixText: widget.periodArray.first.currencySymbol,
                      suffixStyle: TextStyle(color: Theme.of(context).primaryColorLight),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value.replaceAll(',', ''));
                      if (parsed != null) updatePriceForAll(parsed);
                    },
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                  spacing: 12, // Horizontal spacing
                  runSpacing: 12, // Vertical spacing
                  children: widget.periodArray.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    // Check if it's the last item and it's a single one in the last row
                    final isLastSingle = itemCount % 2 != 0 && i == itemCount - 1;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final itemWidth = isLastSingle
                        ? screenWidth - 20 // Full width with padding
                        : (screenWidth - 34) / 2; // Two items per row: 10 padding left + 10 right + 12 spacing

                    return SizedBox(
                      width: itemWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: item.active,
                                  onChanged: (value) {
                                    if (value == true) {
                                      widget.removeGlobalError!();
                                    }
                                    setState(() {
                                      widget.updateFunction(i, item.copyWith(active: !item.active));
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                Expanded(
                                  child: Text(
                                    item.period,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.active) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                key: ValueKey(item.period),
                                controller: _controllers[i],
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13),
                                inputFormatters: [
                                  CurrencyInputFormatter(
                                    thousandSeparator: ThousandSeparator.Comma,
                                    mantissaLength: 0,
                                    trailingSymbol: '',
                                  ),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                  isDense: true,
                                  labelText: context.tr("price"),
                                  labelStyle: const TextStyle(fontSize: 13),
                                  hintText: context.tr("price"),
                                  hintStyle: const TextStyle(fontSize: 13),
                                  suffixText: widget.periodArray.first.currencySymbol,
                                  suffixStyle: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 13,
                                  ),
                                  border: const OutlineInputBorder(),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.pinkAccent.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColorLight,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final parsed = double.tryParse(value?.replaceAll(",", "") ?? "");
                                  if (parsed == null || parsed == 0) {
                                    return context.tr("required");
                                  }
                                  return null;
                                },
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
