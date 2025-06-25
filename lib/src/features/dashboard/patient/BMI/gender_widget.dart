import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_choice_chip/flutter_3d_choice_chip.dart';

class GenderWidget extends StatefulWidget {
  final Function(int) onChange;
  final int gender;
  const GenderWidget({
    super.key,
    required this.onChange,
    required this.gender,
  });

  @override
  State<GenderWidget> createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  int _gender = 0;

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    final ChoiceChip3DStyle selectedStyle = ChoiceChip3DStyle(
        topColor: Theme.of(context).cardColor, backColor: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(20));

    final ChoiceChip3DStyle unselectedStyle = ChoiceChip3DStyle(
        topColor: brightness == Brightness.dark ? Colors.white : Colors.black,
        backColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20));
    if (_gender == 0) {
      _gender = widget.gender;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip3D(
              border: Border.all(
                color: _gender == 1 ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
              ),
              style: _gender == 1 ? selectedStyle : unselectedStyle,
              onSelected: () {
                setState(() {
                  _gender = 1;
                });
                widget.onChange(_gender);
              },
              onUnSelected: () {},
              selected: _gender == 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.asset(
                      "assets/images/man.png",
                      width: 50,
                    ),
                  ),
                  Text(
                    context.tr('male'),
                    style: TextStyle(
                      color: brightness == Brightness.dark
                          ? _gender == 1
                              ? Colors.white
                              : Colors.black
                          : _gender == 1
                              ? Colors.black
                              : Colors.white,
                    ),
                  )
                ],
              )),
          const SizedBox(
            width: 20,
          ),
          ChoiceChip3D(
              border: Border.all(
                color: _gender == 2 ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
              ),
              style: _gender == 2 ? selectedStyle : unselectedStyle,
              onSelected: () {
                setState(() {
                  _gender = 2;
                });
                widget.onChange(_gender);
              },
              selected: _gender == 2,
              onUnSelected: () {},
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.asset(
                      "assets/images/woman.png",
                      width: 50,
                    ),
                  ),
                  Text(
                    context.tr('female'),
                    style: TextStyle(
                      color: brightness == Brightness.dark
                          ? _gender == 2
                              ? Colors.white
                              : Colors.black
                          : _gender == 2
                              ? Colors.black
                              : Colors.white,
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
