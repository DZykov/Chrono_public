import 'dart:convert';
import 'dart:typed_data';
import 'package:chrono_alpha/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:chrono_alpha/constants/storage.dart' as storage;
import 'package:chrono_alpha/resources/auth_methods.dart' as auth;

class UploadMethods {
  auth.AuthService auths = auth.AuthService();

  Future<String> uploadImagePost(Uint8List file, int postId) async {
    var url = Uri.parse(ApiConstants.baseUrlPosts +
        ApiConstants.updatePostImg +
        postId.toString());
    String? access = await storage.storage.read(key: 'access');
    if (access == null) {
      return '';
    }
    /*
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
    
    request.headers.addAll({'Authorization': 'Bearer '+ access});
    request.files.add(http.MultipartFile.fromBytes('file', file, contentType: MediaType('application', 'jpeg'),));

    http.StreamedResponse response = await request.send();

    final responseStr = await response.stream.bytesToString();
    Map data = json.decode(responseStr);
    */
    String imageBase64 = base64Encode(file);

    var response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $access',
          "Accept": "application/json",
          "content-type": "application/json"
        },
        body: jsonEncode({'image': imageBase64}));

    Map data = json.decode(response.body);
    if (response.statusCode == 401 &&
        data.containsKey("msg") &&
        data['msg'] == "Token has expired!") {
      String res = await auths.refreshToken();
      if (res == "success") {
        res = await uploadImagePost(file, postId);
      }
      return res;
    } else if (response.statusCode == 201) {
      return data['photo_url'];
    }

    return '';
  }

  Future<String> uploadAvatar(Uint8List file, int userId) async {
    var url = Uri.parse(ApiConstants.baseUrlAuth + ApiConstants.updateAvatar);
    String? access = await storage.storage.read(key: 'access');
    if (access == null) {
      return '';
    }
    /*
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({'Authorization': 'Bearer ' + access, "Content-type": "multipart/form-data"});
    request.files.add(http.MultipartFile.fromBytes('file', file, contentType: MediaType('image', 'jpeg')));

    http.StreamedResponse response = await request.send();

    final responseStr = await response.stream.bytesToString();
    Map data = json.decode(responseStr);
    */
    String imageBase64 = base64Encode(file);

    var response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $access',
          "Accept": "application/json",
          "content-type": "application/json"
        },
        body: jsonEncode({'image': imageBase64}));

    Map data = json.decode(response.body);

    if (response.statusCode == 401 &&
        data.containsKey("msg") &&
        data['msg'] == "Token has expired!") {
      String res = await auths.refreshToken();
      if (res == "success") {
        res = await uploadAvatar(file, userId);
      }
      return res;
    } else if (response.statusCode == 201) {
      return data['photo_url'];
    }

    return '';
  }
}
