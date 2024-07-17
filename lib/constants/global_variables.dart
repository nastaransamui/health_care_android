import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
String ipApiUrl = 'http://ip-api.com/json';
const double expandedHeight = 250;

List dcotorsDashboarPatientHeader =[
  {
    "title": "totalPatient",
    "icon": "",
    "image": "assets/icon/doctor-dashboard-01.png",
    "percent": 0.8
  },
  {
    "title": "thisWeekPatients",
    "icon": "",
    "image": "assets/icon/doctor-dashboard-02.png",
    "percent": 0.5
  },
  {
    "title": "reservations",
    "icon": "",
    "image": "assets/icon/doctor-dashboard-03.png",
    "percent": 0.3
  }
];
List doctorDataScroll = [
  {
    "title": "thisWeekPatients",
    "icon": const Icon(Icons.date_range),
    "routeName": "/doctors/dashboard/appointments/this_week"
  },
  {
    "title": "todayPatients",
    "icon": const Icon(Icons.medication),
    "routeName": "/doctors/dashboard/appointments/today"
  },
];
List doctorsDashboardLink = [
  {
    'name': 'appointments',
    'routeName': "/doctors/dashboard/appointments",
    "icon": const FaIcon(FontAwesomeIcons.calendarCheck),
  },
  {
    'name': 'myPatients',
    'routeName': "/doctors/dashboard/my-patients",
    "icon": const FaIcon(FontAwesomeIcons.userInjured),
  },
  {
    'name': 'scheduleTiming',
    'routeName': "/doctors/dashboard/schedule-timing",
    "icon": const FaIcon(FontAwesomeIcons.hourglassStart),
  },
  {
    'name': 'availableTiming',
    'routeName': "/doctors/dashboard/available-timing",
    "icon": const FaIcon(FontAwesomeIcons.clock),
  },
  {
    'name': 'invoices',
    'routeName': "/doctors/dashboard/invoices",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoice),
  },
  {
    'name': 'accounts',
    'routeName': "/doctors/dashboard/accounts",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoiceDollar),
  },
  {
    'name': 'reviews',
    'routeName': "/doctors/dashboard/reviews",
    "icon": const FaIcon(FontAwesomeIcons.star),
  },
  {
    'name': 'message',
    'routeName': "/doctors/dashboard/message",
    "icon": const FaIcon(FontAwesomeIcons.comments),
  },
  {
    'name': 'profileSettings',
    'routeName': "/doctors/dashboard/profile",
    "icon": const FaIcon(FontAwesomeIcons.userCog),
  },
  {
    'name': 'socialMedia',
    'routeName': "/doctors/dashboard/socialMedia",
    "icon": const FaIcon(FontAwesomeIcons.shareAlt),
  },
  {
    'name': 'changePassword',
    'routeName': "/doctors/dashboard/changePassword",
    "icon": const FaIcon(FontAwesomeIcons.lock),
  },
];
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
    "routeName": "/patient/dashboard/appointments"
  },
  {
    "title": "prescriptions",
    "icon": const Icon(Icons.medication),
    "routeName": "/patient/dashboard/prescriptions"
  },
  {
    "title": "medicalRecords",
    "icon": const Icon(Icons.medication),
    "routeName": "/patient/dashboard/medicalRecords"
  },
  {
    "title": "billings",
    "icon": const Icon(Icons.attach_money),
    "routeName": "/patient/dashboard/billings"
  }
];

List patientsDashboardLink = [
  {
    'name': 'favourites',
    'routeName': "/patient/dashboard/favourites",
    "icon": const FaIcon(FontAwesomeIcons.columns),
  },
  {
    'name': 'dependent',
    'routeName': "/patient/dashboard/dependent",
    "icon": const FaIcon(FontAwesomeIcons.users),
  },
  {
    'name': 'message',
    'routeName': "/patient/dashboard/message",
    "icon": const FaIcon(FontAwesomeIcons.comments),
  },
  {
    'name': 'orders',
    'routeName': "/patient/dashboard/orders",
    "icon": const FaIcon(FontAwesomeIcons.listAlt),
  },
  {
    'name': 'addMedicalRecords',
    'routeName': "/patient/dashboard/addMedicalRecords",
    "icon": const FaIcon(FontAwesomeIcons.clipboard),
  },
  {
    'name': 'medicalDetails',
    'routeName': "/patient/dashboard/medicalDetails",
    "icon": const FaIcon(FontAwesomeIcons.fileMedicalAlt),
  },
  {
    'name': 'profileSettings',
    'routeName': "/patient/dashboard/profile",
    "icon": const FaIcon(FontAwesomeIcons.userCog),
  },
  {
    'name': 'changePassword',
    'routeName': "/patient/dashboard/changePassword",
    "icon": const FaIcon(FontAwesomeIcons.lock),
  },
];

    final key = encrypt.Key.fromUtf8(dotenv.env['ENCRYPT_32_KEY']!);
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));