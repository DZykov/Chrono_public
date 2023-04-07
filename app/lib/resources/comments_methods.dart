import 'dart:convert';
import 'dart:developer';
import 'package:chrono_alpha/models/comment.dart';
import 'package:chrono_alpha/constants/api_constants.dart';
import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/resources/auth_methods.dart' as auth;
import 'package:chrono_alpha/constants/storage.dart' as storage;
import 'package:http/http.dart' as http;

class CommentsServices {
  auth.AuthService auths = auth.AuthService();

  Future<String> uploadComment(int postId, String text) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url =
          Uri.parse(ApiConstants.baseUrlComments + ApiConstants.createComment);
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({
            'post_id': postId,
            'text': text,
          }));
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = data['comment']['id'].toString();
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await auths.refreshToken();
        if (res == "success") {
          res = await uploadComment(postId, text);
        }
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteComment(int id) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(ApiConstants.baseUrlComments +
          ApiConstants.deleteComment +
          id.toString());
      var response =
          await http.delete(url, headers: {'Authorization': 'Bearer $access'});
      if (response.statusCode == 204) {
        res = "success";
      } else if (response.statusCode != 404) {
        res = await auths.refreshToken();
        if (res == "success") {
          res = await deleteComment(id);
        }
      }
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<Tuple> getAllPostsCommentById(
      int postId, int page, int perPage) async {
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return Tuple(contents: [], nextPage: false);
      }
      final queryParameters = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      var url = Uri.parse(ApiConstants.baseUrlComments +
              ApiConstants.getPostComments +
              postId.toString())
          .replace(queryParameters: queryParameters);
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $access'});
      Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        List<Comment> comments = <Comment>[];
        for (var element in data['data']) {
          try {
            Comment c = Comment.fromJson(element);
            comments.add(c);
          } catch (e) {
            return Tuple(contents: [], nextPage: false);
          }
        }
        return Tuple(contents: comments, nextPage: data['meta']['has_next']);
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        String res = await auths.refreshToken();
        if (res == "success") {
          return await getAllPostsCommentById(postId, page, perPage);
        }
      }
    } catch (err) {
      log(err.toString());
    }
    return Tuple(contents: [], nextPage: false);
  }
}
