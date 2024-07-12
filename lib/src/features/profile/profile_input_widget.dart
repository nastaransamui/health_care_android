import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

InputDecoration decoration(BuildContext context, String labelText){
  return InputDecoration(
      labelText: labelText,
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pinkAccent.shade400, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pinkAccent.shade400, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 14.0,
      horizontal: 8,
    ),
    border: const OutlineInputBorder(),
    labelStyle: TextStyle(
      color: Theme.of(context).primaryColor,
    ),
  );
}

class ProfileInputWidget extends StatefulWidget {
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputFormatter? inputFormatters;
  final TextInputType? keyboardType;
  final String lable;
  final int? minLines;
  final Widget? suffixIcon;
  final void Function()? onTap;
  const ProfileInputWidget({
    super.key,
    this.validator,
    required this.controller,
    required this.readOnly,
    this.inputFormatters,
    this.keyboardType,
    required this.lable,
     this.minLines,
    this.onTap,
    this.suffixIcon,
  });

  @override
  State<ProfileInputWidget> createState() => _ProfileInputWidgetState();
}

class _ProfileInputWidgetState extends State<ProfileInputWidget> {
  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    var textColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Semantics(
        label: widget.lable,
        child: TextFormField(
          restorationId: widget.lable,
          readOnly: widget.readOnly,
          controller: widget.controller,
          maxLines: null,
          minLines: widget.minLines,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: widget.inputFormatters == null ? [] : [widget.inputFormatters!],
          keyboardType: widget.keyboardType ?? TextInputType.name,
          enableSuggestions: true,
          validator: widget.validator,
          style: TextStyle(color: widget.readOnly ? Theme.of(context).disabledColor : textColor),
          decoration: InputDecoration(
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pinkAccent.shade400, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pinkAccent.shade400, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 8,
            ),
            border: const OutlineInputBorder(),
            labelStyle: TextStyle(
              color: widget.readOnly ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
            ),
            labelText: widget.lable,
            alignLabelWithHint: true,
            suffixIcon: widget.suffixIcon
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
