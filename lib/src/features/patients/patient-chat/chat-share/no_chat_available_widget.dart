import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:lottie/lottie.dart';

class NoChatAvailableWidget extends StatelessWidget {
  const NoChatAvailableWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    LottieDelegates chatLottiDeligates = LottieDelegates(
      values: [
        ValueDelegate.colorFilter(
          ['Shape Layer 3', '**'],
          value: ColorFilter.mode(
            theme.primaryColor,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
          ['Shape Layer 1', '**'],
          value: ColorFilter.mode(
            theme.canvasColor,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
          ['boat', 'Shape Layer 2', 'Group 1', 'Rectangle 1', 'Fill 2', '**'],
          value: ColorFilter.mode(
            theme.primaryColorLight,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
          ['boat', 'Shape Layer 2', 'Group 1', 'Rectangle 1', 'Fill 1','**'],
          value: ColorFilter.mode(
            textColor,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
          ['boat', 'Shape Layer 2', 'Group 1', 'Rectangle 2', '**'],
          value: ColorFilter.mode(
            textColor,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
          ['boat', 'Shape Layer 2', 'Group 1', 'Rectangle 3', '**'],
          value: ColorFilter.mode(
            theme.primaryColor,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
          ['boat', 'Shape Layer 2', 'Group 1', 'Rectangle 4', '**'],
          value: ColorFilter.mode(
            theme.primaryColor,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
          ['boat', 'Shape Layer 2', 'Group 1', 'Rectangle 5', '**'],
          value: ColorFilter.mode(
            theme.primaryColorLight,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
           ['boat', 'Shape Layer 2', "Rectangle 6", '**'],
          value: ColorFilter.mode(
            theme.primaryColorLight,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
           ['boat',"Shape Layer 1","Rectangle 2",  '**'],
          value: ColorFilter.mode(
            theme.primaryColor,
            BlendMode.src,
          ),
        ),
        ValueDelegate.colorFilter(
           ['boat',"Shape Layer 1","Rectangle 1",  '**'],
          value: ColorFilter.mode(
            textColor,
            BlendMode.src,
          ),
        ),
      ],
    );
    return FadeinWidget(
      isCenter: true,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Card(
              elevation: 1,
              color: theme.cardTheme.color,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColorLight),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('noChatsAvailable'),
                      style: TextStyle(color: theme.primaryColor, fontSize: 18),
                    ),
                    SizedBox(
                      // height: 50,
                      width: MediaQuery.of(context).size.width / 2,
                      child: Lottie.asset(
                        "assets/images/noChatData.json",
                        animate: true,
                        delegates: chatLottiDeligates,
                        fit: BoxFit.contain,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
