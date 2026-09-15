class ReviewCardModel {
  const ReviewCardModel({required this.id, required this.author, required this.rating, required this.content, required this.date});

  final int id;
  final String author;
  final int rating;
  final String content;
  final String date;

  factory ReviewCardModel.fromJson(Map<String, dynamic> json) {
    return ReviewCardModel(id: json['id'], author: json['author'], rating: json['rating'], content: json['content'], date: json['date']);
  }
}
