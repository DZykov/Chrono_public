import 'dart:convert';

List<Post> sampleFromJson(String str) {
  final jsonData = json.decode(str);
  return List<Post>.from(jsonData.map((x) => Post.fromJson(x)));
}

class Post {
  Post({
    required this.id,
    required this.url,
    required this.shortUrl,
    required this.user,
    required this.name,
    required this.description,
    required this.body,
    required this.tags,
    required this.visits,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
    required this.photoUrl,
    required this.likes,
    required this.comments,
    required this.draft,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      url: json["url"],
      shortUrl: json["short_url"],
      user: json["user"],
      name: json["name"],
      description: json["description"],
      body: json["body"],
      tags: (json["tags"] as List).map((item) => item as String).toList(),
      visits: json["visits"],
      views: json["views"],
      likes: json["likes"],
      comments: json["comments"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"] ?? json["created_at"],
      photoUrl: json['photo_url'],
      draft: json['draft'],
    );
  }

  String body;
  int comments;
  String createdAt;
  String description;
  bool draft;
  int id;
  int likes;
  String name;
  String photoUrl;
  String shortUrl;
  List<String> tags;
  String updatedAt;
  String url;
  int user;
  int views;
  int visits;

  @override
  toString() {
    return """id: $id,url: $url,shortUrl: $shortUrl,user: $user, name: $name, description: $description, 
            body: $body, tags: $tags, visits: $visits, likes: $likes views: $views, 
            createdAt: $createdAt, updatedAt: $updatedAt, photoUrl: photoUrl""";
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
        "short_url": shortUrl,
        "user": user,
        "name": name,
        "description": description,
        "body": body,
        "tags": tags,
        "visits": visits,
        "views": views,
      };
}
