class ReviewItemModel {
  const ReviewItemModel({required this.id, required this.author, required this.rating, required this.content, required this.date});

  final int id;
  final String author;
  final int rating;
  final String content;
  final String date;

  factory ReviewItemModel.fromJson(Map<String, dynamic> json) {
    return ReviewItemModel(id: json['id'], author: json['author'], rating: json['rating'], content: json['content'], date: json['date']);
  }
}
