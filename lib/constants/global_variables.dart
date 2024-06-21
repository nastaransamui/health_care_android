import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
String ipApiUrl = 'http://ip-api.com/json';
const double expandedHeight = 250;

List vitalBoxList = [
  {
    "title": 'heartRate',
    "icon": "assets/images/heartRate.json",
    "image": "",
    "unit": "bpm"
  },
  {
    "title": 'bodyTemp',
    "icon": "assets/images/bodyTemp.json",
    "image": "",
    "unit": "°c"
  },
  {
    "title": 'weight',
    "icon": "assets/images/weight.json",
    "image": "",
    "unit": "kg"
  },
  {
    'title': 'height',
    "icon": "",
    "image": "assets/images/height.png",
    "unit": "cm"
  },
];

List patinetDataScroll = [
  {
    "title": "appointments",
    "icon": const Icon(Icons.book_online),
    "routeName": "/patient_dashboard/appointments"
  },
  {
    "title": "prescriptions",
    "icon": const Icon(Icons.medication),
    "routeName": "/patient_dashboard/prescriptions"
  },
  {
    "title": "medicalRecords",
    "icon": const Icon(Icons.medication),
    "routeName": "/patient_dashboard/medicalRecords"
  },
  {
    "title": "billings",
    "icon": const Icon(Icons.attach_money),
    "routeName": "/patient_dashboard/billings"
  }
];

List elements = [
  {
    'name': 'favourites',
    'routeName': "/patient_dashboard/favourites",
    "icon": const FaIcon(FontAwesomeIcons.columns),
  },
  {
    'name': 'dependent',
    'routeName': "/patient_dashboard/dependent",
    "icon": const FaIcon(FontAwesomeIcons.users),
  },
  {
    'name': 'message',
    'routeName': "/patient_dashboard/message",
    "icon": const FaIcon(FontAwesomeIcons.comments),
  },
  {
    'name': 'orders',
    'routeName': "/patient_dashboard/orders",
    "icon": const FaIcon(FontAwesomeIcons.listAlt),
  },
  {
    'name': 'addMedicalRecords',
    'routeName': "/patient_dashboard/addMedicalRecords",
    "icon": const FaIcon(FontAwesomeIcons.clipboard),
  },
  {
    'name': 'medicalDetails',
    'routeName': "/patient_dashboard/medicalDetails",
    "icon": const FaIcon(FontAwesomeIcons.fileMedicalAlt),
  },
  {
    'name': 'profileSettings',
    'routeName': "/patient_dashboard/profileSettings",
    "icon": const FaIcon(FontAwesomeIcons.userCog),
  },
  {
    'name': 'changePassword',
    'routeName': "/patient_dashboard/changePassword",
    "icon": const FaIcon(FontAwesomeIcons.lock),
  },
];

    final key = encrypt.Key.fromUtf8(dotenv.env['ENCRYPT_32_KEY']!);
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));