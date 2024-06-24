
import 'package:flutter/material.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/theme_config.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;

    final primaryLightColorCode = primaryLightColorCodeReturn(homeThemeName);
    final primaryDarkColorCode = primaryDarkColorCodeReturn(homeThemeName);
    final secondaryLightColorCode =
        secondaryLightColorCodeReturn(homeThemeName);
    final secondaryDarkColorCode = secondaryDarkColorCodeReturn(homeThemeName);
    var brightness = Theme.of(context).brightness;
    return Lottie.asset("assets/images/emptyResult.json",
        animate: true,
        delegates: LottieDelegates(values: [
          ValueDelegate.strokeColor(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['line', 'Shape 1', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.strokeColor(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['line', 'Shape 2', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.strokeColor(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['line', 'Shape 3', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'line', '**'],
            value: Colors.amber,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'hand', '1', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 13', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 17', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 20', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 22', '**'],
            value: Theme.of(context).primaryColor,
          ),

          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 23', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 26', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 27', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 28', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 29', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 30', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 31', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 32', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 34', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 35', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 36', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 39', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 44', 'Fill 1'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          //  ValueDelegate.opacity(
          //   const ['**', 'Group 44', '**'],
          //   value: 0,
          // ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 49', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 52', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 54', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 55', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 56', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 57', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 58', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 59', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 60', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 61', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 62', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 63', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 64', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 65', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 66', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 67', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 68', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 69', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 70', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 71', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 72', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 73', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 74', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 75', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 76', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 77', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 78', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 79', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 80', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 81', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 82', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 83', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 84', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 85', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 86', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 87', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 88', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 89', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 90', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 91', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 92', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 93', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 94', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 95', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 96', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 97', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 98', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 99', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 100', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 101', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 102', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 103', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 104', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 105', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 106', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 107', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 108', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 109', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 110', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 111', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 112', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 113', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 114', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 115', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 116', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 117', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 118', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 119', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 120', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 121', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 122', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 123', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 124', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 125', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 126', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 127', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 128', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 129', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 130', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 131', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 132', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 133', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 134', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 135', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 136', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 137', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 138', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 139', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 140', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 141', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 142', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 143', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 144', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 145', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 146', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 147', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 148', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 149', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 150', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 151', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 152', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 153', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 154', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 155', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 156', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 157', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 158', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 159', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 160', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 161', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 163', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 165', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 168', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 171', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 174', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 176', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
// Color.fromARGB(255, 255, 0, 212)
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 275', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 278', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 285', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 289', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 294', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 299', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 303', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 304', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 305', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 306', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 311', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 314', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 316', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 317', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 318', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 319', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 321', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 324', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 326', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 328', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 330', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 333', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 334', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 335', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 338', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 339', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 342', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 343', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 345', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 346', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 349', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 350', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 351', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 352', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 354', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 357', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 358', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 359', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 360', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 362', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 363', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 364', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 365', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 367', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 370', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 372', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 373', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 374', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 376', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 378', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 379', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 380', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 381', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 386', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 387', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 388', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 389', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 391', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 392', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 393', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 397', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 398', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 399', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 400', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 401', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 403', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 404', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 405', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 406', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 408', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 409', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 410', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 411', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 413', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 416', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 422', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 423', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 426', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 427', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 428', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 434', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 435', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 436', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 437', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 438', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 441', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 442', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 446', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 448', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 449', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 450', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 451', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 452', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 453', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 454', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 455', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 456', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 457', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 458', '**'],
              value: hexToColor(secondaryDarkColorCode)),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 460', '**'],
              value: Theme.of(context).primaryColorLight),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 462', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 467', '**'],
              value: Theme.of(context).primaryColor),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 479', '**'],
              value: Theme.of(context).canvasColor),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 480', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 482', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 485', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 487', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 488', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 489', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 490', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 491', '**'],
            value: Colors.grey,
          ),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 492', '**'],
              value: Theme.of(context).canvasColor),
        ]));
  }
}
