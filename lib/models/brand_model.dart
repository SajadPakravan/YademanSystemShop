class BrandModel {
  const BrandModel({required this.id, required this.name, required this.count, required this.image});

  final int id;
  final String name;
  final int count;
  final String image;

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(id: json['id'], name: json['name'], count: json['count'], image: json['image']);
  }
}
