import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/models/medical_records.dart';
import 'package:image_picker/image_picker.dart';

class FileUploadInput extends StatefulWidget {
  const FileUploadInput({
    super.key,
    required this.medicalRecord,
    required this.formType,
    required this.theme,
    required this.textColor,
    required this.name,
    required this.onUploadTap,
    required this.onDeleteTap,
    required this.controller,
    required this.documentXFile,
  });

  final TextEditingController controller;

  final MedicalRecords medicalRecord;
  final String formType;
  final ThemeData theme;
  final Color textColor;
  final String name;
  final VoidCallback onUploadTap;
  final VoidCallback onDeleteTap;
  final XFile? documentXFile;

  @override
  State<FileUploadInput> createState() => _FileUploadInputState();
}

class _FileUploadInputState extends State<FileUploadInput> {
  String? _fileNameFromInitialValue;

  @override
  void initState() {
    super.initState();

    final recordMap = widget.medicalRecord.toMap();
    final initialValue = recordMap[widget.name]?.toString();

    if (widget.formType == 'view' && initialValue != null && initialValue.isNotEmpty) {
      final uri = Uri.parse(initialValue);
      final path = uri.path;
      final segments = path.split('/');
      final filenameWithExtension = segments.isNotEmpty ? segments.last : null;

      _fileNameFromInitialValue = (filenameWithExtension != null && filenameWithExtension.contains('.'))
          ? filenameWithExtension.split('.').first
          : null; // fallback moved to build()
    }
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.formType == 'view';
    if (widget.controller.text.isEmpty) {
      // Schedule it after build is done
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.text.isEmpty) {
          widget.controller.text = _fileNameFromInitialValue ?? context.tr('documentLink');
        }
      });
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          FormBuilderTextField(
            name: context.tr(widget.name),
            controller: widget.controller,
            style: TextStyle(color: isView ? widget.theme.disabledColor : widget.textColor),
            enabled: false,
            decoration: InputDecoration(
              label: Text(context.tr(widget.name)),
              hintText: context.tr(widget.name),
              labelStyle: TextStyle(color: isView ? widget.theme.disabledColor : widget.textColor ),
              filled: true,
              fillColor: widget.theme.canvasColor.withAlpha((0.1 * 255).round()),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.theme.primaryColor, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isView ? widget.theme.disabledColor : widget.theme.primaryColor,
                  width: 1,
                ),
              ),
              isDense: true,
              alignLabelWithHint: true,
              suffixIcon: const SizedBox(width: 40),
            ),
          ),
          if (!isView)
            Positioned(
              right: 10,
              child: GestureDetector(
                onTap: widget.documentXFile == null ? widget.onUploadTap : widget.onDeleteTap,
                child: Icon(
                  widget.documentXFile == null ? Icons.upload_file : Icons.close,
                  color: widget.theme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
