class PostModel {
  const PostModel({required this.id, required this.title, required this.excerpt, required this.image, required this.date, required this.categories});

  final int id;
  final String title;
  final String excerpt;
  final String image;
  final String date;
  final List<PostCategoryModel> categories;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      excerpt: json['excerpt'],
      image: json['image'],
      date: json['date'],
      categories: List.castFrom(json['categories']).map((item) => PostCategoryModel.fromJson(item)).toList(),
    );
  }
}

class PostCategoryModel {
  const PostCategoryModel({required this.id, required this.name});

  final int id;
  final String name;

  factory PostCategoryModel.fromJson(Map<String, dynamic> json) {
    return PostCategoryModel(id: json['id'], name: json['name']);
  }
}
