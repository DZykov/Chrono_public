import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrono_alpha/constants/other_constants.dart';
import 'package:chrono_alpha/models/post.dart';
import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/resources/posts_methods.dart';
import 'package:chrono_alpha/screens/login_screen.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/follow_button.dart';
import 'package:chrono_alpha/widgets/post_card.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.selfUser}) : super(key: key);

  final User selfUser; // not me

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const perPage = 20;

  AuthService auth = AuthService();
  bool next = false;
  int page = 1;
  PostsService posts = PostsService();
  int postsLength = 0;
  User userN = User(
      username: '',
      id: -1,
      photoUrl: EmptyConstants.noAvatar,
      description: '',
      followersNum: 0,
      followingNum: 0);

  User selfUser = User(
      username: '',
      id: -1,
      photoUrl: EmptyConstants.noAvatar,
      description: '',
      followersNum: 0,
      followingNum: 0);

  final List<dynamic> _posts = [];

  bool _isFollowing = false;
  bool _isLoading = false;
  late ScrollController _scrollController;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkUserEmpty();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoading) {
        if (next) {
          _getPosts();
        }
      }
    });
  }

  _checkUserEmpty() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.selfUser.username == "-1" &&
        widget.selfUser.followersNum == -1 &&
        widget.selfUser.followingNum == -1) {
      User dummyUser = await auth.getUserDetails(userId: widget.selfUser.id);
      setState(() {
        selfUser = dummyUser;
      });
      _getUserAsync();
      _getPosts();
    } else {
      setState(() {
        selfUser = widget.selfUser;
      });
      _getUserAsync();
      _getPosts();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Column buildHeader(bool noPosts) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.contain,
                imageUrl: selfUser.photoUrl,
                imageBuilder: (context, imageProvider) {
                  // you can access to imageProvider
                  return CircleAvatar(
                    // or any widget that use imageProvider like (PhotoView)
                    backgroundImage: imageProvider,
                    radius: 70,
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  top: 15,
                ),
                child: Text(
                  selfUser.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  top: 15,
                ),
                child: Text(
                  selfUser.description,
                ),
              ),
              const Divider(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildStatColumn(postsLength, "posts"),
                            buildStatColumn(selfUser.followersNum, "followers"),
                            buildStatColumn(selfUser.followingNum, "following"),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 25)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            userN.id == selfUser.id
                                ? FollowButton(
                                    text: 'Sign Out',
                                    backgroundColor: mobileBackgroundColor,
                                    textColor: primaryColor,
                                    borderColor: Colors.grey,
                                    function: () async {
                                      await auth.logout();
                                      if (context.mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : _isFollowing
                                    ? FollowButton(
                                        text: 'Unfollow',
                                        backgroundColor: activeColor,
                                        textColor: Colors.black,
                                        borderColor: activeColor,
                                        function: () async {
                                          await auth.unfollowUserById(
                                              id: selfUser.id);

                                          setState(() {
                                            _isFollowing = false;
                                            selfUser.followersNum--;
                                          });
                                        },
                                      )
                                    : FollowButton(
                                        text: 'Follow',
                                        backgroundColor: activeColor,
                                        textColor: Colors.white,
                                        borderColor: activeColor,
                                        function: () async {
                                          await auth.followUserById(
                                              id: selfUser.id);

                                          setState(() {
                                            _isFollowing = true;
                                            selfUser.followersNum++;
                                          });
                                        },
                                      )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        noPosts == true ? const Text("No posts!") : const SizedBox.shrink(),
      ],
    );
  }

  SizedBox buildStatColumn(int num, String label) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 4,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getPosts() async {
    List<Tuple> check = [Tuple(contents: [], nextPage: false)];
    setState(() {
      _isLoading = true;
    });
    try {
      List<Tuple> response =
          await posts.getAllPostsUserById(selfUser.id, page, perPage);
      check = response;
      _posts.addAll(response[1].contents);
      setState(() {
        _isLoading = false;
        page++;
        next = check[1].nextPage;
        postsLength = check[0].nextPage;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(
        context,
        e.toString(),
      );
    }
  }

  Future<void> _getUserAsync() async {
    try {
      userN = await auth.getMineDetails();
      _isFollowing = await auth.checkFolow(selfUser.id);
      if (userN.id == -1) {
        if (context.mounted) {
          showSnackBar(
            context,
            "Something went wrong!",
          );
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              foregroundColor: activeColor,
              title: Text(
                selfUser.username,
                style: const TextStyle(color: activeColor),
              ),
              centerTitle: false,
            ),
            body: SafeArea(
              minimum: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Center(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildHeader(_posts.isEmpty);
                    }
                    index -= 1;
                    if (index == _posts.length && next == true) {
                      return const SizedBox(
                        width: 60,
                        height: 60,
                        child: FittedBox(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return PostCard(
                      snap: _posts[index] as Post,
                      selfUser: userN,
                    );
                  },
                  controller: _scrollController,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: _posts.length + (next ? 1 : 0) + 1,
                  addAutomaticKeepAlives: true,
                ),
              ),
            ),
          );
  }
}
