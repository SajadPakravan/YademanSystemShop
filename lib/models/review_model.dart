class ReviewModel {
  int? id;
  String? dateCreated;
  String? dateCreatedGmt;
  int? productId;
  String? productName;
  String? status;
  String? reviewer;
  String? reviewerEmail;
  ReviewerAvatarUrls? avatarUrls;
  String? review;
  int? rating;

  ReviewModel({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.productId,
    this.status,
    this.reviewer,
    this.reviewerEmail,
    this.avatarUrls,
    this.review,
    this.rating,
  });

  ReviewModel.fromJson(dynamic json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateCreatedGmt = json['date_created_gmt'];
    productId = json['product_id'];
    status = json['status'];
    reviewer = json['reviewer'];
    reviewerEmail = json['reviewer_email'];
    avatarUrls = json['reviewer_avatar_urls'] != null ? ReviewerAvatarUrls.fromJson(json['reviewer_avatar_urls']) : null;
    review = json['review'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['date_created'] = dateCreated;
    data['date_created_gmt'] = dateCreatedGmt;
    data['product_id'] = productId;
    data['status'] = status;
    data['reviewer'] = reviewer;
    data['reviewer_email'] = reviewerEmail;
    if (avatarUrls != null) data['reviewer_avatar_urls'] = avatarUrls!.toJson();
    data['review'] = review;
    data['rating'] = rating;
    return data;
  }
}

class ReviewerAvatarUrls {
  String? s24;
  String? s48;
  String? s96;

  ReviewerAvatarUrls({this.s24, this.s48, this.s96});

  ReviewerAvatarUrls.fromJson(Map<String, dynamic> json) {
    s24 = json['24'];
    s48 = json['48'];
    s96 = json['96'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['24'] = s24;
    data['48'] = s48;
    data['96'] = s96;
    return data;
  }
}
