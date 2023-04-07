class User {
  User({
    required this.username,
    required this.id,
    required this.photoUrl,
    required this.description,
    required this.followersNum,
    required this.followingNum,
    //required this.tags
  });

  //List<dynamic> tags;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json["username"],
      id: json["id"],
      description: json["description"],
      followersNum: json["followers_num"],
      followingNum: json["following_num"],
      photoUrl: json["photo_url"],
      //tags: (json["tags"] as List).map((item) => item as String).toList(),
    );
  }

  String description;
  int followersNum;
  int followingNum;
  int id;
  String photoUrl;
  String username;

  Map<String, dynamic> toJson() =>
      {"id": id, "username": username, "description": description};
}
