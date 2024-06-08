import 'package:flutter/material.dart';
import 'package:health_care/src/utils/hex_to_color.dart';

String primaryColorCodeReturn(String homeThemeName) {
  switch (homeThemeName) {
    case 'joker':
      return 'e52165';
    case 'cloud':
      return '3f51b5';
    case 'greenLeaf':
      return '4caf50';
    case 'money':
      return 'ffa000';
    case 'grayscale':
      return '546e7a';
    case 'violet':
      return '673AB7';
    case 'violeta':
      return '9c27b0';
    case 'violate':
      return '8bc34a';
    case 'deepBlue':
      return '03a9f4';
    case 'ubuntu':
      return 'EF6C00';
    case 'geenNature':
      return '009688';
    case 'vampire':
      return 'f44336';
    case 'gold':
      return 'FF9100';
    case 'botani':
      return '689F38';
    case 'littleQueen':
      return '00BCD4';
    case 'brown':
      return '795548';
    case 'oceanBlue':
      return '00f5ff';
    default:
      return '';
  }
}

ThemeData themDataLive(String homeThemeName, String homeThemeType) {
  String primaryColor = '';
  String secondaryColor = '';
  switch (homeThemeName) {
    case 'joker':
      primaryColor = '#e52165';
      secondaryColor = '#00BCD4';
      break;
    case 'cloud':
      primaryColor = '#3f51b5';
      secondaryColor = '#f50057';
      break;
    case 'greenLeaf':
      primaryColor = '#4caf50';
      secondaryColor = '#607D8B';
      break;
    case 'money':
      primaryColor = '#ffa000';
      secondaryColor = '#4caf50';
      break;
    case 'grayscale':
      primaryColor = '#546e7a';
      secondaryColor = '#f5c200';
      break;
    case 'violet':
      primaryColor = '#673AB7';
      secondaryColor = '#ec407a';
      break;
    case 'violeta':
      primaryColor = '#9c27b0';
      secondaryColor = '#8bc34a';
      break;
    case 'violate':
      primaryColor = '#8bc34a';
      secondaryColor = '#9c27b0';
      break;
    case 'deepBlue':
      primaryColor = '#03a9f4';
      secondaryColor = '#3f51b5';
      break;
    case 'ubuntu':
      primaryColor = '#EF6C00';
      secondaryColor = '#9C27B0';
      break;
    // case 'geenNature':
    //   primaryColor = '#009688';
    //   secondaryColor = '#76ff02';
    // break;
    case 'vampire':
      primaryColor = '#f44336';
      secondaryColor = '#607d8b';
      break;
    case 'gold':
      primaryColor = '#FF9100';
      secondaryColor = '#8d6e63';
      break;
    case 'botani':
      primaryColor = '#689F38';
      secondaryColor = '#F06292';
      break;
    case 'littleQueen':
      primaryColor = '#00BCD4';
      secondaryColor = '#F06292';
      break;
    case 'brown':
      primaryColor = '#795548';
      secondaryColor = '#18ffff';
      break;
    case 'oceanBlue':
      primaryColor = '#00f5ff';
      secondaryColor = '#e8ff18';
      break;
    default:
      primaryColor = '#009688';
      secondaryColor = '#76ff02';
  }
  switch (homeThemeType) {
    case 'dark':
      return ThemeData.dark().copyWith(
        textTheme: Typography().white.apply(fontFamily: 'Roboto_Condensed'),
        appBarTheme: AppBarTheme(
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Roboto_Condensed',
          ),
          backgroundColor: hexToColor(primaryColor),
          iconTheme: IconThemeData(
            color: hexToColor(secondaryColor),
          ),
        ),
        iconTheme: IconThemeData(color: hexToColor(secondaryColor)),
        dividerColor: hexToColor(secondaryColor),
        primaryColor: hexToColor(primaryColor),
        primaryColorLight: hexToColor(secondaryColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(hexToColor(primaryColor)),
            foregroundColor: WidgetStateProperty.all(Colors.black),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: hexToColor(secondaryColor),
          foregroundColor: Colors.black,
          focusColor: hexToColor(primaryColor),
          splashColor: hexToColor(primaryColor),
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: hexToColor(primaryColor),
        ),
        // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.redAccent),

        textSelectionTheme: TextSelectionThemeData(
          cursorColor: hexToColor(secondaryColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: hexToColor(secondaryColor)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                style: BorderStyle.solid, color: hexToColor(secondaryColor)),
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: hexToColor(secondaryColor),
          selectedTileColor: hexToColor(primaryColor),
          selectedColor: hexToColor(secondaryColor),
          textColor: hexToColor(primaryColor),
          titleTextStyle: const TextStyle(fontFamily: 'Roboto_Condensed', fontSize: 18.0)
        ),
      );
    default:
      return ThemeData.light().copyWith(
        textTheme: Typography().black.apply(fontFamily: 'Roboto_Condensed'),
        appBarTheme: AppBarTheme(
          backgroundColor: hexToColor(primaryColor),
          iconTheme: IconThemeData(
            color: hexToColor(secondaryColor),
          ),
        ),
        iconTheme: IconThemeData(color: hexToColor(secondaryColor)),
        dividerColor: hexToColor(secondaryColor),
        primaryColor: hexToColor(primaryColor),
        primaryColorLight: hexToColor(secondaryColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(hexToColor(primaryColor)),
            foregroundColor: WidgetStateProperty.all(Colors.black),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: hexToColor(secondaryColor),
          foregroundColor: Colors.black,
          focusColor: hexToColor(primaryColor),
          splashColor: hexToColor(primaryColor),
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: hexToColor(primaryColor),
        ),
        // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.redAccent),

        textSelectionTheme: TextSelectionThemeData(
          cursorColor: hexToColor(secondaryColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: hexToColor(secondaryColor)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                style: BorderStyle.solid, color: hexToColor(secondaryColor)),
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: hexToColor(secondaryColor),
          selectedTileColor: hexToColor(primaryColor),
          selectedColor: hexToColor(secondaryColor),
          textColor: hexToColor(primaryColor),
           titleTextStyle: const TextStyle(fontFamily: 'Roboto_Condensed', fontSize: 18.0)
        ),
      );
  }
}
