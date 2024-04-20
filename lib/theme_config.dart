
import 'package:flutter/material.dart';
import 'package:health_care/src/utils/hex_to_color.dart';

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
      primaryColor = '#673AB';
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
    case 'geenNature':
      primaryColor = '#009688';
      secondaryColor = '#76ff02';
      break;
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
        appBarTheme: AppBarTheme(
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
          backgroundColor: hexToColor(primaryColor),
          iconTheme: IconThemeData(
            color: hexToColor(secondaryColor),
          ),
        ),
        iconTheme: IconThemeData(
          color: hexToColor(secondaryColor)
        ),
        dividerColor: hexToColor(secondaryColor),
        primaryColor: hexToColor(primaryColor),
        primaryColorLight: hexToColor(secondaryColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(hexToColor(primaryColor)),
            foregroundColor: MaterialStateProperty.all(Colors.black),
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
        ),
      );
    default:
      return ThemeData.light().copyWith(
       appBarTheme: AppBarTheme(
          backgroundColor: hexToColor(primaryColor),
          iconTheme: IconThemeData(
            color: hexToColor(secondaryColor),
          ),
        ),
        iconTheme: IconThemeData(
          color: hexToColor(secondaryColor)
        ),
        dividerColor: hexToColor(secondaryColor),
        primaryColor: hexToColor(primaryColor),
        primaryColorLight: hexToColor(secondaryColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(hexToColor(primaryColor)),
            foregroundColor: MaterialStateProperty.all(Colors.black),
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
        ),
      );
  }
}