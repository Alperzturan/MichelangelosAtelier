class FavoriteModel {
  final int id;
  final int userId;
  final int artworkId;
  final DateTime? createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.artworkId,
    this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      userId: json['user_id'],
      artworkId: json['artwork_id'],
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
      'created_at': createdAt?.toIso8601String(),
    };
  }
}