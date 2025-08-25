import 'package:health_care/models/clinics.dart';

List<Clinics> skipNullsClinics<T>(List<Clinics> items) {
  return items..removeWhere((item) => !item.active);
}
