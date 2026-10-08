class PaginationModel {
  const PaginationModel({this.currentPage = 1, this.perPage = 20, this.totalItems = 0, this.totalPages = 1, this.total = 0, this.hasNext = false, this.hasPrevious = false});
  final int currentPage, perPage, totalItems, totalPages, total;
  final bool hasNext, hasPrevious;

  factory PaginationModel.fromJson(dynamic value, {String totalKey = 'total_items', int fallbackCount = 0}) {
    final map = value is Map ? value : const {};
    int number(String key, int fallback) => int.tryParse(map[key]?.toString() ?? '') ?? fallback;
    final page = number('current_page', 1);
    final pages = number('total_pages', 1);
    return PaginationModel(currentPage: page, perPage: number('per_page', 20), totalItems: number('total_items', fallbackCount), totalPages: pages, total: number(totalKey, number('total_items', fallbackCount)), hasNext: map['has_next'] is bool ? map['has_next'] : page < pages, hasPrevious: map['has_previous'] is bool ? map['has_previous'] : page > 1);
  }
}
