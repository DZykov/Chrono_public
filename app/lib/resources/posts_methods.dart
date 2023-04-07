import 'dart:convert';
import 'dart:developer';
import 'package:chrono_alpha/constants/other_constants.dart';
import 'package:chrono_alpha/models/post.dart';
import 'package:chrono_alpha/constants/api_constants.dart';
import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/resources/auth_methods.dart' as auth;
import 'package:chrono_alpha/constants/storage.dart' as storage;
import 'package:http/http.dart' as http;

class PostsService {
  auth.AuthService auths = auth.AuthService();

  Future<String> uploadPost(String name, String description, String body,
      List<String> tags, String urlp, bool draft) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(ApiConstants.baseUrlPosts + ApiConstants.createPost);
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({
            'name': name,
            'description': description,
            'body': body,
            'tags': tags,
            'url': urlp,
            'draft': draft,
          }));
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = data['post']['id'].toString();
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await auths.refreshToken();
        if (res == "success") {
          res = await uploadPost(name, description, body, tags, urlp, draft);
        }
      } else if (response.statusCode == 409 &&
          data.containsKey("error") &&
          data['error'] == "Url is taken! Please, choose another one.") {
        res = "Url is taken! Please, choose another one.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(int id) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlPosts + ApiConstants.deletePost + id.toString());
      var response =
          await http.delete(url, headers: {'Authorization': 'Bearer $access'});
      if (response.statusCode == 204) {
        res = "success";
      } else if (response.statusCode != 404) {
        res = await auths.refreshToken();
        if (res == "success") {
          res = await deletePost(id);
        }
      }
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> updatePost(String name, String description, String body,
      List<String> tags, String urlp, int id, bool draft) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlPosts + ApiConstants.editPost + id.toString());
      var response = await http.put(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({
            'name': name,
            'description': description,
            'body': body,
            'tags': tags,
            'url': urlp,
            'draft': draft,
          }));

      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = data['post']['id'].toString();
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await auths.refreshToken();
        if (res == "success") {
          res =
              await updatePost(name, description, body, tags, urlp, id, draft);
        }
      } else if (response.statusCode == 400) {
        res = data['error'];
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePostById(int id) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlPosts + ApiConstants.likePost + id.toString());
      var response =
          await http.post(url, headers: {'Authorization': 'Bearer $access'});

      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = "success";
      } else if (response.statusCode == 404 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await auths.refreshToken();
        if (res == "success") {
          res = await likePostById(id);
        }
      } else if (response.statusCode == 404) {
        res = data['error'];
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> dislikePostById(int id) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlPosts + ApiConstants.dislikePost + id.toString());
      var response =
          await http.post(url, headers: {'Authorization': 'Bearer $access'});

      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = "success";
      } else if (response.statusCode == 404 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await auths.refreshToken();
        if (res == "success") {
          res = await dislikePostById(id);
        }
      } else if (response.statusCode == 404) {
        res = data['error'];
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<bool> likedPostByUser(int id) async {
    bool res = false;
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(ApiConstants.baseUrlPosts +
          ApiConstants.checkPostLikeByUser +
          id.toString());
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $access'});

      //Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = true;
      } else if (response.statusCode == 204) {
        String resAuth = await auths.refreshToken();
        if (resAuth == "success") {
          res = await likedPostByUser(id);
        }
      } else if (response.statusCode == 404) {
        res = false;
      }
    } catch (err) {
      err.toString();
    }
    return res;
  }

  Future<List<Tuple>> getAllPostsUserById(
      int userId, int page, int perPage) async {
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return [Tuple(contents: [], nextPage: false)];
      }
      final queryParameters = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      var url = Uri.parse(ApiConstants.baseUrlPosts +
              ApiConstants.getAllByUser +
              userId.toString())
          .replace(queryParameters: queryParameters);
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $access'});
      Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        List<Post> posts = <Post>[];
        for (var element in data['data']) {
          try {
            Post p = Post.fromJson(element);
            posts.add(p);
          } catch (e) {
            return [Tuple(contents: [], nextPage: false)];
          }
        }
        return [
          Tuple(contents: [], nextPage: data['meta']['total_count']),
          Tuple(contents: posts, nextPage: data['meta']['has_next'])
        ];
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        String res = await auths.refreshToken();
        if (res == "success") {
          return await getAllPostsUserById(userId, page, perPage);
        }
      }
    } catch (err) {
      log(err.toString());
    }
    return [Tuple(contents: [], nextPage: false)];
  }

  Future<List<Tuple>> getAllPostsUserByIdPrivate(
      int userId, int page, int perPage) async {
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return [Tuple(contents: [], nextPage: false)];
      }
      final queryParameters = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      var url = Uri.parse(
              ApiConstants.baseUrlPosts + ApiConstants.getAllByUserPrivate)
          .replace(queryParameters: queryParameters);
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $access'});
      Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        List<Post> posts = <Post>[];
        for (var element in data['data']) {
          try {
            Post p = Post.fromJson(element);
            posts.add(p);
          } catch (e) {
            return [Tuple(contents: [], nextPage: false)];
          }
        }
        return [
          Tuple(contents: [], nextPage: data['meta']['total_count']),
          Tuple(contents: posts, nextPage: data['meta']['has_next'])
        ];
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        String res = await auths.refreshToken();
        if (res == "success") {
          return await getAllPostsUserByIdPrivate(userId, page, perPage);
        }
      }
    } catch (err) {
      log(err.toString());
    }
    return [Tuple(contents: [], nextPage: false)];
  }

  Future<Post> getPostById(int postId) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlPosts +
          ApiConstants.getPostById +
          postId.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Post post = Post.fromJson(jsonDecode(response.body));
        return post;
      }
    } catch (e) {
      log(e.toString());
    }
    return Post(
        id: EmptyConstants.emptyId,
        url: EmptyConstants.emptyString,
        shortUrl: EmptyConstants.emptyString,
        user: EmptyConstants.emptyId,
        name: EmptyConstants.emptyString,
        description: EmptyConstants.emptyString,
        body: EmptyConstants.emptyString,
        tags: EmptyConstants.emptyList,
        visits: EmptyConstants.emptyId,
        views: EmptyConstants.emptyId,
        createdAt: EmptyConstants.emptyString,
        updatedAt: EmptyConstants.emptyString,
        photoUrl: EmptyConstants.noPhoto,
        likes: EmptyConstants.emptyId,
        comments: EmptyConstants.emptyId,
        draft: false);
  }

  Future<Post> getPostByIdPrivate(int postId) async {
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return Post(
            id: EmptyConstants.emptyId,
            url: EmptyConstants.emptyString,
            shortUrl: EmptyConstants.emptyString,
            user: EmptyConstants.emptyId,
            name: EmptyConstants.emptyString,
            description: EmptyConstants.emptyString,
            body: EmptyConstants.emptyString,
            tags: EmptyConstants.emptyList,
            visits: EmptyConstants.emptyId,
            views: EmptyConstants.emptyId,
            createdAt: EmptyConstants.emptyString,
            updatedAt: EmptyConstants.emptyString,
            photoUrl: EmptyConstants.noPhoto,
            likes: EmptyConstants.emptyId,
            comments: EmptyConstants.emptyId,
            draft: false);
      }
      var url = Uri.parse(ApiConstants.baseUrlPosts +
          ApiConstants.getPostByIdPrivate +
          postId.toString());
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $access'});
      if (response.statusCode == 200) {
        Post post = Post.fromJson(jsonDecode(response.body));
        return post;
      }
    } catch (e) {
      log(e.toString());
    }
    return Post(
        id: EmptyConstants.emptyId,
        url: EmptyConstants.emptyString,
        shortUrl: EmptyConstants.emptyString,
        user: EmptyConstants.emptyId,
        name: EmptyConstants.emptyString,
        description: EmptyConstants.emptyString,
        body: EmptyConstants.emptyString,
        tags: EmptyConstants.emptyList,
        visits: EmptyConstants.emptyId,
        views: EmptyConstants.emptyId,
        createdAt: EmptyConstants.emptyString,
        updatedAt: EmptyConstants.emptyString,
        photoUrl: EmptyConstants.noPhoto,
        likes: EmptyConstants.emptyId,
        comments: EmptyConstants.emptyId,
        draft: false);
  }

  Future<int> getLikesPostById(int postId) async {
    int res = 0;
    try {
      var url = Uri.parse(ApiConstants.baseUrlPosts +
          ApiConstants.getPostLikes +
          postId.toString());
      var response = await http.get(url);

      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = data['likes'];
      } else if (response.statusCode == 404) {
        res = 0;
      }
    } catch (err) {
      log(err.toString());
    }
    return res;
  }

  Future<List<String>> getTagsPostById(int postId) async {
    List<String> res = [];
    try {
      var url = Uri.parse(ApiConstants.baseUrlPosts +
          ApiConstants.getPostTags +
          postId.toString());
      var response = await http.get(url);

      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = data['tags'];
      } else if (response.statusCode == 404) {
        res = [];
      }
    } catch (err) {
      log(err.toString());
    }
    return res;
  }

  Future<int> checkTagsCount(List<String> tags) async {
    int res = 0;
    try {
      var url =
          Uri.parse(ApiConstants.baseUrlPosts + ApiConstants.checkPostTags);
      var response = await http.post(url, body: {tags});

      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = data['num'];
      } else {
        res = 0;
      }
    } catch (err) {
      log(err.toString());
    }
    return res;
  }
}
