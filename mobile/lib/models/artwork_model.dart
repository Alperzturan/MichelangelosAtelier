class ArtworkModel {
  final int id;
  final String title;
  final String artist;
  final int year;
  final String imageUrl;
  final String description;
  final int categoryId;
  final String? artistBio;
  final String? artistPeriod;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.imageUrl,
    required this.description,
    required this.categoryId,
    this.artistBio,
    this.artistPeriod,
  });

  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    return ArtworkModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      year: json['year'],
      imageUrl: json['image_url'],
      description: json['description'] ?? '',
      categoryId: json['category_id'],
      artistBio: json['artist_bio']?.toString(),
      artistPeriod: json['artist_period']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'year': year,
      'image_url': imageUrl,
      'description': description,
      'category_id': categoryId,
      if (artistBio != null) 'artist_bio': artistBio,
      if (artistPeriod != null) 'artist_period': artistPeriod,
    };
  }
}