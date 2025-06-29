import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:delayed_display/delayed_display.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_lightbox/flutter_lightbox.dart';
import 'package:flutter_lightbox/image_type.dart';

import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:health_care/models/doctors.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:readmore/readmore.dart';
import 'package:timezone/timezone.dart' as tz;

class DoctorCard extends StatelessWidget {
  final Doctors singleDoctor;
  final Future<void> Function() getDataOnUpdate;
  final bool isExpanded;
  final void Function(int index) onToggle;
  final int index;
  const DoctorCard({
    super.key,
    required this.singleDoctor,
    required this.getDataOnUpdate,
    required this.isExpanded,
    required this.onToggle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final String doctorName = "Dr. ${singleDoctor.fullName}";
    final String doctorProfileImage = singleDoctor.profileImage;
    final encodedId = base64.encode(utf8.encode(singleDoctor.id.toString()));
    final bangkok = tz.getLocation('Asia/Bangkok');
    final ImageProvider<Object> finalImage = doctorProfileImage.isEmpty
        ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
        : CachedNetworkImageProvider(doctorProfileImage);
    final Color statusColor = singleDoctor.idle ?? false
        ? const Color(0xFFFFA812)
        : singleDoctor.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    final String speciality = singleDoctor.specialities.first.specialities;
    final String specialityImage = singleDoctor.specialities.first.image;
    double doctorStarRate =
        singleDoctor.rateArray.isEmpty ? 0 : singleDoctor.rateArray.reduce((acc, number) => acc + number) / singleDoctor.rateArray.length;
    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.primaryColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
                            context.push(Uri(path: '/doctors/profile/$encodedId').toString());
                          },
                          colors: [
                            Theme.of(context).primaryColorLight,
                            Theme.of(context).primaryColor,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.eye, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr("view"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MyDivider(theme: theme),
              // Profile Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          InkWell(
                            splashColor: theme.primaryColorLight,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            onTap: () {
                              context.push(Uri(path: '/doctors/profile/$encodedId').toString());
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: theme.primaryColorLight),
                                shape: BoxShape.rectangle,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                image: DecorationImage(fit: BoxFit.contain, image: finalImage),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 5,
                            bottom: 10,
                            child: AvatarGlow(
                              glowColor: statusColor,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.primaryColor, width: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8),
                        child: StarReviewWidget(
                          rate: doctorStarRate,
                          textColor: textColor,
                          starSize: 12,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Column beside profile image
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    context.push(Uri(path: '/doctors/profile/$encodedId').toString());
                                  },
                                  child: Text(
                                    doctorName,
                                    style: TextStyle(
                                      color: textColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SortIconWidget(
                                columnName: 'profile.fullName',
                                getDataOnUpdate: getDataOnUpdate,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    context.push(Uri(path: '/doctors/profile/$encodedId').toString());
                                  },
                                  child: Text(
                                    '#${singleDoctor.doctorsId}',
                                    style: TextStyle(
                                      color: theme.primaryColorLight,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SortIconWidget(
                                columnName: 'profile.id',
                                getDataOnUpdate: getDataOnUpdate,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  imageIsSvg
                                      ? SvgPicture.network(
                                          specialityImage,
                                          width: 15,
                                          height: 15,
                                          fit: BoxFit.fitHeight,
                                        )
                                      : SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CachedNetworkImage(
                                            imageUrl: specialityImage,
                                            fadeInDuration: const Duration(milliseconds: 0),
                                            fadeOutDuration: const Duration(milliseconds: 0),
                                            errorWidget: (ccontext, url, error) {
                                              return Image.asset(
                                                'assets/images/default-avatar.png',
                                              );
                                            },
                                          ),
                                        ),
                                  const SizedBox(width: 5),
                                  Text(
                                    speciality,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: 'profile.specialities.0.specialities',
                              getDataOnUpdate: getDataOnUpdate,
                            )
                          ],
                        ),
                        if (singleDoctor.clinicImages.isNotEmpty) ...[
                          Row(
                            children: [
                              ...singleDoctor.clinicImages.map((i) {
                                return InkWell(
                                  onTap: () {
                                    showGeneralDialog(
                                      context: context,
                                      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
                                        return LightBox(
                                          initialIndex: index,
                                          images: singleDoctor.clinicImages.map((e) => e.src).toList(),
                                          imageType: ImageType.network,
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Theme.of(context).primaryColorLight, width: 0.5),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    elevation: 5.0,
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.network(
                                      semanticLabel: i.tags[0].title,
                                      fit: BoxFit.cover,
                                      i.src,
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                ],
              ),
              MyDivider(theme: theme),
              //Join day
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${context.tr('joinDay')}: '),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(singleDoctor.createdAt, bangkok),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'createdAt',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDivider(theme: theme),
              // Gender
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${context.tr('gender')} '),
                          singleDoctor.gender.isEmpty
                              ? const Text('---')
                              : Text("${singleDoctor.gender == 'Mr' ? '👨' : '👩'} ${singleDoctor.gender}"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'profile.gender',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),

              MyDivider(theme: theme),
              // City
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('city')} '),
                          Text(
                            singleDoctor.city == '' ? '---' : singleDoctor.city,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(columnName: 'profile.city', getDataOnUpdate: getDataOnUpdate)
                  ],
                ),
              ),
              MyDivider(theme: theme),
              // State
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 3),
                          Text('${context.tr('state')} '),
                          Text(
                            singleDoctor.state == '' ? '---' : singleDoctor.state,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 3),
                    SortIconWidget(columnName: 'profile.state', getDataOnUpdate: getDataOnUpdate),
                  ],
                ),
              ),
              MyDivider(theme: theme),
              // Country
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('country')} '),
                          Text(
                            singleDoctor.country == '' ? '---' : singleDoctor.country,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(columnName: 'profile.country', getDataOnUpdate: getDataOnUpdate)
                  ],
                ),
              ),
              MyDivider(theme: theme),
              // AboutTitle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("${context.tr('about')}: ")),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'profile.aboutMe',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              // AboutReadMore
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ReadMoreText(
                  singleDoctor.aboutMe,
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: context.tr('readMore'),
                  trimExpandedText: context.tr('readLess'),
                  moreStyle: TextStyle(color: theme.primaryColorLight),
                  lessStyle: TextStyle(color: theme.primaryColor),
                ),
              ),
              MyDivider(theme: theme),
              InkWell(
                onTap: () => onToggle(index),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${context.tr('services')} :", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: isExpanded ? theme.primaryColorLight : theme.primaryColor,
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ServicesWidget(singleDoctor: singleDoctor),
                      )
                    : const SizedBox.shrink(),
              ),
              //
            ],
          ),
        ),
      ),
    );
  }
}

class ServicesWidget extends StatefulWidget {
  final Doctors singleDoctor;
  const ServicesWidget({
    super.key,
    required this.singleDoctor,
  });

  @override
  State<ServicesWidget> createState() => _ServicesWidgetState();
}

class _ServicesWidgetState extends State<ServicesWidget> {
  void showArrayDataModal(BuildContext context, String name, List<dynamic> data) {
    Widget children = Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(context.tr(name)),
          ),
          if (name == 'specialitiesServices') ...[
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                verticalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                top: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                left: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                right: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                ...[
                  ...[
                    ...data.map((e) {
                      return TableRow(children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              e,
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ]
                ]
              ],
            )
          ] else if (name == 'educations') ...[
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                verticalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                top: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                left: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                right: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          context.tr('collage'),
                        ),
                      ),
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: Center(
                          child: Text(
                            context.tr('degree'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          context.tr('yearOfCompletion'),
                        ),
                      ),
                    ),
                  ],
                ),
                ...[
                  ...[
                    ...data.map((e) {
                      final parsedDate = DateTime.parse(e.yearOfCompletion);
                      final formattedFromDate = DateFormat("yyyy MMM dd").format(parsedDate);
                      return TableRow(children: [
                        Center(
                          child: Text(
                            e.collage,
                          ),
                        ),
                        Center(
                          child: Text(
                            e.degree,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Center(
                          child: Text(
                            formattedFromDate,
                          ),
                        ),
                      ]);
                    }),
                  ]
                ]
              ],
            )
          ] else if (name == 'experinces') ...[
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                verticalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                top: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                left: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                right: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          context.tr('designation'),
                        ),
                      ),
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: Center(
                          child: Text(
                            context.tr('hospitalName'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          context.tr('from'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          context.tr('to'),
                        ),
                      ),
                    ),
                  ],
                ),
                ...[
                  ...[
                    ...data.map((e) {
                      String formattedFromDate = DateFormat("yyyy MMM dd").format(e.from);
                      String formattedToDate = DateFormat("yyyy MMM dd").format(e.to);
                      return TableRow(children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              e.designation,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              e.hospitalName,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              formattedFromDate,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              formattedToDate,
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ]
                ]
              ],
            )
          ] else if (name == 'awards') ...[
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                verticalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                top: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                left: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                right: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          context.tr('award'),
                        ),
                      ),
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: Center(
                          child: Text(
                            context.tr('year'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ...[
                  ...[
                    ...data.map((e) {
                      final parsedDate = DateTime.parse(e.year);
                      final formattedFromDate = DateFormat("yyyy MMM dd").format(parsedDate);
                      return TableRow(children: [
                        SizedBox(
                          height: 32,
                          child: Center(
                            child: Text(
                              e.award,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 32,
                          child: Center(
                            child: Text(
                              formattedFromDate,
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ]
                ]
              ],
            )
          ] else if (name == 'memberships') ...[
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                verticalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                top: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                left: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                right: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                ...[
                  ...[
                    ...data.map((e) {
                      return TableRow(children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              e.membership,
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ]
                ]
              ],
            )
          ] else if (name == 'registrations') ...[
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                verticalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                top: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                left: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                right: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          context.tr('registration'),
                        ),
                      ),
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: Center(
                          child: Text(
                            context.tr('year'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ...[
                  ...[
                    ...data.map((e) {
                      final parsedDate = DateTime.parse(e.year);
                      final formattedFromDate = DateFormat("yyyy MMM dd").format(parsedDate);
                      return TableRow(children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              e.registration,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              formattedFromDate,
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ]
                ]
              ],
            )
          ]
        ],
      ),
    );
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).canvasColor,
      barrierColor: Theme.of(context).cardColor.withAlpha((0.8 * 255).round()),
      constraints: BoxConstraints(
        maxHeight: double.infinity,
        minWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height / 5,
      ),
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (context) {
        return Padding(padding: const EdgeInsets.all(8), child: SingleChildScrollView(child: children));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          // Seprate tablate from mobile with 1 or 2 rows
          if (useMobileLayout) ...[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'specialitiesServices',
                      widget.singleDoctor.specialitiesServices,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('services')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'educations',
                      widget.singleDoctor.educations,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('educations')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'experinces',
                      widget.singleDoctor.experinces,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('experinces')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'awards',
                      widget.singleDoctor.awards,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('awards')),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'memberships',
                      widget.singleDoctor.memberships,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: useMobileLayout ? 8.0 : 18.0),
                    child: Chip(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).primaryColorLight,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                      padding: const EdgeInsets.all(0),
                      label: Text(context.tr('memberships')),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'registrations',
                      widget.singleDoctor.registrations,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('registrations')),
                  ),
                )
              ],
            ),
          ] else ...[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'specialitiesServices',
                      widget.singleDoctor.specialitiesServices,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('services')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'educations',
                      widget.singleDoctor.educations,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('educations')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'experinces',
                      widget.singleDoctor.experinces,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('experinces')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'awards',
                      widget.singleDoctor.awards,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('awards')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'memberships',
                      widget.singleDoctor.memberships,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: useMobileLayout ? 8.0 : 18.0),
                    child: Chip(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).primaryColorLight,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                      padding: const EdgeInsets.all(0),
                      label: Text(context.tr('memberships')),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showArrayDataModal(
                      context,
                      'registrations',
                      widget.singleDoctor.registrations,
                    );
                  },
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                    padding: const EdgeInsets.all(0),
                    label: Text(context.tr('registrations')),
                  ),
                )
              ],
            ),
          ]
        ],
      ),
    );
  }
}
