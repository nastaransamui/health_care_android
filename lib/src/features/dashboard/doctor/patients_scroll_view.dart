import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:jiffy/jiffy.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PatientsScrollView extends StatefulWidget {
  final DoctorUserProfile doctorProfile;
  final AppointmentProvider appointmentProvider;
  const PatientsScrollView({
    super.key,
    required this.doctorProfile,
    required this.appointmentProvider,
  });

  @override
  State<PatientsScrollView> createState() => _PatientsScrollViewState();
}

class _PatientsScrollViewState extends State<PatientsScrollView> {
  @override
  Widget build(BuildContext context) {
    final DoctorUserProfile doctorProfile = widget.doctorProfile;
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return CarouselSlider(
      options: CarouselOptions(
        height: 215.0,
        autoPlay: false,
        enlargeCenterPage: true,
      ),
      items: dcotorsDashboarPatientHeader.map((i) {
        return Builder(
          builder: (BuildContext context) {
            final int args = i['title'] == "totalPatient"
                ? doctorProfile.patientsId.length
                : i['title'] == "reservations"
                    ? doctorProfile.reservationsId.length
                    : widget.appointmentProvider.total;
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                color: theme.canvasColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 5.0,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 45,
                        child: ListTile(
                          title: Center(
                            child: Text(
                              context.tr(i['title']!, args: ['$args']),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 105,
                        child: CircularPercentIndicator(
                          radius: 40.0,
                          animation: true,
                          animationDuration: 1200,
                          lineWidth: 5.0,
                          percent: i['percent']!,
                          center: i['image']!.isEmpty
                              ? const Text('load Lottie')
                              : Image.asset(
                                  i['image']!,
                                  width: 45,
                                  height: 45,
                                  color: textColor,
                                ),
                          circularStrokeCap: CircularStrokeCap.butt,
                          backgroundColor: Theme.of(context).primaryColorLight,
                          progressColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: Text(
                          Jiffy.now().yMMMEd,
                          style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
