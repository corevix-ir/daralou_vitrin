class NewsModel {
  final String id;
  final String categoryTag;
  final String title;
  final String imageUrl;
  final String publishedAt;
  final int totalSlides;
  final int activeIndex;

  NewsModel({
    required this.id,
    required this.categoryTag,
    required this.title,
    required this.imageUrl,
    required this.publishedAt,
    this.totalSlides = 4,
    this.activeIndex = 0,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String,
      categoryTag: json['categoryTag'] as String? ?? 'اخبار رسمی',
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      publishedAt: json['publishedAt'] as String,
      totalSlides: json['totalSlides'] as int? ?? 4,
      activeIndex: json['activeIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryTag': categoryTag,
      'title': title,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt,
      'totalSlides': totalSlides,
      'activeIndex': activeIndex,
    };
  }
}
