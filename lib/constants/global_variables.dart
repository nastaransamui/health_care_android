import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

String ipApiUrl = 'http://ip-api.com/json';
const double expandedHeight = 250;
  final List<Map<String, dynamic>> bloodGValues = [
    {"title": 'A+', 'icon': '🅰️'},
    {"title": 'A-', 'icon': '🅰️'},
    {"title": 'B+', 'icon': '🅱️'},
    {"title": 'B-', 'icon': '🅱️'},
    {"title": 'AB+', 'icon': '🆎'},
    {"title": 'AB-', 'icon': '🆎'},
    {"title": 'O+', 'icon': '🅾️'},
    {"title": 'O-', 'icon': '🅾️'},
  ];
List dcotorsDashboarPatientHeader = [
  {"title": "totalPatient", "icon": "", "image": "assets/icon/doctor-dashboard-01.png", "percent": 0.8},
  {"title": "thisWeekPatients", "icon": "", "image": "assets/icon/doctor-dashboard-02.png", "percent": 0.5},
  {"title": "reservations", "icon": "", "image": "assets/icon/doctor-dashboard-03.png", "percent": 0.3}
];
List doctorDataScroll = [
  {"title": "thisWeekPatients", "icon": const Icon(Icons.date_range), "routeName": "/doctors/dashboard/appointments/this_week"},
  {"title": "todayPatients", "icon": const Icon(Icons.medication), "routeName": "/doctors/dashboard/appointments/today"},
];
List doctorsDashboardLink = [
  {
    'name': 'profileSettings',
    'routeName': "/doctors/dashboard/profile",
    "icon": const FaIcon(FontAwesomeIcons.userCog),
  },
  {
    'name': 'favourites',
    'routeName': "/doctors/dashboard/favourites",
    "icon": const FaIcon(FontAwesomeIcons.bookmark),
  },
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
    'routeName': "/doctors/dashboard/invoice",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoice),
  },
  {
    'name': 'billings',
    'routeName': "/doctors/dashboard/billings",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoice),
  },
  {
    'name': 'accounts',
    'routeName': "/doctors/dashboard/account",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoiceDollar),
  },
  {
    'name': 'reviews',
    'routeName': "/doctors/dashboard/reviews",
    "icon": const FaIcon(FontAwesomeIcons.comment),
  },
  // {
  //   'name': 'rates',
  //   'routeName': "/doctors/dashboard/rates",
  //   "icon": const FaIcon(FontAwesomeIcons.star),
  // },
  {
    'name': 'message',
    'routeName': "/doctors/dashboard/chat-doctor",
    "icon": const FaIcon(FontAwesomeIcons.comments),
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
  {"title": 'heartRate', "icon": "assets/images/heartRate.json", "image": "", "unit": "bpm"},
  {"title": 'bodyTemp', "icon": "assets/images/bodyTemp.json", "image": "", "unit": "°c"},
  {"title": 'weight', "icon": "assets/images/weight.json", "image": "", "unit": "kg"},
  {'title': 'height', "icon": "", "image": "assets/images/height.png", "unit": "cm"},
];


List socialPlatforms = ["facebook", "x", "instagram", "pinterest", "linkedin", "youtube"];
final Map<String, IconData> platformToIconMap = {
  "facebook": FontAwesomeIcons.facebookF, // Often facebookF for solid icon
  "x": FontAwesomeIcons.twitter,        // 'x' is typically x-twitter
  "instagram": FontAwesomeIcons.instagram,
  "pinterest": FontAwesomeIcons.pinterest,
  "linkedin": FontAwesomeIcons.linkedinIn, // Often linkedinIn for solid icon
  "youtube": FontAwesomeIcons.youtube,
};

List patientsDashboardLink = [
  {
    'name': 'profileSettings',
    'routeName': "/patient/dashboard/profile",
    "icon": const FaIcon(FontAwesomeIcons.userCog),
  },
  {
    'name': 'favourites',
    'routeName': "/patient/dashboard/favourites",
    "icon": const FaIcon(FontAwesomeIcons.bookmark),
  },
  {
    'name': 'appointments',
    'routeName': "/patient/dashboard/appointments",
    "icon": const FaIcon(FontAwesomeIcons.calendarCheck),
  },

  {
    'name': 'invoices',
    'routeName': "/patient/dashboard/invoice",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoice),
  },
  {
    'name': 'billings',
    'routeName': "/patient/dashboard/billings",
    "icon": const FaIcon(FontAwesomeIcons.fileInvoice),
  },
  {
    'name': 'dependent',
    'routeName': "/patient/dashboard/dependent",
    "icon": const FaIcon(FontAwesomeIcons.users),
  },
  {
    'name': 'reviews',
    'routeName': "/patient/dashboard/review",
    "icon": const FaIcon(FontAwesomeIcons.comments),
  },
  {
    'name': 'rates',
    'routeName': "/patient/dashboard/rates",
    "icon": const FaIcon(FontAwesomeIcons.star),
  },
  {
    'name': 'message',
    'routeName': "/patient/dashboard/patient-chat",
    "icon": const FaIcon(FontAwesomeIcons.comments),
  },
  // {
  //   'name': 'orders',
  //   'routeName': "/patient/dashboard/orders",
  //   "icon": const FaIcon(FontAwesomeIcons.listAlt),
  // },
  {
    'name': 'medicalrecords',
    'routeName': "/patient/dashboard/medicalrecords",
    "icon": const FaIcon(FontAwesomeIcons.clipboard),
  },
  {
    'name': 'prescriptions',
    'routeName': "/patient/dashboard/prescriptions",
    "icon": const FaIcon(FontAwesomeIcons.clipboard),
  },
  {
    'name': 'medicalDetails',
    'routeName': "/patient/dashboard/medicalDetails",
    "icon": const FaIcon(FontAwesomeIcons.fileMedicalAlt),
  },
  {
    'name': 'changePassword',
    'routeName': "/patient/dashboard/changePassword",
    "icon": const FaIcon(FontAwesomeIcons.lock),
  },
];

// Define your initial limits and skips as a constant Map
const Map<String, int> doctorPatientInitialLimitsAndSkips = {
  'appointMentsLimit': 5,
  'appointMentsSkip': 0,
  'prescriptionLimit': 5,
  'prescriptionSkip': 0,
  'medicalRecordLimit': 5,
  'medicalRecordSkip': 0,
  'billingLimit': 5,
  'billingSkip': 0,
};

List latestArticlesList = [
  {
    "img": "assets/images/blogs/blog-11.jpg",
    "writer": "John Doe",
    "date": "13 Aug, 2023",
    "title": "Health care – Making your clinic painless visit?",
    "shortDescription": "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
    "mainDescription":
        "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
  },
  {
    "img": "assets/images/blogs/blog-12.jpg",
    "writer": "Darren Elder",
    "date": "10 Sep, 2023",
    "title": "What are the benefits of Online Doctor Booking?",
    "shortDescription": "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
    "mainDescription":
        "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
  },
  {
    "img": "assets/images/blogs/blog-13.jpg",
    "writer": "Ruby Perrin",
    "date": "30 Oct, 2023",
    "title": "Benefits of consulting with an Online Doctor",
    "shortDescription": "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
    "mainDescription":
        "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
  },
  {
    "img": "assets/images/blogs/blog-14.jpg",
    "writer": "Sofia Brient",
    "date": "08 Nov, 2023",
    "title": "5 Great reasons to use an Online Doctor",
    "shortDescription": "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
    "mainDescription":
        "Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium Sed perspiciatis unde omnis iste natus error sit voluptatem accusantium",
  }
];

List<String> general0Images = [
  'assets/images/general0/meetOurDoctor.jpeg',
  'assets/images/general0/medicalClinics.webp',
  'assets/images/general0/specialities.jpg',
  'assets/images/general0/bestDoctors.webp',
  'assets/images/general0/howItsWork.jpg',
  'assets/images/general0/latestArticles.webp',
  'assets/images/general0/faq.jpg',
  'assets/images/general0/testimonial.jpg',
];
List<String> general0titles = ['', '', '', '', '', '', '', ''];

final key = encrypt.Key.fromUtf8(dotenv.env['ENCRYPT_32_KEY']!);
final iv = encrypt.IV.fromLength(16);

final encrypter = encrypt.Encrypter(encrypt.AES(key));

List<Map<String, String>> whyUsList = [
  {"title": "personalized", "svgIcon": "https://health-care.duckdns.org/assets/images/icons/health-care-love.svg"},
  {"title": "expert", "svgIcon": "https://health-care.duckdns.org/assets/images/icons/user-doctor.svg"},
  {"title": "regularly", "svgIcon": "https://health-care.duckdns.org/assets/images/icons/healthcare.svg"},
  {"title": "treatment", "svgIcon": "https://health-care.duckdns.org/assets/images/icons/drugs-svg.svg"},
  {"title": "minimally", "svgIcon": "https://health-care.duckdns.org/assets/images/icons/syringe-svg.svg"},
];

List<Map<String, String>> ourServicesList = [
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/features/feature-07.webp",
    "content": "heartValveDisease",
    "doctorImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-19.webp",
    "doctorName": "Dr Anoop Shetty"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/features/feature-08.webp",
    "content": "coronaryArteryDisease",
    "doctorImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-20.webp",
    "doctorName": "Dr Simon Pearse"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/features/feature-09.webp",
    "content": "highBloodPressure",
    "doctorImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-21.webp",
    "doctorName": "Dr Rajan Sharma"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/features/feature-10.webp",
    "content": "heartAttack",
    "doctorImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-22.webp",
    "doctorName": "Dr John Paul"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/features/feature-11.webp",
    "content": "heartPalpitations",
    "doctorImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-23.webp",
    "doctorName": "Dr Marry Peter"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/features/feature-12.webp",
    "content": "heartPalpitations",
    "doctorImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-24.webp",
    "doctorName": "Dr Juliana"
  },
];

List<Map<String, dynamic>> cardioHomeSpecialistsList = [
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-13.webp",
    "starsCount": 4.5,
    "specialities": 'cardioLogist',
    "doctorName": "Dr Jonathan Behar"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-14.webp",
    "starsCount": 4,
    "specialities": 'consultCardioLogist',
    "doctorName": "Dr Piers Clifford"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-15.webp",
    "starsCount": 4.5,
    "specialities": 'cardioLogist',
    "doctorName": "Dr Rajan Sharma"
  },
  {
    "mainImage": "https://health-care.duckdns.org/assets/images/doctors/doctor-16.webp",
    "starsCount": 5,
    "specialities": 'consultCardioLogist',
    "doctorName": "Dr Julian Collinson"
  },
];

List startDrawerTitleList = [
  {
    'name': 'home',
    'routeName': "/",
    "icon": const FaIcon(FontAwesomeIcons.home),
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.clinicMedical),
    'name': 'clinics',
    'injectClinics': true,
    'children': [],
  },
  {
    'name': 'pharmacy',
    'routeName': "/pharmacy",
    "icon": const FaIcon(FontAwesomeIcons.medkit),
  },
  {
    'name': 'blog',
    'routeName': "/blog",
    "icon": const FaIcon(FontAwesomeIcons.blog),
  },
  {
    'name': 'doctors',
    'routeName': '/doctors/search',
    "icon": const FaIcon(FontAwesomeIcons.userMd),
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.fileAlt),
    'name': "conditions",
    'children': [
      {
        'name': 'privacyPolicy',
        'routeName': '/privacy',
        'icon': const FaIcon(FontAwesomeIcons.userSecret),
      },
      {
        'name': 'termsAndConditions',
        'routeName': '/terms',
        'icon': const FaIcon(FontAwesomeIcons.fileContract),
      },
      {
        'name': 'faq',
        'routeName': '/faq',
        'icon': const FaIcon(FontAwesomeIcons.questionCircle),
      },
    ],
  },
  {
    'name': 'aboutUs',
    'routeName': "/about",
    "icon": const FaIcon(FontAwesomeIcons.infoCircle),
  },
  {
    'name': 'contactUs',
    'routeName': "/contact",
    "icon": const FaIcon(FontAwesomeIcons.envelopeOpenText),
  },
];
final DateTime now = DateTime.now();

// Morning: 9 AM to 12 PM
final DateTime morningStart = DateTime(now.year, now.month, now.day, 9);
final DateTime morningFinish = DateTime(now.year, now.month, now.day, 12);
final int morningMinutes = morningFinish.difference(morningStart).inMinutes;

// Afternoon: 1 PM to 4 PM
final DateTime afterNoonStart = DateTime(now.year, now.month, now.day, 13);
final DateTime afterNoonFinish = DateTime(now.year, now.month, now.day, 16);
final int afterNoonMinutes = afterNoonFinish.difference(afterNoonStart).inMinutes;

// Evening: 5 PM to 8 PM
final DateTime eveningStart = DateTime(now.year, now.month, now.day, 17);
final DateTime eveningFinish = DateTime(now.year, now.month, now.day, 20);
final int eveningMinutes = eveningFinish.difference(eveningStart).inMinutes;

  Map<String, dynamic> googlePayData = {
    "provider": "google_pay",
    "data": {
      "environment": "TEST",
      "apiVersion": 2,
      "apiVersionMinor": 0,
      "allowedPaymentMethods": [
        {
          "type": "CARD",
          "tokenizationSpecification": {
            "type": "PAYMENT_GATEWAY",
            "parameters": {"gateway": "example", "gatewayMerchantId": "exampleGatewayMerchantId"}
          },
          "parameters": {
            "allowedCardNetworks": ["VISA", "MASTERCARD"],
            "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
            "billingAddressRequired": true,
            "billingAddressParameters": {"format": "FULL", "phoneNumberRequired": true}
          }
        }
      ],
      "merchantInfo": {"merchantName": "Demo Merchant", "merchantId": "12345678901234567890"},
      "transactionInfo": {
        "countryCode": "US",
        "currencyCode": "USD",
        "totalPriceStatus": "FINAL",
        "totalPrice": "0.00" // will update this dynamically
      }
    }
  };