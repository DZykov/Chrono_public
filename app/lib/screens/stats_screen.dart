import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/global_variables.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/info_card.dart';
import 'package:chrono_alpha/widgets/logo.dart';
import 'package:chrono_alpha/resources/feed_methods.dart';
import 'package:chrono_alpha/resources/posts_methods.dart';
import 'package:flutter/material.dart';
import 'package:chrono_alpha/models/post.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key, required this.selfUser}) : super(key: key);

  final User selfUser; // me

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const perPage = 20;

  AuthService auth = AuthService();
  FeedService feed = FeedService();
  bool next = false;
  int page = 1;
  PostsService posts = PostsService();

  final List<dynamic> _posts = [];

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
    _getPosts();
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

  Widget buildHeader(bool noPosts) {
    return Container(
      alignment: Alignment.center,
      child: noPosts == true
          ? const Text("You have 0 posts!")
          : const SizedBox.shrink(),
    );
  }

  _getPosts() async {
    List<Tuple> check = [Tuple(contents: [], nextPage: false)];
    setState(() {
      _isLoading = true;
    });
    try {
      List<Tuple> response = await posts.getAllPostsUserByIdPrivate(
          widget.selfUser.id, page, perPage);
      check = response;
      _posts.addAll(response[1].contents);
      setState(() {
        _isLoading = false;
        page++;
        next = check[1].nextPage;
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: true,
              title: const Logo(),
              actions: const [],
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
              if (index == _posts.length) {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: FittedBox(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return InfoCard(
                snap: _posts[index] as Post,
                selfUser: widget.selfUser,
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
