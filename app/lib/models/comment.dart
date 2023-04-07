class Comment {
  Comment(
      {required this.id,
      required this.userId,
      required this.postId,
      required this.text,
      required this.username,
      required this.photoUrl});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      userId: json["user_id"],
      postId: json["post_id"],
      text: json["text"],
      username: json["username"],
      photoUrl: json["photo_url"],
    );
  }

  int id;
  int postId;
  String text;
  String username;
  String photoUrl;
  int userId;

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": text,
        "postId": postId,
        "text": text,
      };
}
