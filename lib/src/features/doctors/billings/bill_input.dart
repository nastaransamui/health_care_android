import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/models/bills.dart';

class BillInput extends StatelessWidget {
  const BillInput({
    super.key,
    required this.index,
    required this.detail,
    required this.formType,
    required this.theme,
    required this.textColor,
    required this.name,
    required this.bookingsFee,
    required this.currencySymbol,
  });

  final int index;
  final String name;
  final BillingsDetails detail;
  final String formType;
  final ThemeData theme;
  final Color textColor;
  final double bookingsFee;
  final String currencySymbol;
  String? getInitialValue() {
    switch (name) {
      case 'title':
        return detail.title;
      case 'price':
        return detail.price == 0 ? '' : detail.price.toString();
      case 'bookingsFee':
        return bookingsFee.toString();
      case 'bookingsFeePrice':
        return detail.bookingsFeePrice.toString();
      case 'total':
        return detail.total.toString();
      default:
        return '';
    }
  }

  String? Function(String?)? getValidator(BuildContext context) {
    if (formType == 'view') return null;

    return (fieldValue) {
      if (fieldValue == null || fieldValue.trim().isEmpty) {
        return context.tr('required');
      }

      if (name == 'price' || name == 'bookingsFee' || name == 'bookingsFeePrice' || name == 'total') {
        final intVal = double.tryParse(fieldValue.trim());
        if (intVal == null || intVal <= 0) {
          return context.tr('mustBePositiveInt');
        }
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Semantics(
        label: context.tr(name),
        child: FormBuilderTextField(
          enabled: formType != 'view' ? name == 'title' || name == 'price' : false,
          enableSuggestions: true,
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: name == 'price' ? TextInputType.number : TextInputType.name,
          autovalidateMode: formType != 'view' ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          inputFormatters: name == 'price' ? [FilteringTextInputFormatter.digitsOnly] : [],
          validator: getValidator(context),
          name: '${name}_${detail.uniqueId}',
          initialValue: getInitialValue(),
          decoration: InputDecoration(
            errorStyle: TextStyle(color: Colors.redAccent.shade400),
            floatingLabelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            labelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            // labelText: context.tr(key),
            label: RichText(
              text: TextSpan(
                text: context.tr(name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: formType == 'view' ? theme.disabledColor : textColor),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            hintText: context.tr(name),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
            ),
            fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
            suffix: name != 'title'
                ? name == 'bookingsFee'
                    ? const Text('%')
                    : Text(currencySymbol)
                : null,
            filled: true,
            // prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
            isDense: true,
            alignLabelWithHint: true,
          ),
          onChanged: (val) {
            // Update the detail object directly
            switch (name) {
              case 'title':
                detail.title = val ?? '';
                break;
              case 'price':
                detail.price = double.tryParse(val ?? '0') ?? 0;

                final calculatedBookingFeePrice = double.parse(((detail.price * bookingsFee) / 100).toStringAsFixed(2));
                final calculatedTotal = double.parse((detail.price + calculatedBookingFeePrice).toStringAsFixed(2));

                detail.bookingsFeePrice = calculatedBookingFeePrice;
                detail.total = calculatedTotal;

                final formState = FormBuilder.of(context);

                // Update field values
                formState?.fields['bookingsFeePrice_${detail.uniqueId}']?.didChange(calculatedBookingFeePrice.toStringAsFixed(2));
                formState?.fields['total_${detail.uniqueId}']?.didChange(calculatedTotal.toStringAsFixed(2));

                // Re-validate them
                formState?.fields['bookingsFeePrice_${detail.uniqueId}']?.validate();
                formState?.fields['total_${detail.uniqueId}']?.validate();
                break;
            }
          },
        ),
      ),
    );
  }
}
