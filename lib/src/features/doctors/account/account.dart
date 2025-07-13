import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/bank_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/bank_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class Account extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/account';
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final ScrollController doctorsAccountsScrollController = ScrollController();
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final BankService bankService = BankService();
  late final BankProvider bankProvider;
  final bankDataFormKey = GlobalKey<FormBuilderState>();
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool showBankName = false;
  double lifeTime = 10000;
  double duration = 200;
  String bankId = '';
  Future<void> getDataOnUpdate() async {
    final bankWithReservations = await bankService.getUserBankDataWithReservation(context);
    if (bankWithReservations == null) return;

    final bankData = bankWithReservations.bankData.toMap();
    final filtered = Map<String, dynamic>.from(bankData);

    // Format and clean individual fields
    final formattedMap = <String, dynamic>{};
    final bangkok = tz.getLocation(dotenv.env['TZ']!);

    for (final entry in filtered.entries) {
      final key = entry.key;
      final value = entry.value;

      dynamic formattedValue;
      if (value is DateTime) {
        formattedValue = DateFormat('yyyy MMM dd, HH:mm').format(tz.TZDateTime.from(value, bangkok));
      } else {
        if (key == 'id') {
          setState(() {
            bankId = value.toString();
          });
        }
        formattedValue = value?.toString();
      }

      if (formattedValue != null && formattedValue.toString().trim().isNotEmpty) {
        formattedMap[key] = formattedValue;
      }
    }

    // Only patch if there's something to patch
    if (formattedMap.isEmpty) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (bankDataFormKey.currentState?.mounted ?? false) {
        bankDataFormKey.currentState?.patchValue(formattedMap);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void dispose() {
    doctorsAccountsScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      bankProvider = Provider.of<BankProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  Future<void> onSubmitEditBank() async {
    final isValid = bankDataFormKey.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      // Errors will automatically be shown next to each field including RadioGroup
      return;
    }

    final formData = bankDataFormKey.currentState!.value;

    if (bankDataFormKey.currentState!.validate()) {
      var payload = {
        if (bankId.isNotEmpty) "_id": bankId,
        "userId": authProvider.doctorsProfile!.userId,
        "bankName": formData['bankName'],
        "branchName": formData['branchName'],
        "accountNumber": formData['accountNumber'],
        "accountName": formData['accountName'],
        "swiftCode": formData['swiftCode'] ?? '',
        "BICcode": formData['bICcode'] ?? '',
      };
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      );
      socket.emit('bankUpdate', payload);
      socket.once('bankUpdateReturn', (data) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
          FocusScope.of(context).unfocus();

          if (data['status'] != 200) {
            showErrorSnackBar(
              context,
              data['reason'] ?? data['message'] ?? 'Something went wrong.',
            );
          } else {
            final bankData = data['bankData'];
            final filtered = Map<String, dynamic>.from(bankData);

            final bangkok = tz.getLocation(dotenv.env['TZ']!);
            final formattedMap = <String, dynamic>{};

            filtered.forEach((key, value) {
              if (key == '_id') {
                setState(() {
                  bankId = value.toString();
                });
              }

              if ((key == 'createdAt' || key == 'updateAt') && value is String) {
                try {
                  final dt = DateTime.parse(value);
                  formattedMap[key] = DateFormat('yyyy MMM dd, HH:mm').format(tz.TZDateTime.from(dt, bangkok));
                } catch (e) {
                  formattedMap[key] = value; // fallback if parse fails
                }
              } else {
                formattedMap[key] = value?.toString();
              }
            });

            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (bankDataFormKey.currentState?.mounted ?? false) {
                bankDataFormKey.currentState?.patchValue(formattedMap);
              }
            });

            showErrorSnackBar(context, 'Bank data updated successfully');
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BankProvider>(
      builder: (context, bankProvider, _) {
        final bankWithReservations = bankProvider.bankWithReservations;
        final DoctorUserProfile doctorUserProfile = authProvider.doctorsProfile!.userProfile;
        final String currencySymbol = doctorUserProfile.currency.isNotEmpty ? doctorUserProfile.currency.first.currency : '';
        final ThemeData theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

        return ScaffoldWrapper(
          title: context.tr('accounts'),
          children: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double per = 0;
                  if (doctorsAccountsScrollController.hasClients) {
                    per = ((doctorsAccountsScrollController.offset / doctorsAccountsScrollController.position.maxScrollExtent));
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
                  controller: doctorsAccountsScrollController,
                  child: Column(
                    children: [
                      // bank information
                      FadeinWidget(
                        isCenter: true,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                FormBuilder(
                                  key: bankDataFormKey,
                                  child: Card(
                                    elevation: 12,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: theme.primaryColor),
                                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  context.tr('bankAccount'),
                                                  style: TextStyle(
                                                    color: theme.primaryColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      context.tr('weEncrypt'),
                                                      style: TextStyle(
                                                        color: theme.primaryColorLight,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          showBankName = !showBankName;
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Icon(
                                                          !showBankName ? Icons.visibility_off : Icons.visibility,
                                                          color: Theme.of(context).primaryColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Divider(height: 1, color: theme.primaryColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ...bankWithReservations.bankData.toMap().entries.map((entry) {
                                            final key = entry.key;
                                            if (key != 'id' && key != 'userId') {
                                              final isDisabled = key == 'createdAt' || key == 'updateAt';
                                              final isOptional = key == 'swiftCode' || key == 'bICcode' || key == 'createdAt' || key == 'updateAt';

                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                                child: Semantics(
                                                  label: context.tr(key),
                                                  child: FormBuilderTextField(
                                                    name: key,
                                                    enabled: !isDisabled,
                                                    obscureText: isDisabled ? false : !showBankName,
                                                    keyboardType: key == 'accountNumber' ? TextInputType.number : TextInputType.name,
                                                    inputFormatters: entry.key == 'accountNumber' ? [FilteringTextInputFormatter.digitsOnly] : null,
                                                    enableSuggestions: true,
                                                    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    validator: (fieldValue) {
                                                      if (!isOptional && (fieldValue == null || fieldValue.isEmpty)) {
                                                        return context.tr('required');
                                                      }
                                                      return null;
                                                    },
                                                    decoration: InputDecoration(
                                                      errorStyle: TextStyle(color: Colors.redAccent.shade400),
                                                      floatingLabelStyle:
                                                          TextStyle(color: isDisabled ? theme.disabledColor : theme.primaryColorLight),
                                                      labelStyle: TextStyle(color: isDisabled ? theme.disabledColor : theme.primaryColorLight),
                                                      // labelText: context.tr(key),
                                                      label: RichText(
                                                        text: TextSpan(
                                                          text: context.tr(key),
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(color: isDisabled ? theme.disabledColor : textColor),
                                                          children: [
                                                            if (!isOptional) // show * if required
                                                              const TextSpan(
                                                                text: ' *',
                                                                style: TextStyle(color: Colors.red),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      hintText: context.tr(key),
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
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          }),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              height: 35,
                                              child: GradientButton(
                                                onPressed: () {
                                                  onSubmitEditBank();
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
                                                      context.tr("submit"),
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
                            )),
                      ),
                      // Reservation information
                      FadeinWidget(
                        isCenter: true,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                elevation: 12,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: theme.primaryColor),
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: bankWithReservations.reservationsAndTotals.map((entry) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr(
                                              "totalReservations",
                                              args: ["${bankWithReservations.reservationsAndTotals.first.totalReservations}"],
                                            ),
                                            style: TextStyle(color: theme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Divider(height: 1, color: theme.primaryColor),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              children: [
                                                const Expanded(child: Divider()),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    context.tr('awaitingRequest', args: ['${entry.awaitingRequest?.totalBookings}']),
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                ),
                                                const Expanded(child: Divider()),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...entry.awaitingRequest!.toMap().entries.map(
                                            (entry) {
                                              if (entry.key != 'totalBookings') {
                                                final key = entry.key;
                                                final value = entry.value;
                                                final Color bgColor = key == 'totalAmount'
                                                    ? const Color.fromRGBO(15, 183, 107, 0.12)
                                                    : key == 'totalPrice'
                                                        ? const Color.fromRGBO(255, 152, 0, 0.12)
                                                        : const Color.fromRGBO(197, 128, 255, 0.12);

                                                final Color color = key == 'totalAmount'
                                                    ? hexToColor('#26af48')
                                                    : key == 'totalPrice'
                                                        ? hexToColor('#f39c12')
                                                        : hexToColor('#c580ff');
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                        child: Container(
                                                          margin: const EdgeInsets.only(bottom: 5),
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: bgColor,
                                                          ),
                                                          child: Center(
                                                              child: Column(
                                                            children: [
                                                              Text(
                                                                '$currencySymbol ${NumberFormat("#,##0.00", "en_US").format(value)}',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              Text(
                                                                context.tr("account_$key"),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              children: [
                                                const Expanded(child: Divider()),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    context.tr('pendingRequest', args: ['${entry.pending?.totalBookings}']),
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                ),
                                                const Expanded(child: Divider()),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...entry.pending!.toMap().entries.map(
                                            (entry) {
                                              if (entry.key != 'totalBookings') {
                                                final key = entry.key;
                                                final value = entry.value;
                                                final Color bgColor = key == 'totalAmount'
                                                    ? const Color.fromRGBO(15, 183, 107, 0.12)
                                                    : key == 'totalPrice'
                                                        ? const Color.fromRGBO(255, 152, 0, 0.12)
                                                        : const Color.fromRGBO(197, 128, 255, 0.12);

                                                final Color color = key == 'totalAmount'
                                                    ? hexToColor('#26af48')
                                                    : key == 'totalPrice'
                                                        ? hexToColor('#f39c12')
                                                        : hexToColor('#c580ff');
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                        child: Container(
                                                          margin: const EdgeInsets.only(bottom: 5),
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: bgColor,
                                                          ),
                                                          child: Center(
                                                              child: Column(
                                                            children: [
                                                              Text(
                                                                '$currencySymbol ${NumberFormat("#,##0.00", "en_US").format(value)}',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              Text(
                                                                context.tr("account_$key"),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              children: [
                                                const Expanded(child: Divider()),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    context.tr('paidRequest', args: ['${entry.paid?.totalBookings}']),
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                ),
                                                const Expanded(child: Divider()),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...entry.paid!.toMap().entries.map(
                                            (entry) {
                                              if (entry.key != 'totalBookings') {
                                                final key = entry.key;
                                                final value = entry.value;
                                                final Color bgColor = key == 'totalAmount'
                                                    ? const Color.fromRGBO(15, 183, 107, 0.12)
                                                    : key == 'totalPrice'
                                                        ? const Color.fromRGBO(255, 152, 0, 0.12)
                                                        : const Color.fromRGBO(197, 128, 255, 0.12);

                                                final Color color = key == 'totalAmount'
                                                    ? hexToColor('#26af48')
                                                    : key == 'totalPrice'
                                                        ? hexToColor('#f39c12')
                                                        : hexToColor('#c580ff');
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                        child: Container(
                                                          margin: const EdgeInsets.only(bottom: 5),
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: bgColor,
                                                          ),
                                                          child: Center(
                                                              child: Column(
                                                            children: [
                                                              Text(
                                                                '$currencySymbol ${NumberFormat("#,##0.00", "en_US").format(value)}',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              Text(
                                                                context.tr("account_$key"),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Billing informations
                      FadeinWidget(
                        isCenter: true,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                elevation: 12,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: theme.primaryColor),
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: bankWithReservations.billingsAndTotals.map((entry) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr(
                                              "totalBillingsAccount",
                                              args: ["${bankWithReservations.billingsAndTotals.first.totalBillings}"],
                                            ),
                                            style: TextStyle(color: theme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Divider(height: 1, color: theme.primaryColor),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              children: [
                                                const Expanded(child: Divider()),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    context.tr('pendingRequest', args: ['${entry.pending?.totalBillings}']),
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                ),
                                                const Expanded(child: Divider()),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...entry.pending!.toMap().entries.map(
                                            (entry) {
                                              if (entry.key != 'totalBillings') {
                                                final key = entry.key;
                                                final value = entry.value;
                                                final Color bgColor = key == 'totalAmount'
                                                    ? const Color.fromRGBO(15, 183, 107, 0.12)
                                                    : key == 'totalPrice'
                                                        ? const Color.fromRGBO(255, 152, 0, 0.12)
                                                        : const Color.fromRGBO(197, 128, 255, 0.12);

                                                final Color color = key == 'totalAmount'
                                                    ? hexToColor('#26af48')
                                                    : key == 'totalPrice'
                                                        ? hexToColor('#f39c12')
                                                        : hexToColor('#c580ff');
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                        child: Container(
                                                          margin: const EdgeInsets.only(bottom: 5),
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: bgColor,
                                                          ),
                                                          child: Center(
                                                              child: Column(
                                                            children: [
                                                              Text(
                                                                '$currencySymbol ${NumberFormat("#,##0.00", "en_US").format(value)}',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              Text(
                                                                context.tr("account_$key"),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              children: [
                                                const Expanded(child: Divider()),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    context.tr('paidRequest', args: ['${entry.paid?.totalBillings}']),
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                ),
                                                const Expanded(child: Divider()),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...entry.paid!.toMap().entries.map(
                                            (entry) {
                                              if (entry.key != 'totalBillings') {
                                                final key = entry.key;
                                                final value = entry.value;
                                                final Color bgColor = key == 'totalAmount'
                                                    ? const Color.fromRGBO(15, 183, 107, 0.12)
                                                    : key == 'totalPrice'
                                                        ? const Color.fromRGBO(255, 152, 0, 0.12)
                                                        : const Color.fromRGBO(197, 128, 255, 0.12);

                                                final Color color = key == 'totalAmount'
                                                    ? hexToColor('#26af48')
                                                    : key == 'totalPrice'
                                                        ? hexToColor('#f39c12')
                                                        : hexToColor('#c580ff');
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                        child: Container(
                                                          margin: const EdgeInsets.only(bottom: 5),
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: bgColor,
                                                          ),
                                                          child: Center(
                                                              child: Column(
                                                            children: [
                                                              Text(
                                                                '$currencySymbol ${NumberFormat("#,##0.00", "en_US").format(value)}',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              Text(
                                                                context.tr("account_$key"),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: color,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ScrollButton(scrollController: doctorsAccountsScrollController, scrollPercentage: scrollPercentage),
            ],
          ),
        );
      },
    );
  }
}
