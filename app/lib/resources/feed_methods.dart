import 'dart:convert';
import 'dart:developer';
import 'package:chrono_alpha/models/post.dart';
import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/constants/api_constants.dart';
import 'package:chrono_alpha/resources/auth_methods.dart' as auth;
import 'package:chrono_alpha/constants/storage.dart' as storage;
import 'package:http/http.dart' as http;

class FeedService {
  auth.AuthService auths = auth.AuthService();

  Future<Tuple> updateFeed(int page, int perPage) async {
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return Tuple(contents: [], nextPage: false);
      }
      final queryParameters = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      var url = Uri.parse(ApiConstants.baseUrlFeed + ApiConstants.refreshFeed)
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
            return Tuple(contents: [], nextPage: false);
          }
        }
        return Tuple(contents: posts, nextPage: data['meta']['has_next']);
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        String res = await auths.refreshToken();
        if (res == "success") {
          return await updateFeed(page, perPage);
        }
      }
    } catch (err) {
      log(err.toString());
    }
    return Tuple(contents: [], nextPage: false);
  }

  Future<Tuple> discoverFeed(
      int page, int perPage, String order, tags, name) async {
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return Tuple(contents: [], nextPage: false);
      }
      final queryParameters = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      var url = Uri.parse(
              "${ApiConstants.baseUrlFeed}${ApiConstants.discoverFeed}$order")
          .replace(queryParameters: queryParameters);
      var response = await http.put(url,
          headers: {
            //'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({
            'tags': tags,
            'name': name,
          }));
      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        List<Post> posts = <Post>[];
        for (var element in data['data']) {
          try {
            Post p = Post.fromJson(element);
            posts.add(p);
          } catch (e) {
            return Tuple(contents: [], nextPage: false);
          }
        }
        return Tuple(contents: posts, nextPage: data['meta']['has_next']);
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        String res = await auths.refreshToken();
        if (res == "success") {
          return await discoverFeed(page, perPage, order, tags, name);
        }
      }
    } catch (err) {
      log(err.toString());
    }
    return Tuple(contents: [], nextPage: false);
  }
}
