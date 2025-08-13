import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/services/vital_service.dart';
import 'package:health_care/shared/vital_image.dart';
import 'package:health_care/stream_socket.dart';

class VitalSignScrollView extends StatefulWidget {
  final VitalSigns? vitalSigns;
  final String userId;
  const VitalSignScrollView({
    super.key,
    this.vitalSigns,
    required this.userId,
  });

  @override
  State<VitalSignScrollView> createState() => _VitalSignScrollViewState();
}

class _VitalSignScrollViewState extends State<VitalSignScrollView> {
  final VitalService vitalService = VitalService();
  final Map<String, TextEditingController> vitalSignsController = {
    'heartRate': TextEditingController(),
    'bodyTemp': TextEditingController(),
    'weight': TextEditingController(),
    'height': TextEditingController(),
  };
  @override
  void dispose() {
    for (var key in vitalSignsController.keys) {
      vitalSignsController[key]?.dispose();
    }
    super.dispose();
  }

  void showCustomDialog(
    BuildContext context,
    String title,
    String unit,
    List<Map<String, dynamic>> dataTable,
  ) async {
    final ThemeData theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
          titlePadding: const EdgeInsets.all(0),
          backgroundColor: theme.cardColor,
          title: Column(
            children: [
              ListTile(
                dense: true,
                title: Center(child: Text(context.tr(title))),
              ),
              Divider(
                color: theme.primaryColorLight,
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DataTable(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: theme.primaryColor, width: 0.7),
                    verticalInside: BorderSide(color: theme.primaryColor, width: 0.7),
                    bottom: BorderSide(color: theme.primaryColor, width: 0.7),
                    top: BorderSide(color: theme.primaryColor, width: 0.7),
                    left: BorderSide(color: theme.primaryColor, width: 0.7),
                    right: BorderSide(color: theme.primaryColor, width: 0.7),
                  ),
                  headingRowHeight: 32.0,
                  showBottomBorder: true,
                  horizontalMargin: dataTable.isNotEmpty ? 16 : 50,
                  columns: [
                    DataColumn(
                      label: Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text(
                            context.tr('id'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text(
                            "${context.tr('value')} / $unit",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text(
                            context.tr('date'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: dataTable.map((e) {
                    String formattedDate = DateFormat("yyyy MMM dd HH:mm").format(e['date']);
                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              e['id'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              e['value'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(double.maxFinite, 30),
                      elevation: 5.0,
                      foregroundColor: theme.primaryColor,
                      animationDuration: const Duration(milliseconds: 1000),
                      backgroundColor: theme.primaryColorLight,
                      shadowColor: theme.primaryColorLight,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      context.tr('close'),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final VitalSigns? vitalSigns = widget.vitalSigns;
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: false,
        enlargeCenterPage: true,
      ),
      items: vitalBoxList.map(
        (i) {
          return Builder(
            builder: (BuildContext context) {
              dynamic vitalMap;
              if (vitalSigns != null) {
                vitalMap = vitalSigns.toMap();
                if (vitalMap[i['title']].isNotEmpty) {
                  vitalSignsController[i['title']]?.text = vitalMap[i['title']][0]['value'].toString();
                }
              }
              var image = i['image'];
              var icon = i['icon'];
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
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.all(0),
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor,
                    onTap: () {
                      showCustomDialog(
                        context,
                        i['title'],
                        i['unit'],
                        vitalMap == null ? [] : vitalMap[i['title']],
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
                        Expanded(child: VitalImage(image: image, icon: icon, brightness: brightness)),
                        SizedBox(
                          height: 45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                child: TextField(
                                  onEditingComplete: () {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    var name = i['title'];
                                    var value = vitalSignsController[i['title']]?.text;
                                    var userId = widget.userId;
                                    if (value!.isNotEmpty) {
                                      socket.emit(
                                        'vitalSignsUpdate',
                                        {"name": name, "value": int.tryParse(value), "userId": userId},
                                      );
                                      vitalService.getVitalSignsData(context);
                                    }
                                  },
                                  maxLength: 3,
                                  controller: vitalSignsController[i['title']],
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    hintText: "-- ",
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ], // Only numbers can be entered
                                ),
                              ),
                              Text(
                                "${i['unit']}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
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
              );
            },
          );
        },
      ).toList(),
    );
  }
}
