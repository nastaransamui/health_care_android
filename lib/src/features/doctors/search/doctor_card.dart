import 'dart:convert';
import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:health_care/models/doctors.dart';

class DoctorCard extends StatelessWidget {
  final Doctors singleDoctor;
  final double height;
  final Function increaseHight;
  final Function decreaseHight;
  const DoctorCard({
    super.key,
    required this.singleDoctor,
    required this.height,
    required this.increaseHight,
    required this.decreaseHight,
  });

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return Card(
      color: Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColorLight, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 5.0,
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        child: Column(
          children: [
            PhotoRowWidget(singleDoctor: singleDoctor),
            Divider(color: Theme.of(context).primaryColor, indent: 0, endIndent: 0, height: 5),
            LocationAboutWidget(singleDoctor: singleDoctor),
            Divider(
              color: Theme.of(context).primaryColor,
              indent: 0,
              endIndent: 0,
              height: 1,
            ),
            if (useMobileLayout ? height == 200 : height == 300) ...[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onPressed: () {
                      increaseHight(useMobileLayout);
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                  )
                ],
              )
            ] else ...[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onPressed: () {
                      decreaseHight(useMobileLayout);
                    },
                    icon: const Icon(Icons.arrow_drop_up),
                  )
                ],
              ),
              ServicesWidget(singleDoctor: singleDoctor)
            ]
          ],
        ),
      ),
    );
  }
}

class PhotoRowWidget extends StatefulWidget {
  final Doctors singleDoctor;
  const PhotoRowWidget({
    super.key,
    required this.singleDoctor,
  });

  @override
  State<PhotoRowWidget> createState() => _PhotoRowWidgetState();
}

class _PhotoRowWidgetState extends State<PhotoRowWidget> {
  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    final name = widget.singleDoctor.fullName;
    final doctorId = widget.singleDoctor.id;
    double doctorStarRate = widget.singleDoctor.rateArray.isEmpty
        ? 0
        : widget.singleDoctor.rateArray.reduce((acc, number) => acc + number) / widget.singleDoctor.rateArray.length;
    final encodedId = base64.encode(utf8.encode(doctorId.toString()));
    var subheading = context.tr(widget.singleDoctor.specialities[0].specialities);
    final specialitiesImageSrc = widget.singleDoctor.specialities[0].image;
    final uri = Uri.parse(specialitiesImageSrc);
    final imageIsSvg = uri.path.endsWith('.svg');
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: badges.Badge(
              stackFit: StackFit.passthrough,
              position: badges.BadgePosition.custom(
                start: 4,
                top: 4,
              ),
              badgeContent: AvatarGlow(
                startDelay: const Duration(milliseconds: 1000),
                glowColor: widget.singleDoctor.online ? Colors.green : Colors.transparent,
                glowShape: BoxShape.circle,
                animate: true,
                repeat: true,
                curve: Curves.fastOutSlowIn,
                child: Material(
                  elevation: 8.0,
                  shape: const CircleBorder(),
                  color: Colors.transparent,
                  child: Icon(
                    widget.singleDoctor.online ? Icons.check : Icons.close,
                    color: Colors.transparent,
                    size: 7,
                  ),
                ),
              ),
              badgeStyle: badges.BadgeStyle(
                padding: const EdgeInsets.all(1),
                shape: badges.BadgeShape.circle,
                badgeColor: widget.singleDoctor.online ? Colors.green : Colors.pink,
                elevation: 12,
              ),
              child: GestureDetector(
                onTap: () {
                  log(encodedId);
                  context.push(
                    Uri(path: '/doctors/profile/$encodedId').toString(),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(8),
                    ),
                    image: DecorationImage(
                      image: widget.singleDoctor.profileImage.isEmpty
                          ? const AssetImage(
                              'assets/images/doctors_profile.jpg',
                            ) as ImageProvider
                          : CachedNetworkImageProvider(
                              widget.singleDoctor.profileImage,
                            ),
                      fit: BoxFit.cover,
                    ),

                    // your own shape
                    shape: BoxShape.rectangle,
                  ),
                  height: useMobileLayout ? 90 : 150,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: SizedBox(
              height: useMobileLayout ? 80 : 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: useMobileLayout ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Dr. $name",
                          style: TextStyle(
                            color: brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: useMobileLayout ? 10 : 20,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(
                                Uri(path: '/doctors/profile/$encodedId').toString(),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subheading,
                        style: TextStyle(
                          color: brightness == Brightness.dark ? Colors.white : Colors.black,
                          fontSize: useMobileLayout ? 10 : 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                        ),
                        child: imageIsSvg
                            ? SvgPicture.network(
                                specialitiesImageSrc,
                                width: useMobileLayout ? 20 : 50,
                                height: useMobileLayout ? 20 : 50,
                                fit: BoxFit.fitHeight,
                              )
                            : CachedNetworkImage(
                                key: ValueKey(
                                  specialitiesImageSrc,
                                ),
                                width: useMobileLayout ? 20 : 50,
                                height: useMobileLayout ? 20 : 50,
                                imageUrl: specialitiesImageSrc,
                                errorWidget: (ccontext, url, error) {
                                  return Image.asset(
                                    'assets/images/default-avatar.png',
                                  );
                                },
                              ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: SizedBox(
                height: useMobileLayout ? 80 : 150,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: useMobileLayout ? MainAxisAlignment.end : MainAxisAlignment.spaceEvenly,
                  children: [
                    RatingStars(
                      value: doctorStarRate,
                      onValueChanged: (v) {},
                      starCount: 5,
                      starSize: 10,
                      valueLabelVisibility: false,
                      maxValue: 5,
                      starSpacing: 2,
                      maxValueVisibility: true,
                      animationDuration: const Duration(milliseconds: 1000),
                      starOffColor: const Color(0xffe7e8ea),
                      starColor: Colors.yellow,
                    ),
                    Text(
                      '${context.tr('gender')}: ${widget.singleDoctor.gender == 'Mr' ? '👨' : '👩'} ${widget.singleDoctor.gender}',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: useMobileLayout ? 10 : 20,
                      ),
                    ),
                    if (widget.singleDoctor.clinicImages.isNotEmpty) ...[
                      CarouselSlider(
                          options: CarouselOptions(
                            height: useMobileLayout ? 50.0 : 80,
                            autoPlay: true,
                            enlargeCenterPage: true,
                          ),
                          items: widget.singleDoctor.clinicImages.map((i) {
                            return Card(
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
                                width: useMobileLayout ? 50.0 : 80,
                                height: useMobileLayout ? 50.0 : 80,
                              ),
                            );
                          }).toList())
                    ] else ...[
                      SizedBox(
                        height: useMobileLayout ? 30.0 : 50.0,
                      )
                    ]
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class LocationAboutWidget extends StatefulWidget {
  final Doctors singleDoctor;

  const LocationAboutWidget({
    super.key,
    required this.singleDoctor,
  });

  @override
  State<LocationAboutWidget> createState() => _LocationAboutWidgetState();
}

class _LocationAboutWidgetState extends State<LocationAboutWidget> {
  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    final isCollapsed = ValueNotifier<bool>(true);
    return IntrinsicHeight(
      child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 12,
          ),
          child: Icon(
            Icons.location_on,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: Text(
                  widget.singleDoctor.city,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: useMobileLayout ? 10 : 14,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: Text(
                  widget.singleDoctor.state,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: useMobileLayout ? 10 : 14,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: Text(
                  widget.singleDoctor.country,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: useMobileLayout ? 10 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(
          width: 3,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: Theme.of(context).primaryColorLight,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  context.tr('about'),
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: isCollapsed,
                builder: (context, value, child) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            style: TextStyle(
                              color: brightness == Brightness.dark ? Colors.white : Colors.black,
                              fontSize: useMobileLayout ? 10 : 14,
                            ),
                            text: widget.singleDoctor.aboutMe.length <= 100
                                ? widget.singleDoctor.aboutMe
                                : widget.singleDoctor.aboutMe.substring(0, 100),
                          ),
                          if (widget.singleDoctor.aboutMe.length >= 100) ...[
                            TextSpan(
                                text: value ? context.tr('readMore') : context.tr('readLess'),
                                style: TextStyle(
                                  fontSize: useMobileLayout ? 10 : 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    isCollapsed.value = !isCollapsed.value;
                                    showModalBottomSheet(
                                      context: context,
                                      useSafeArea: true,
                                      isDismissible: true,
                                      showDragHandle: true,
                                      constraints: const BoxConstraints(
                                        maxHeight: double.infinity,
                                      ),
                                      scrollControlDisabledMaxHeightRatio: 1,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            widget.singleDoctor.aboutMe,
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        );
                                      },
                                    ).whenComplete(() {
                                      isCollapsed.value = !isCollapsed.value;
                                    });
                                  })
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        )
      ]),
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
    Widget children = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(context.tr(name)),
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
                      Center(
                        child: Text(
                          e,
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
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.collage,
                        ),
                      ),
                      Center(
                        child: Text(
                          e.degree,
                        ),
                      ),
                      Center(
                        child: Text(
                          e.yearOfCompletion,
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
                      Center(
                        child: Text(
                          e.designation,
                        ),
                      ),
                      Center(
                        child: Text(
                          e.hospitalName,
                        ),
                      ),
                      Center(
                        child: Text(
                          formattedFromDate,
                        ),
                      ),
                      Center(
                        child: Text(
                          formattedToDate,
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
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.award,
                        ),
                      ),
                      Center(
                        child: Text(
                          e.year,
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
                      Center(
                        child: Text(
                          e.membership,
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
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.registration,
                        ),
                      ),
                      Center(
                        child: Text(
                          e.year,
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
