class ApiConstants {
  static String baseUrl = 'API LINK';

  static String baseUrlAuth = '${baseUrl}v1/auth';
  // post requests
  static String register = '/register';
  static String login = '/login';
  static String updateAvatar = '/update/avatar';
  static String tokenRefresh = '/token/refresh';
  static String updateUserDescription = '/update/description';
  static String updateUserTags = '/update/tags';
  static String followUser = '/follow/';
  static String unfollowUser = '/unfollow/';
  // get requests
  static String getMe = '/me';
  static String getUser = '/user/';
  static String getAvatar = '/get/avatar/';
  static String getUserTags = 'get/tags/';
  static String getUserCountFollowers = '/get/followers/count/';
  static String getUserCountFollowing = '/get/following/count/';
  static String getUserFollowers = '/get/followers/';
  static String getUserFollowing = '/get/following/';
  static String checkFollow = '/check/follow/';

  static String baseUrlPosts = '${baseUrl}v1/posts';
  // post requests
  static String createPost = '/create';
  static String updatePostImg = '/update/imgpost/';
  static String deletePost = '/delete/';
  static String editPost = '/update/';
  static String likePost = '/like/';
  static String dislikePost = '/dislike/';
  // get
  static String getAllByUserPrivate = '/private/all/user/';
  static String getAllByUser = '/all/user/';
  static String getPostByIdPrivate = '/pid/';
  static String getPostById = '/id/';
  static String getPostByUrl = '/url/';
  static String getPostImg = '/get/pimgpost/';
  static String getPostLikes = '/get/likes/';
  static String getPostTags = '/get/tags/';
  static String checkPostTags = '/check/tags/';
  static String checkPostLikeByUser = '/get/user/likes/';

  static String baseUrlFeed = '${baseUrl}v1/feed';
  // get
  static String refreshFeed = '/refresh';
  static String discoverFeed = '/discover/';

  static String baseUrlComments = '${baseUrl}v1/comments';
  // post
  static String createComment = '/create';
  static String deleteComment = '/delete/';
  // get
  static String getPostComments = '/get/';

  static String baseUrlAds = '${baseUrl}v1/ads';
  // post
  static String authAd = '/auth/';
  static String createAd = '/create';
  static String setAdImg = '/set_img/';
  // get
  static String getAdByTags = '/get';
  static String getAdImg = '/get/img';
}
