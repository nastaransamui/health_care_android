import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class FilterableGridColumn {
  final GridColumn column;
  final String dataType; // 'string', 'number', 'date', etc.

  FilterableGridColumn({required this.column, required this.dataType});
}

class SfDataGridFilterWidget extends StatefulWidget {
  final List<FilterableGridColumn> columns;
  final String columnName;
  const SfDataGridFilterWidget({
    super.key,
    required this.columns,
    required this.columnName,
  });

  @override
  State<SfDataGridFilterWidget> createState() => _SfDataGridFilterWidgetState();
}

class _SfDataGridFilterWidgetState extends State<SfDataGridFilterWidget> {
  String? selectedColumnName;
  String? selectedOperator;
  String? inputValue;
  String? inputValue2;

  FilterableGridColumn? get selectedColumn => widget.columns.firstWhereOrNull(
        (col) => col.column.columnName == selectedColumnName,
      );

  @override
  void initState() {
    super.initState();
    selectedColumnName = widget.columnName;
  }

  List<Map<String, String>> getOperatorsForType(String? type) {
    switch (type) {
      case 'number':
        return [
          {"label": context.tr('greaterThan'), "value": ">"},
          {"label": context.tr('lessThan'), "value": "<"},
          {"label": context.tr('equal'), "value": "="},
          {"label": context.tr('between'), "value": "between"},
        ];
      case 'string':
        return [
          {"label": context.tr('contains'), "value": "contains"},
          {"label": context.tr('equal'), "value": "equals"},
        ];
      case 'date':
        return [
          {"label": context.tr('before'), "value": "before"},
          {"label": context.tr('after'), "value": "after"},
          {"label": context.tr('on'), "value": "on"},
        ];
      case 'boolean':
        return [
          {"label": context.tr('is'), "value": "is"},
        ];
      default:
        return [];
    }
  }

  final Map<String, String> mongoDBOperators = {
    'contains': r'$regex',
    'equals': r'$eq',
    '>': r'$gt',
    '<': r'$lt',
    '=': r'$eq',
    'before': r'$lt',
    'after': r'$gt',
    'on': r'$eq',
    'between': r'$between',
    'is': r'$eq',
  };
  Map<String, dynamic> convertFilterToMongoDB(
    Map<String, dynamic> filterModel,
    List<FilterableGridColumn> columns,
    String timezone,
  ) {
    final List<dynamic> items = filterModel['items'] ?? [];
    Map<String, dynamic> query = {};

    for (final filter in items) {
      final String? field = filter['field'] as String?;
      final String? operator = filter['operator'] as String?;
      final dynamic value = filter['value'];

      if (field == null || operator == null || value == null) continue;
      final operatorSymbol = mongoDBOperators[operator];
      if (operatorSymbol == null || value == null) continue;

      FilterableGridColumn? column;
      try {
        column = columns.firstWhere((col) => col.column.columnName == field);
      } catch (e) {
        column = null;
      }
      if (column == null) continue;

      final String type = column.dataType;
      dynamic parsedValue = value;
      switch (type) {
        case 'number':
          if (operator == 'between' && value is List && value.length == 2) {
            final min = num.tryParse(value[0].toString());
            final max = num.tryParse(value[1].toString());
            if (min != null && max != null) {
              parsedValue = {r'$gte': min, r'$lte': max};
              query[field] = parsedValue;
            }
          } else {
            final numVal = num.tryParse(value.toString());
            if (numVal != null) {
              parsedValue = numVal;
              query[field] = {operatorSymbol: parsedValue};
            }
          }
          break;

        case 'date':
        case 'dateTime':
          try {
            final format = DateFormat('dd/MM/yyyy'); // matches your input
            final parsedDate = format.parse(value.toString());
            parsedValue = parsedDate;
          } catch (e) {
            continue;
          }
          break;

        case 'boolean':
          if (parsedValue is bool) {
            query[field] = {operatorSymbol: parsedValue};
          }
          break;
      }
      if (operator == 'contains' && parsedValue is String) {
        query[field] = {
          operatorSymbol: parsedValue,
          r'$options': 'i',
        };
      } else if (operator == 'between' && parsedValue is Map) {
        query[field] = parsedValue;
      } else if (['before', 'after', 'on'].contains(operator)) {
        try {
          final inputDate = DateFormat('dd/MM/yyyy').parseStrict(value.toString());

          final localDate = inputDate.toLocal().copyWith(
                hour: 0,
                minute: 0,
                second: 0,
                millisecond: 0,
              );

          final utcDate = localDate.toUtc().toIso8601String();
          query = {
            r'$expr': {
              operatorSymbol: [
                {
                  r'$cond': {
                    'if': {
                      r'$ne': [
                        {r'$type': '\$$field'},
                        'string',
                      ],
                    },
                    'then': {
                      r'$dateToString': {
                        'format': '%Y-%m-%d',
                        'date': '\$$field',
                      },
                    },
                    'else': null,
                  },
                },
                {
                  r'$dateToString': {
                    'format': '%Y-%m-%d',
                    'date': {
                      r'$dateFromString': {
                        'dateString': type == 'dateTime' ? utcDate : localDate.toIso8601String(),
                      },
                    },
                  },
                },
              ],
            },
          };
        } catch (e) {
          continue;
        }
      } else {
        if (type != 'boolean' || parsedValue is! String) {
          query[field] = {operatorSymbol: parsedValue};
        }
      }

      // Workaround for DataGrid bug
      if (type == 'boolean' && parsedValue is String) {
        return {
          field: {r'$eq': false}
        };
      }
    }

    return query;
  }

  bool? _selectedValue = true;
  @override
  Widget build(BuildContext context) {
    final selectedDataType = selectedColumn?.dataType;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("selectColumn")),
        automaticallyImplyLeading: false, // Removes the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedColumnName,
              decoration: InputDecoration(
                labelText: context.tr("selectColumForFilter"),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              isExpanded: true,
              items: widget.columns.map((col) {
                return DropdownMenuItem<String>(
                  value: col.column.columnName,
                  child: Container(
                    alignment: Alignment.centerLeft, // force left
                    width: double.infinity, // make sure it uses full width
                    child: Builder(
                      builder: (context) {
                        final label = col.column.label;
                        // Try to extract the text directly if it's a known structure
                        if (label is Container && label.child is Text) {
                          return Text(
                            (label.child as Text).data ?? '',
                            style: (label.child as Text).style,
                            textAlign: TextAlign.left,
                          );
                        }
                        return label; // fallback
                      },
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedColumnName = value;
                  selectedOperator = null;
                  inputValue = null;
                  inputValue2 = null;
                });
              },
            ),
            if (selectedDataType != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedOperator,
                  decoration: InputDecoration(
                    labelText: context.tr("selectOperator"),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  items: getOperatorsForType(selectedDataType).map((op) {
                    return DropdownMenuItem<String>(
                      value: op["value"],
                      child: Text(op["label"]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOperator = value;
                      inputValue = null;
                      inputValue2 = null;
                    });
                  },
                ),
              ),
            if (selectedOperator != null)
              if (selectedOperator == 'between')
                Row(
                  children: [
                    Expanded(child: buildInputField(isSecond: false)),
                    const SizedBox(width: 12),
                    Expanded(child: buildInputField(isSecond: true)),
                  ],
                )
              else if (selectedOperator == 'is')
                DropdownButtonFormField<bool>(
                  value: _selectedValue,
                  decoration: InputDecoration(
                    labelText: context.tr("selectValue"),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _selectedValue = newValue;
                    });
                  },
                  items: <DropdownMenuItem<bool>>[
                    DropdownMenuItem<bool>(
                      value: true,
                      child: Text(context.tr('${selectedColumnName}_filterTrue')),
                    ),
                    DropdownMenuItem<bool>(
                      value: false,
                      child: Text(context.tr('${selectedColumnName}_filterFalse')),
                    ),
                  ],
                )
              else
                buildInputField(isSecond: false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final filterModel = {
                  'items': [
                    {
                      'field': selectedColumnName,
                      'operator': selectedOperator,
                      'value': selectedOperator == 'between'
                          ? [inputValue, inputValue2]
                          : selectedOperator == 'is'
                              ? _selectedValue
                              : inputValue,
                    }
                  ]
                };
                
                final mongoQuery = convertFilterToMongoDB(
                    filterModel,
                    widget.columns, // your List<Map<String, dynamic>> column definitions
                    'Asia/Bangkok' // or your custom timezone string
                    );

                Navigator.pop(context, mongoQuery);
              },
              child: Text(context.tr("applyFilter")),
            )
          ],
        ),
      ),
    );
  }

  TextEditingController inputController = TextEditingController();
  TextEditingController inputController2 = TextEditingController();

  Widget buildInputField({required bool isSecond}) {
    final dataType = selectedColumn?.dataType;
    final controller = isSecond ? inputController2 : inputController;

    // Set initial value to controller if needed
    final currentVal = isSecond ? inputValue2 : inputValue;
    if (controller.text != currentVal) controller.text = currentVal ?? '';

    void updateValue(String? val) {
      setState(() {
        if (isSecond) {
          inputValue2 = val;
        } else {
          inputValue = val;
        }
      });
    }

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        final formatted = "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
        controller.text = formatted;
        updateValue(formatted);
      }
    }

    final decoration = InputDecoration(
      labelText: isSecond ? context.tr("valueTo") : context.tr("valueFrom"),
      suffixIcon: (dataType == 'date' || dataType == 'datetime') ? const Icon(Icons.calendar_today) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );

    if (dataType == 'date' || dataType == 'datetime') {
      return GestureDetector(
        onTap: pickDate,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: decoration,
            readOnly: true,
          ),
        ),
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: dataType == 'number' ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: dataType == 'number' ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))] : [],
      decoration: decoration,
      onChanged: (val) => updateValue(val),
    );
  }
}

bool isColumnFiltered(String columnName, Map<String, dynamic> mongoFilter) {
  bool checkValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      for (var entry in value.entries) {
        if (entry.key == '\$$columnName' || checkValue(entry.value)) {
          return true;
        }
      }
    } else if (value is List) {
      for (var item in value) {
        if (checkValue(item)) return true;
      }
    } else if (value is String && value == '\$$columnName') {
      return true;
    }
    return false;
  }

  for (var entry in mongoFilter.entries) {
    if (entry.key == columnName) return true; // direct match
    if (checkValue(entry.value)) return true; // deep match
  }

  return false;
}

GridColumn buildColumn(String label, String name, Color color, {double width = 200}) {
  return GridColumn(
    columnName: name,
    allowSorting: true,
    allowFiltering: true,
    columnWidthMode: ColumnWidthMode.none, // Must use `none` to allow fixed width
    width: width,
    autoFitPadding: const EdgeInsets.all(8),
    label: Container(
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: color),
      ),
    ),
  );
}
