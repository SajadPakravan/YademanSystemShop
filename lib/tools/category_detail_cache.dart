import 'package:yad_sys/models/category/category_detail_model.dart';

/// کش حافظه‌ای جزئیات دسته‌بندی.
/// تا زمانی که اپلیکیشن بسته نشده، جزئیات دسته‌ای که یک بار دریافت شده
/// دوباره از سرور درخواست نمی‌شود؛ مگر اینکه forceRefresh صراحتاً استفاده شود.
class CategoryDetailCache {
  CategoryDetailCache._();

  static final CategoryDetailCache instance = CategoryDetailCache._();

  final Map<int, CategoryDetailModel> _items = <int, CategoryDetailModel>{};

  CategoryDetailModel? get(int categoryId) => _items[categoryId];

  void save(CategoryDetailModel category) {
    _items[category.data.id] = category;
  }

  void remove(int categoryId) {
    _items.remove(categoryId);
  }

  void clear() {
    _items.clear();
  }
}
