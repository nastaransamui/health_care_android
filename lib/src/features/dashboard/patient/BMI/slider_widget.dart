import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SliderWidget extends StatefulWidget {
  final Function(int) onChange;
  final int value;
  final String name;
  final String unit;

  final double min;

  final double max;
  const SliderWidget({
    super.key,
    required this.onChange,
    required this.value,
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late TextEditingController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _controller = TextEditingController(text: _value.toString());
  }

  @override
  void didUpdateWidget(covariant SliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 12,
          shape: const RoundedRectangleBorder(),
          child: Column(
            children: [
              Text(
                context.tr(widget.name),
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: TextField(
                      maxLength: 3,
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterText: '',
                        hintText: "-- ",
                        hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        int? intValue = int.tryParse(value);
                        if (intValue != null && intValue >= widget.min.toInt() && intValue <= widget.max.toInt()) {
                          setState(() {
                            _value = intValue;
                            _controller.text = intValue.toString();
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );
                          });
                          widget.onChange(intValue);
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    context.tr(widget.unit),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              Slider(
                min: widget.min,
                max: widget.max,
                value: widget.value.toDouble(),
                thumbColor: Theme.of(context).primaryColor,
                activeColor: Theme.of(context).primaryColorLight,
                onChanged: (value) {
                  setState(() {
                    _value = value.toInt();
                    _controller.text = _value.toString();
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  });
                  widget.onChange(_value);
                },
              )
            ],
          )),
    );
  }
}
