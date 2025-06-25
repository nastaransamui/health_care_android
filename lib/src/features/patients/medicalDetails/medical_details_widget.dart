import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/shared/vital_image.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';

class MedicalDetailsWidget extends StatefulWidget {
  static const String routeName = '/patient/dashboard/medicalDetails';
  const MedicalDetailsWidget({super.key});

  @override
  State<MedicalDetailsWidget> createState() => _MedicalDetailsWidgetState();
}

class _MedicalDetailsWidgetState extends State<MedicalDetailsWidget> {
  final ScrollController scrollController = ScrollController();

  double scrollPercentage = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    var brightness = theme.brightness;
    return ScaffoldWrapper(
      title: context.tr('vitalSigns'),
      children: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              double per = 0;
              if (scrollController.hasClients) {
                per = ((scrollController.offset / scrollController.position.maxScrollExtent));
              }
              if (per >= 0) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    setState(() {
                      scrollPercentage = 307 * per;
                    });
                  }
                });
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeinWidget(
                    isCenter: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: theme.primaryColorLight),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              context.tr('vitalSigns'),
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...vitalBoxList.map(
                    (i) {
                      var image = i['image'];
                      var icon = i['icon'];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 5.0,
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.all(0),
                            child: InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              onTap: () {
                                context.push(
                                  Uri(
                                    path: '/patient/dashboard/singleMedicalDetail',
                                    queryParameters: {'title': i["title"]},
                                  ).toString(),
                                );
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 45,
                                    child: ListTile(
                                      title: Center(
                                        child: Text(
                                          context.tr(i['title']!),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 100,
                                    child: VitalImage(
                                      image: image,
                                      icon: icon,
                                      brightness: brightness,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 45,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: Text(
                                            "${i['unit']}",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Text(
                            //   context.tr(i),
                            //   style: const TextStyle(fontSize: 16.0),
                            // ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
        ],
      ),
    );
  }
}
