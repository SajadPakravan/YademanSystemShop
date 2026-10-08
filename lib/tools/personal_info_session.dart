import 'package:yad_sys/models/customer_model.dart';

/// نگهداری مشخصات فردی فقط در حافظه اجرای فعلی اپلیکیشن؛ فاقد ذخیره روی دیسک.
class PersonalInfoSession {
  PersonalInfoSession._();

  /// کلید شناسه مشتری مانع استفاده از اطلاعات حساب دیگر می‌شود.
  static final Map<int, CustomerModel> _customers = <int, CustomerModel>{};

  /// دریافت اطلاعات بارگذاری‌شده هنگام اولین بازدید از فرم.
  static CustomerModel? get(int customerId) => _customers[customerId];

  /// ثبت نتیجه GET یا PUT مشخصات برای بازدیدهای بعدی در همین نشست.
  static void save(CustomerModel customer) => _customers[customer.id] = customer;

  /// پاکسازی اطلاعات خصوصی در خروج یا تغییر حساب.
  static void clear() => _customers.clear();
}
