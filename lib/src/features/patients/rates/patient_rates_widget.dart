
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/rate_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/rate_service.dart';
import 'package:health_care/shared/rating_progress.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/utils/calculate_average_rating.dart';
import 'package:health_care/src/utils/get_star_rating_proportion.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class PatientRatesWidget extends StatefulWidget {
  static const String routeName = '/patient/dashboard/rates';
  const PatientRatesWidget({super.key});

  @override
  State<PatientRatesWidget> createState() => _PatientRatesWidgetState();
}

class _PatientRatesWidgetState extends State<PatientRatesWidget> {
  final RateService rateService = RateService();
  late final RateProvider rateProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  bool _isProvidersInitialized = false;
  Future<void> getDataOnUpdate() async {
    rateService.getAuthorRates(context);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      rateProvider = Provider.of<RateProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('updateGetAuthorRates');
    socket.off('getAuthorRatesReturn');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RateProvider>(
      builder: (context, rateProvider, child) {
        final List<double> ratesArray = rateProvider.ratesArray;
        bool isLoading = rateProvider.isLoading;
        final int totalRates = rateProvider.total;
        final ThemeData theme = Theme.of(context);
        final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        // final PatientsProfile? patientsProfile = authProvider.patientProfile;
        double averageRating = calculateAverageRating(ratesArray);
        // Calculate proportions for each star rating
        final double fiveStarProportion = getStarRatingProportion(ratesArray, 5.0);
        final double fourStarProportion = getStarRatingProportion(ratesArray, 4.0);
        final double threeStarProportion = getStarRatingProportion(ratesArray, 3.0);
        final double twoStarProportion = getStarRatingProportion(ratesArray, 2.0);
        final double oneStarProportion = getStarRatingProportion(ratesArray, 1.0);

        return ScaffoldWrapper(
          title: context.tr('rates'),
          children: SingleChildScrollView(
            child: Column(
              children: [
                FadeinWidget(
                  isCenter: true,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                            'totalRates',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ).plural(
                            totalRates,
                            format: NumberFormat.compact(
                              locale: context.locale.toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (ratesArray.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  FadeinWidget(
                    isCenter: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: theme.primaryColorLight),
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '$averageRating',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 9,
                                      child: Column(
                                        children: [
                                          RatingProgress(theme: theme, star: 5, value: fiveStarProportion),
                                          RatingProgress(theme: theme, star: 4, value: fourStarProportion),
                                          RatingProgress(theme: theme, star: 3, value: threeStarProportion),
                                          RatingProgress(theme: theme, star: 2, value: twoStarProportion),
                                          RatingProgress(theme: theme, star: 1, value: oneStarProportion),
                                        ],
                                      )),
                                ],
                              ),
                              const SizedBox(height: 10),
                              StarReviewWidget(
                                rate: averageRating,
                                textColor: textColor,
                                starSize: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  NumberFormat("#,##0", "en_US").format(ratesArray.length),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (isLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
