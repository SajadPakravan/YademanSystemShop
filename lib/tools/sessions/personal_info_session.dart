
import 'package:yad_sys/models/customer_model.dart';

class PersonalInfoSession {
  PersonalInfoSession._();

  static CustomerModel? _customer;

  static CustomerModel? get() => _customer;

  static void save(CustomerModel customer) => _customer = customer;

  static void clear() => _customer = null;
}
