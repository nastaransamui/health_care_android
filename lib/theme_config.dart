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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
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
            backgroundColor:
                WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return hexToColor(primaryColor);
              } else if (states.contains(WidgetState.disabled)) {
                return Colors.grey[400];
              } else {
                return hexToColor(primaryColor);
              }
            }), //WidgetStateProperty.all(hexToColor(primaryColor)),
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
        // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color.fromARGB(255, 255, 0, 76)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: hexToColor(primaryColor),
          primary: hexToColor(primaryColor),
          brightness: Brightness.dark,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: hexToColor(secondaryColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: hexToColor(secondaryColor)),
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          
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
          titleTextStyle:
              const TextStyle(fontFamily: 'Roboto_Condensed', fontSize: 18.0),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: hexToColor(primaryColor),
          primary: hexToColor(primaryColor),
          brightness: Brightness.light,
        ),

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
            titleTextStyle: const TextStyle(
                fontFamily: 'Roboto_Condensed', fontSize: 18.0)),
      );
  }
}

String primaryLightColorCodeReturn(String homeThemeName) {
  switch (homeThemeName) {
    case 'joker':
      return '#EA4D83';
    case 'cloud':
      return '#6573C3';
    case 'greenLeaf':
      return '#6FBF73';
    case 'money':
      return '#FFB333';
    case 'grayscale':
      return '#768B94';
    case 'violet':
      return '#8561C5';
    case 'violeta':
      return '#AF52BF';
    case 'violate':
      return '#A2CF6E';
    case 'deepBlue':
      return '#35BAF6';
    case 'ubuntu':
      return '#F28933';
    case 'geenNature':
      return '#33AB9F';
    case 'vampire':
      return '#F6685E';
    case 'gold':
      return '#FFA733';
    case 'botani':
      return '#86B25F';
    case 'littleQueen':
      return '#33C9DC';
    case 'brown':
      return '#93776C';
    case 'oceanBlue':
      return '#33F7FF';
    default:
      return '';
  }
}

String primaryDarkColorCodeReturn(String homeThemeName) {
  switch (homeThemeName) {
    case 'joker':
      return '#A01746';
    case 'cloud':
      return '#2C387E';
    case 'greenLeaf':
      return '#357A38';
    case 'money':
      return '#B27000';
    case 'grayscale':
      return '#3A4D55';
    case 'violet':
      return '#482880';
    case 'violeta':
      return '#6D1B7B';
    case 'violate':
      return '#618833';
    case 'deepBlue':
      return '#0276AA';
    case 'ubuntu':
      return '#A74B00';
    case 'geenNature':
      return '#00695F';
    case 'vampire':
      return '#AA2E25';
    case 'gold':
      return '#B26500';
    case 'botani':
      return '#486F27';
    case 'littleQueen':
      return '#008394';
    case 'brown':
      return '#543B32';
    case 'oceanBlue':
      return '#00ABB2';
    default:
      return '';
  }
}

String secondaryLightColorCodeReturn(String homeThemeName) {
  switch (homeThemeName) {
    case 'joker':
      return '#33C9DC';
    case 'cloud':
      return '#F73378';
    case 'greenLeaf':
      return '#7F97A2';
    case 'money':
      return '#6FBF73';
    case 'grayscale':
      return '#F7CE33';
    case 'violet':
      return '#EF6694';
    case 'violeta':
      return '#A2CF6E';
    case 'violate':
      return '#AF52BF';
    case 'deepBlue':
      return '#6573C3';
    case 'ubuntu':
      return '#AF52BF';
    case 'geenNature':
      return '#86B25F';
    case 'vampire':
      return '#7F97A2';
    case 'gold':
      return '#A38B82';
    case 'botani':
      return '#F381A7';
    case 'littleQueen':
      return '#F381A7';
    case 'brown':
      return '#46FFFF';
    case 'oceanBlue':
      return '#ECFF46';
    default:
      return '';
  }
}

String secondaryDarkColorCodeReturn(String homeThemeName) {
  switch (homeThemeName) {
    case 'joker':
      return '#008394';
    case 'cloud':
      return '#AB003C';
    case 'greenLeaf':
      return '#435761';
    case 'money':
      return '#357A38';
    case 'grayscale':
      return '#AB8700';
    case 'violet':
      return '#A52C55';
    case 'violeta':
      return '#618833';
    case 'violate':
      return '#6D1B7B';
    case 'deepBlue':
      return '#2C387E';
    case 'ubuntu':
      return '#6D1B7B';
    case 'geenNature':
      return '#486F27';
    case 'vampire':
      return '#435761';
    case 'gold':
      return '#624D45';
    case 'botani':
      return '#A84466';
    case 'littleQueen':
      return '#A84466';
    case 'brown':
      return '#10B2B2';
    case 'oceanBlue':
      return '#A2B210';
    default:
      return '';
  }
}
