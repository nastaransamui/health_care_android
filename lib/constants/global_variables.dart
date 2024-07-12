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
    "routeName": "/doctors_dashboard/appointments/this_week"
  },
  {
    "title": "todayPatients",
    "icon": const Icon(Icons.medication),
    "routeName": "/doctors_dashboard/appointments/today"
  },
];
List doctorsDashboardLink = [
  {
    'name': 'appointments',
    'routeName': "/doctors_dashboard/appointments",
    "icon": const FaIcon(FontAwesomeIcons.calendarCheck),
  },
  {
    'name': 'myPatients',
    'routeName': "/doctors_dashboard/my-patients",
    "icon": const FaIcon(FontAwesomeIcons.userInjured),
  },
  {
    'name': 'scheduleTiming',
    'routeName': "/doctors_dashboard/schedule-timing",
    "icon": const FaIcon(FontAwesomeIcons.hourglassStart),
  },
  {
    'name': 'availableTiming',
    'routeName': "/doctors_dashboard/available-timing",
    "icon": const FaIcon(FontAwesomeIcons.clock),
  },
  {
    'name': 'invoices',
    'routeName': "/doctors_dashboard/invoices",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoice),
  },
  {
    'name': 'accounts',
    'routeName': "/doctors_dashboard/accounts",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoiceDollar),
  },
  {
    'name': 'reviews',
    'routeName': "/doctors_dashboard/reviews",
    "icon": const FaIcon(FontAwesomeIcons.star),
  },
  {
    'name': 'message',
    'routeName': "/doctors_dashboard/message",
    "icon": const FaIcon(FontAwesomeIcons.comments),
  },
  {
    'name': 'profileSettings',
    'routeName': "/doctors_dashboard/doctors_profile",
    "icon": const FaIcon(FontAwesomeIcons.userCog),
  },
  {
    'name': 'socialMedia',
    'routeName': "/doctors_dashboard/socialMedia",
    "icon": const FaIcon(FontAwesomeIcons.shareAlt),
  },
  {
    'name': 'changePassword',
    'routeName': "/doctors_dashboard/changePassword",
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

List patientsDashboardLink = [
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
    'routeName': "/patient_dashboard/patient_profile",
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