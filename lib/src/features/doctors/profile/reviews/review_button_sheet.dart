import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/gradient_button.dart';

class ReviewButtonSheet extends StatefulWidget {
  final DoctorUserProfile doctorUserProfile;
  const ReviewButtonSheet({
    super.key,
    required this.doctorUserProfile,
  });

  @override
  State<ReviewButtonSheet> createState() => _ReviewButtonSheetState();
}

class _ReviewButtonSheetState extends State<ReviewButtonSheet> {
  final ScrollController scrollController = ScrollController();
  final reviewFormKey = GlobalKey<FormBuilderState>();

  Future<void> onReviewSubmit() async {
    final isValid = reviewFormKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) {
      return;
    }

    final formData = reviewFormKey.currentState!.value;

    if (reviewFormKey.currentState!.validate()) {
      Navigator.pop(context, formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DoctorUserProfile doctorUserProfile = widget.doctorUserProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final String profileImage = doctorUserProfile.profileImage;

    final String name = "Dr. ${doctorUserProfile.fullName}";
    final ImageProvider<Object> avatarImage =
        profileImage.isEmpty ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider : CachedNetworkImageProvider(profileImage);
    final Color statusColor = doctorUserProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorUserProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("addReview", args: [name])),
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
              ReviewProfileWidget(avatarImage: avatarImage, statusColor: statusColor, theme: theme, name: name),
              const SizedBox(height: 8),
              Divider(height: 1, color: theme.primaryColor),
              FormBuilder(
                key: reviewFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    const RatingWidget(),
                    RecommendedWidget(theme: theme, textColor: textColor),
                    // Title
                    TitleWidget(theme: theme, textColor: textColor),
                    BodyWidget(theme: theme, textColor: textColor),
                    const TermsWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                        child: GradientButton(
                          onPressed: () {
                            onReviewSubmit();
                          },
                          colors: [
                            theme.primaryColorLight,
                            theme.primaryColor,
                          ],
                          child: Text(
                            context.tr("addReview", args: [name]),
                            style: TextStyle(fontSize: 12, color: textColor),
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

class TermsWidget extends StatelessWidget {
  const TermsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: FormBuilderField<bool>(
        name: 'terms',
        initialValue: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: FormBuilderValidators.equal(
          true,
          errorText: context.tr('termsError'),
        ),
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: field.value ?? false,
                    onChanged: (val) {
                      field.didChange(val);
                    },
                    visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Transform.translate(
                    offset: const Offset(0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.tr('readAndAccept')),
                        GestureDetector(
                          onTap: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (_) => const TermsDialog(),
                            );
                            field.didChange(result == true);
                          },
                          child: Text(
                            context.tr('termsAndConditions'),
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 4), // align with checkbox title
                  child: Text(
                    field.errorText!,
                    style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {
  const BodyWidget({
    super.key,
    required this.theme,
    required this.textColor,
  });

  final ThemeData theme;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: FormBuilderField<String>(
        name: 'body',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (fieldValue) {
          if (fieldValue == null || fieldValue.isEmpty) {
            return context.tr('required');
          }
          return null;
        },
        builder: (field) {
          final controller = TextEditingController(text: field.value);
    
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                enableSuggestions: true,
                onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                maxLines: 5,
                controller: controller,
                onChanged: (val) => field.didChange(val),
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    color: Colors.redAccent.shade400,
                  ),
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
                  isDense: true,
                  alignLabelWithHint: true,
                ),
              ),
              if (field.hasError)
                Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.theme,
    required this.textColor,
  });

  final ThemeData theme;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: FormBuilderField<String>(
        name: 'title',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (fieldValue) {
          if (fieldValue == null || fieldValue.isEmpty) {
            return context.tr('required');
          }
          return null;
        },
        builder: (field) {
          final controller = TextEditingController(text: field.value);
    
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                enableSuggestions: true,
                onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                controller: controller,
                onChanged: (val) => field.didChange(val),
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
              if (field.hasError)
                Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                ),
            ],
          );
        },
      ),
    );
  }
}

class RecommendedWidget extends StatelessWidget {
  const RecommendedWidget({
    super.key,
    required this.theme,
    required this.textColor,
  });

  final ThemeData theme;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<bool>(
      name: 'recommend',
      validator: (value) {
        if (value == null) {
          return context.tr('required'); // Or use a custom string
        }
        return null;
      },
      builder: (field) {
        final value = field.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${context.tr('recommend')} :'),
            const SizedBox(height: 8),
            Row(
              children: [
                // YES Button
                GestureDetector(
                  onTap: () {
                    field.didChange(true);
                    field.validate(); // Trigger validation
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: value == true ? Colors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: BoxBorder.all(color: theme.primaryColorLight),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up_alt_outlined, size: 14, color: value == true ? textColor : theme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('yes'),
                          style: TextStyle(color: value == true ? textColor : theme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
    
                // NO Button
                GestureDetector(
                  onTap: () {
                    field.didChange(false);
                    field.validate();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: value == false ? Colors.redAccent.shade400 : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: BoxBorder.all(color: theme.primaryColorLight),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.thumb_down_alt_outlined, size: 14, color: value == false ? textColor : theme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('no'),
                          style: TextStyle(color: value == false ? textColor : theme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: FormBuilderField<double>(
        name: 'rating',
        initialValue: 0.0,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.min(0.5, errorText: context.tr('required')),
        ]),
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("${context.tr('rating')}: "),
                  RatingBar.builder(
                    initialRating: field.value ?? 0.0,
                    minRating: 0.5,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      field.didChange(rating);
                      field.validate();
                    },
                  ),
                ],
              ),
              if (field.hasError)
                Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ReviewProfileWidget extends StatelessWidget {
  const ReviewProfileWidget({
    super.key,
    required this.avatarImage,
    required this.statusColor,
    required this.theme,
    required this.name,
  });

  final ImageProvider<Object> avatarImage;
  final Color statusColor;
  final ThemeData theme;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: avatarImage,
              ),
              Positioned(
                right: 2,
                top: 2,
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
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: theme.primaryColorLight,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terms & Conditions'),
      content: const SizedBox(
        height: 400,
        width: 300,
        child: SingleChildScrollView(
          child: Terms(), // This uses your <Terms /> content from earlier
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

class Terms extends StatelessWidget {
  const Terms({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Terms and contisoido');
  }
}
