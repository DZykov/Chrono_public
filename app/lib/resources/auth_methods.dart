import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chrono_alpha/constants/api_constants.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/constants/storage.dart' as storage;

class AuthService {
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        var url = Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.register);
        var response = await http.post(url,
            headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            },
            body: jsonEncode(
                {'username': username, 'email': email, 'password': password}));
        if (response.statusCode == 201) {
          res = "success";
          Map data = json.decode(response.body);
          if (data.containsKey('error')) {
            res = data['error'];
          } else {
            await storage.storage.write(key: "access", value: data['access']);
            await storage.storage.write(key: "refresh", value: data['refresh']);
          }
        } else {
          Map data = json.decode(response.body);
          if (data.containsKey('error')) {
            res = data['error'];
          }
        }
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // logging in user with email and password
        var url = Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.login);
        var response = await http.post(url,
            headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            },
            body: jsonEncode({'username': email, 'password': password}));
        if (response.statusCode == 200) {
          res = "success";
          Map data = json.decode(response.body);
          await storage.storage.write(key: "access", value: data['access']);
          await storage.storage.write(key: "refresh", value: data['refresh']);
          res = "success";
        } else {
          Map data = json.decode(response.body);
          if (data.containsKey('error')) {
            res = data['error'];
          }
        }
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> refreshToken() async {
    String res = "Some error occurred";
    try {
      String? refresh = await storage.storage.read(key: "refresh");
      // logging in user with email and password
      var url = Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.tokenRefresh);
      if (refresh == null) {
        return res;
      }
      var response =
          await http.post(url, headers: {'Authorization': 'Bearer $refresh'});
      if (response.statusCode == 200) {
        res = "success";
        Map data = json.decode(response.body);
        await storage.storage.write(key: "access", value: data['access']);
        res = "success";
      } else if (response.statusCode == 401) {
        res = "Token has expired!";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> updateUserDescription({required String description}) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlAuth + ApiConstants.updateUserDescription);
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({'description': description}));
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = "success";
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await refreshToken();
        if (res == "success") {
          res = await updateUserDescription(description: description);
        }
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> updateUserTags({required List<String> tags}) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url =
          Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.updateUserTags);
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({'tags': tags}));
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = "success";
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await refreshToken();
        if (res == "success") {
          res = await updateUserTags(tags: tags);
        }
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> followUserById({required int id}) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlAuth + ApiConstants.followUser + id.toString());
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $access',
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = "success";
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await refreshToken();
        if (res == "success") {
          res = await followUserById(id: id);
        }
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> followUserByUsername({required String username}) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.followUser);
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({'username': username}));
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = "success";
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await refreshToken();
        if (res == "success") {
          res = await followUserByUsername(username: username);
        }
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> unfollowUserById({required int id}) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlAuth + ApiConstants.unfollowUser + id.toString());
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({'id': id}));
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = "success";
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await refreshToken();
        if (res == "success") {
          res = await followUserById(id: id);
        }
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> unfollowUserByUsername({required String username}) async {
    String res = "Some error occurred";
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.unfollowUser);
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $access',
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({'username': username}));
      Map data = json.decode(response.body);
      if (response.statusCode == 201) {
        res = "success";
      } else if (response.statusCode == 401 &&
          data.containsKey("msg") &&
          data['msg'] == "Token has expired!") {
        res = await refreshToken();
        if (res == "success") {
          res = await followUserByUsername(username: username);
        }
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<User> logout() async {
    await storage.storage.write(key: "access", value: '');
    await storage.storage.write(key: "refresh", value: '');
    return User(
        username: '',
        id: -1,
        photoUrl: '',
        description: '',
        followersNum: 0,
        followingNum: 0);
  }

  Future<User> getMineDetails() async {
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access!.isEmpty) {
        return User(
            username: '',
            id: -1,
            photoUrl: '',
            description: '',
            followersNum: 0,
            followingNum: 0);
      }
      var url = Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.getMe);
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $access'});
      if (response.statusCode == 200) {
        User user = User.fromJson(jsonDecode(response.body.toString()));
        return user;
      } else if (response.statusCode == 401) {
        String res = await refreshToken();
        if (res == "success") {
          return await getMineDetails();
        }
      }
    } catch (e) {
      e.toString();
    }
    return User(
        username: '',
        id: -10,
        photoUrl: '',
        description: '',
        followersNum: 0,
        followingNum: 0);
  }

  // get user details
  Future<User> getUserDetails({required int userId}) async {
    try {
      var url = Uri.parse(
          ApiConstants.baseUrlAuth + ApiConstants.getUser + userId.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        try {
          User user = User.fromJson(jsonDecode(response.body));
          return user;
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return User(
        username: '',
        id: -1,
        photoUrl: '',
        description: '',
        followersNum: 0,
        followingNum: 0);
  }

  Future<String> getUserAvatarUrl({required int userId}) async {
    return ApiConstants.baseUrlAuth + ApiConstants.getUser + userId.toString();
  }

  Future<List<String>> getUserTags({required int userId}) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlAuth +
          ApiConstants.getUserTags +
          userId.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<String> tags = json.decode(response.body);
        return tags;
      }
    } catch (e) {
      log(e.toString());
    }
    return [];
  }

  Future<int> getUserCountFollowers({required int userId}) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlAuth +
          ApiConstants.getUserCountFollowers +
          userId.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        int count = json.decode(response.body);
        return count;
      }
    } catch (e) {
      log(e.toString());
    }
    return 0;
  }

  Future<int> getUserCountFollowing({required int userId}) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlAuth +
          ApiConstants.getUserCountFollowing +
          userId.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        int count = json.decode(response.body);
        return count;
      }
    } catch (e) {
      log(e.toString());
    }
    return 0;
  }

  Future<List<int>> getUserFollowers({required int userId}) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlAuth +
          ApiConstants.getUserFollowers +
          userId.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<int> followers = json.decode(response.body);
        return followers;
      }
    } catch (e) {
      log(e.toString());
    }
    return [];
  }

  Future<List<int>> getUserFollowing({required int userId}) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlAuth +
          ApiConstants.getUserFollowing +
          userId.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<int> following = json.decode(response.body);
        return following;
      }
    } catch (e) {
      log(e.toString());
    }
    return [];
  }

  Future<bool> checkFolow(int id) async {
    bool res = false;
    try {
      String? access = await storage.storage.read(key: 'access');
      if (access == null) {
        return res;
      }
      var url = Uri.parse(
          ApiConstants.baseUrlAuth + ApiConstants.checkFollow + id.toString());
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $access'});

      //Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        res = true;
      } else if (response.statusCode == 204) {
        String resAuth = await refreshToken();
        if (resAuth == "success") {
          res = await checkFolow(id);
        }
      } else if (response.statusCode == 404) {
        res = false;
      }
    } catch (err) {
      err.toString();
    }
    return res;
  }
}
