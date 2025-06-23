import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:provider/provider.dart';

import 'package:health_care/models/reviews.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';

class ReplyButtonSheet extends StatefulWidget {
  final Reviews? review;
  final PatientReviews? patientReviews;
  final String replyTo;
  const ReplyButtonSheet({
    super.key,
    required this.replyTo,
    this.review,
    this.patientReviews,
  });

  @override
  State<ReplyButtonSheet> createState() => _ReplyButtonSheetState();
}

class _ReplyButtonSheetState extends State<ReplyButtonSheet> {
  final ScrollController scrollController = ScrollController();
  final replyFormKey = GlobalKey<FormBuilderState>();

  Future<void> onSubmitEditBank() async {
    final isValid = replyFormKey.currentState?.saveAndValidate() ?? false;
    final String roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!isValid) {
      // Errors will automatically be shown next to each field including RadioGroup
      return;
    }

    final formData = replyFormKey.currentState!.value;

    if (replyFormKey.currentState!.validate()) {
      String authorId = "";
      if (roleName == 'doctors') {
        authorId = authProvider.doctorsProfile!.userId;
      } else if (roleName == 'patient') {
        authorId = authProvider.patientProfile!.userId;
      }
      var payload = {
        "authorId": authorId,
        "parentId": widget.replyTo == 'patient' ? widget.review?.id : widget.patientReviews?.id,
        "role": roleName,
        "title": formData['title'],
        "body": formData['body'],
        "replies": []
      };
      Navigator.pop(context, payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Reviews? review = widget.review;
    final PatientReviews? patientReviews = widget.patientReviews;
    final String replyTo = widget.replyTo;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final PatientUserProfile? patientUserProfile = review?.patientProfile;
    final DoctorUserProfile? doctorUserProfile = patientReviews?.doctorProfile;
    final String? profileImage = replyTo == 'patient' ? patientUserProfile?.profileImage : doctorUserProfile?.profileImage;
    final encodedId = replyTo == 'patient'
        ? base64.encode(utf8.encode(patientUserProfile!.id.toString()))
        : base64.encode(utf8.encode(doctorUserProfile!.id.toString()));
    final String name = replyTo == 'patient'
        ? "${patientUserProfile!.gender}${patientUserProfile.gender.isNotEmpty ? '. ' : ''}${patientUserProfile.fullName}"
        : "Dr. ${doctorUserProfile!.fullName}";
    final ImageProvider<Object> avatarImage = profileImage!.isEmpty
        ? replyTo == 'patient'
            ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
            : const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
        : CachedNetworkImageProvider(profileImage);
    final Color statusColor = replyTo == 'patient'
        ? patientUserProfile!.idle ?? false
            ? const Color(0xFFFFA812)
            : patientUserProfile.online
                ? const Color(0xFF44B700)
                : const Color.fromARGB(255, 250, 18, 2)
        : doctorUserProfile!.idle ?? false
            ? const Color(0xFFFFA812)
            : doctorUserProfile.online
                ? const Color(0xFF44B700)
                : const Color.fromARGB(255, 250, 18, 2);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("replyTo", args: [name])),
        automaticallyImplyLeading: false, // Removes the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (replyTo == 'patient') {
                              context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString());
                            } else {
                              context.push(Uri(path: '/doctors/profile/$encodedId').toString());
                            }
                          },
                          child: CircleAvatar(
                            backgroundImage: avatarImage,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
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
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (replyTo == 'patient') {
                                  context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString());
                                } else {
                                  context.push(Uri(path: '/doctors/profile/$encodedId').toString());
                                }
                              },
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: theme.primaryColorLight,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '#${replyTo == 'patient' ? review!.reviewId : patientReviews!.reviewId}',
                              style: TextStyle(
                                color: theme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: theme.primaryColor),
              FormBuilder(
                key: replyFormKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Semantics(
                        label: context.tr('title'),
                        child: FormBuilderTextField(
                          name: 'title',
                          enableSuggestions: true,
                          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (fieldValue) {
                            if (fieldValue == null || fieldValue.isEmpty) {
                              return context.tr('required');
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.redAccent.shade400),
                            floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                            labelStyle: TextStyle(color: theme.primaryColorLight),
                            // labelText: context.tr(key),
                            label: RichText(
                              text: TextSpan(
                                text: context.tr('title'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                                children: const [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            hintText: context.tr('title'),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
                            ),
                            fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
                            filled: true,
                            // prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
                            isDense: true,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      label: context.tr('body'),
                      child: FormBuilderTextField(
                        name: 'body',
                        maxLines: 5,
                        enableSuggestions: true,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (fieldValue) {
                          if (fieldValue == null || fieldValue.isEmpty) {
                            return context.tr('required');
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.redAccent.shade400),
                          floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                          labelStyle: TextStyle(color: theme.primaryColorLight),
                          // labelText: context.tr(key),
                          label: RichText(
                            text: TextSpan(
                              text: context.tr('body'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                              children: const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          hintText: context.tr('body'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
                          ),
                          fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
                          filled: true,
                          // prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
                          isDense: true,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                        child: GradientButton(
                          onPressed: () {
                            onSubmitEditBank();
                          },
                          colors: [
                            theme.primaryColorLight,
                            theme.primaryColor,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.reply, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr("replyTo", args: [name]),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
