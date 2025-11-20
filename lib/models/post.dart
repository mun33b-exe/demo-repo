class Post {
  final String id;
  final String content;
  final String? userEmail;
  final List<String> likes;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.content,
    this.userEmail,
    required this.likes,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      userEmail: json['user_email'],
      likes: List<String>.from(json['likes'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
