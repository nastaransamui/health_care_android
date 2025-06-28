

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KeyWordWidget extends StatelessWidget {
  final TextEditingController keyWordController;
  final Map<String, dynamic> localQueryParams;
  const KeyWordWidget({
    super.key,
    required this.keyWordController,
    required this.localQueryParams,
  });

  @override
  Widget build(BuildContext context) {
    void onChange(value) {
      keyWordController.text = value;
      localQueryParams.remove('keyWord');
      Map<String, String> searchFilters = {
        ...localQueryParams,
        ...keyWordController.text.isNotEmpty
            ? {"keyWord": keyWordController.text}
            : {},
      };
      context.replace(
        Uri(
          path: '/doctors/search',
          queryParameters: searchFilters,
        ).toString(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: keyWordController,
        keyboardType: TextInputType.text,
        onChanged: (value) {
          onChange(value);
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          prefixIconColor: Theme.of(context).primaryColor,
          suffixIcon: keyWordController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    onChange('');
                  },
                  icon: const Icon(Icons.close)),
          suffixIconColor: Theme.of(context).primaryColor,
          contentPadding: const EdgeInsets.all(8),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          label: Text(context.tr('keyWord')),
          labelStyle: const TextStyle(
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
