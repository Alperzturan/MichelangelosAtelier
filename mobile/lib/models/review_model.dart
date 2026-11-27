class ReviewModel {
  final int id;
  final int userId;
  final int artworkId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final String? userName;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.artworkId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final dynamic nestedUser = json['user'];
    final String? parsedUserName = json['user_name']?.toString() ??
        json['full_name']?.toString() ??
        (nestedUser is Map<String, dynamic>
            ? nestedUser['full_name']?.toString()
            : null);

    return ReviewModel(
      id: json['id'],
      userId: json['user_id'],
      artworkId: json['artwork_id'],
      rating: json['rating'],
      comment: (json['comment'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      userName: parsedUserName,
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
      if (userName != null) 'user_name': userName,
    };
  }
}