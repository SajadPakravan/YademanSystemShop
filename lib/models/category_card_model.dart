class CategoryCardModel {
  CategoryCardModel({required this.id, required this.name, required this.count, required this.image, required this.children});

  final int id;
  final String name;
  final int count;
  final String image;
  final List<CategoryCardModel> children;

  factory CategoryCardModel.fromJson(Map<String, dynamic> json) {
    return CategoryCardModel(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      image: json['image'],
      children: List.castFrom(json['children']).map((item) => CategoryCardModel.fromJson(item)).toList(),
    );
  }
}
