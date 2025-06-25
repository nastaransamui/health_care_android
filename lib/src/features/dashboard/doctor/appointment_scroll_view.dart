import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:provider/provider.dart';

class AppointmentScrollView extends StatefulWidget {
  const AppointmentScrollView({super.key});

  @override
  State<AppointmentScrollView> createState() => _AppointmentScrollViewState();
}

class _AppointmentScrollViewState extends State<AppointmentScrollView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        // final total = appointmentProvider.total;

        return CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 2.0,
            height: 110,
            enlargeCenterPage: true,
            scrollDirection: Axis.vertical,
            autoPlay: false,
          ),
          items: doctorDataScroll.map((i) {
            final name = context.tr(i['title']);
            return InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: () {
                context.push(i['routeName']);
              },
              child: Card(
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: InkWell(
                  splashColor: Theme.of(context).primaryColor,
                  onTap: () {
                    context.push(i['routeName']);
                  },
                  child: SizedBox(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      leading: i['icon'],
                      title: Text(name),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
