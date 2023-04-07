import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/global_variables.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/logo.dart';
import 'package:chrono_alpha/resources/feed_methods.dart';
import 'package:chrono_alpha/widgets/post_card.dart';
import 'package:flutter/material.dart';

import 'package:chrono_alpha/models/post.dart';
//import 'package:chrono_alpha/models/user.dart' as UserModel;

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key, required this.selfUser}) : super(key: key);

  final User selfUser; // me

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const perPage = 20;

  FeedService feed = FeedService();
  bool next = false;
  int page = 1;

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

  _getPosts() async {
    Tuple check = Tuple(contents: [], nextPage: false);
    setState(() {
      _isLoading = true;
    });
    try {
      Tuple response = await feed.updateFeed(page, perPage);
      check = response;
      _posts.addAll(response.contents);
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      _isLoading = false;
      page++;
      next = check.nextPage;
    });
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
              if (index == _posts.length) {
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
                selfUser: widget.selfUser,
              );
            },
            controller: _scrollController,
            separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
            itemCount: _posts.length + (next ? 1 : 0),
            addAutomaticKeepAlives: true,
          ),
        ),
      ),
    );
  }
}
