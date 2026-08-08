class CategoryItemModel {
  const CategoryItemModel({required this.id, required this.name, required this.parent, required this.count, required this.image});

  final int id;
  final String name;
  final int parent;
  final int count;
  final String image;

  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemModel(id: json['id'], name: json['name'], parent: json['parent'], count: json['count'], image: json['image']);
  }
}
