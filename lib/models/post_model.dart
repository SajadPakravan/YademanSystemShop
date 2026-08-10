class PostModel {
  const PostModel({required this.id, required this.title, required this.excerpt, required this.image, required this.date});

  final int id;
  final String title;
  final String excerpt;
  final String image;
  final String date;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(id: json['id'], title: json['title'], excerpt: json['excerpt'], image: json['image'], date: json['date']);
  }
}
