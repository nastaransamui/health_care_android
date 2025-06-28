
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

final RegExp urlRegex = RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');

class SocialMediaWidget extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/socialMedia';
  const SocialMediaWidget({super.key});

  @override
  State<SocialMediaWidget> createState() => _SocialMediaWidgetState();
}

class _SocialMediaWidgetState extends State<SocialMediaWidget> {
  late final AuthProvider authProvider;
  final AuthService authService = AuthService();
  final ScrollController scrollController = ScrollController();
  bool _isProvidersInitialized = false;
  final socialMediaFormKey = GlobalKey<FormBuilderState>();
  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> onSubmitSocialMedia() async {
    final isValid = socialMediaFormKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) {
      return;
    }

    final formData = socialMediaFormKey.currentState!.value;

    var socialMedia = socialPlatforms.map(
      (e) {
        // Assuming formData is a Map<String, dynamic> from your FormBuilder
        return {"platform": e, "link": formData[e] ?? ''};
      },
    ).toList();
    var payload = {"userId": authProvider.doctorsProfile?.userId, "socialMedia": socialMedia};
    if (context.mounted) {
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      );
    }
    socket.emit('socialMediaUpdate', payload);
    socket.once('socialMediaUpdateReturn', (msg) {
      if (!context.mounted) {
        return;
      }
      // Navigator.pop(context);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }

        if (msg['status'] != 200) {
          // Show error message
            Navigator.pop(context);
          showErrorSnackBar(context, msg['message'] ?? 'An unknown error occurred.');
        } else {
          // Success: Update profile
          authService.updateProfile(context, msg['accessToken']);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final DoctorsProfile? doctorUserProfile = authProvider.doctorsProfile;
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    List<SocialMedia>? socialMediaList = doctorUserProfile?.userProfile.socialMedia;

    // Convert the list of SocialMedia objects into a Map for easy lookup
    // where the key is the platform name and the value is the link.
    final Map<String, String> existingSocialMediaLinks = {};
    if (socialMediaList != null) {
      for (var sm in socialMediaList) {
        existingSocialMediaLinks[sm.platform] = sm.link;
      }
    }
    return ScaffoldWrapper(
      title: context.tr('socialMedia'),
      children: SingleChildScrollView(
        controller: scrollController,
        child: FadeinWidget(
          isCenter: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.primaryColorLight),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          context.tr("socialMediaSetup"),
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
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.primaryColorLight),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: FormBuilder(
                    key: socialMediaFormKey,
                    initialValue: existingSocialMediaLinks,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          ...socialPlatforms.map((entry) {
                            final IconData platformIcon = platformToIconMap[entry] ?? Icons.link;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Semantics(
                                label: context.tr('${entry}_url'),
                                child: FormBuilderTextField(
                                  name: entry,
                                  enableSuggestions: true,
                                  validator: (fieldValue) {
                                    // If the field is empty, it's considered valid (not required)
                                    if (fieldValue == null || fieldValue.isEmpty) {
                                      return null;
                                    }

                                    // If it's not empty, validate against the URL regex
                                    if (!urlRegex.hasMatch(fieldValue)) {
                                      return context.tr('invalid_url_format'); // You'll need to define this translation key
                                    }

                                    return null; // Input is valid
                                  },
                                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(color: Colors.redAccent.shade400),
                                    floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                                    labelStyle: TextStyle(color: theme.primaryColorLight),
                                    // labelText: context.tr(key),
                                    label: Text(
                                      context.tr('${entry}_url'),
                                      style: TextStyle(color: textColor),
                                    ),
                                    hintText: context.tr('${entry}_url'),
                                    suffixIcon: SizedBox(
                                      // Wrap the icon in a SizedBox
                                      height: 24, // Explicitly set height (adjust as needed, typical icon size is 24)
                                      width: 24, // Explicitly set width
                                      child: Center(
                                        // Center the icon within the SizedBox
                                        child: FaIcon(platformIcon, color: textColor),
                                      ),
                                    ),
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
                                    isDense: true,
                                    alignLabelWithHint: true,
                                  ),
                                ),
                              ),
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 16.0, bottom: 16.0, right: 16.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              child: GradientButton(
                                onPressed: () {
                                  onSubmitSocialMedia();
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
                                      context.tr("saveChanges"),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
