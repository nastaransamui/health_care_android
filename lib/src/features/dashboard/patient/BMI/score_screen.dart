import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pretty_gauge/pretty_gauge.dart';

class ScoreScreen extends StatefulWidget {
  final double bmiScore;

  final int age;

  const ScoreScreen({
    super.key,
    required this.bmiScore,
    required this.age,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  String? bmiStatus;

  String? bmiInterpretation;

  Color? bmiStatusColor;

  @override
  Widget build(BuildContext context) {
    setBmiInterpretation(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.tr("bmiScore")),
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor),
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr("yourScore"),
                  style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                PrettyGauge(
                  gaugeSize: 300,
                  minValue: 0,
                  maxValue: 40,
                  segments: [
                    GaugeSegment('UnderWeight', 18.5, Colors.red),
                    GaugeSegment('Normal', 6.4, Colors.green),
                    GaugeSegment('OverWeight', 5, Colors.orange),
                    GaugeSegment('Obese', 10.1, Colors.pink),
                  ],
                  valueWidget: Text(
                    widget.bmiScore.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 40),
                  ),
                  currentValue: widget.bmiScore.toDouble(),
                  needleColor: Theme.of(context).primaryColorLight,
                  startMarkerStyle: const TextStyle(
                    fontSize: 10,
                  ),
                  endMarkerStyle: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  bmiStatus!,
                  style: TextStyle(fontSize: 20, color: bmiStatusColor!),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  bmiInterpretation!,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(context.tr('Re-calculate'))),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          // Share.share(
                          //     "Your BMI is ${bmiScore.toStringAsFixed(1)} at age $age");
                        },
                        child: Text(context.tr("Share"))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setBmiInterpretation(context) {
    if (widget.bmiScore > 30) {
      bmiStatus = tr("Obese");
      bmiInterpretation = tr("ObeseDesc");
      bmiStatusColor = Colors.pink;
    } else if (widget.bmiScore >= 25) {
      bmiStatus = tr("Overweight");
      bmiInterpretation = tr("OverweightDesc");
      bmiStatusColor = Colors.orange;
    } else if (widget.bmiScore >= 18.5) {
      bmiStatus = tr("Normal");
      bmiInterpretation = tr("NormalDesc");
      bmiStatusColor = Colors.green;
    } else if (widget.bmiScore < 18.5) {
      bmiStatus = tr("Underweight");
      bmiInterpretation = tr("UnderweightDesc");
      bmiStatusColor = Colors.red;
    }
  }
}
