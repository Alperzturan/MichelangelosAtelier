class ReviewModel {
  final int id;
  final int userId;
  final int artworkId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.artworkId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userId: json['user_id'],
      artworkId: json['artwork_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'artwork_id': artworkId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}