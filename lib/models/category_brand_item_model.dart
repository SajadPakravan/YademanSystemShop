
class CategoryBrandItemModel {
  const CategoryBrandItemModel({required this.id, required this.name, required this.parent, required this.count, required this.image});

  final int id;
  final String name;
  final int parent;
  final int count;
  final String image;

  factory CategoryBrandItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryBrandItemModel(
      id: json['id'],
      name: json['name'],
      parent: json['parent'],
      count: json['count'],
      image: json['image'],
    );
  }
}
