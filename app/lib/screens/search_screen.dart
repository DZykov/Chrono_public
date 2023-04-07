import 'package:chrono_alpha/models/post.dart';
import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/feed_methods.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:chrono_alpha/utils/colors.dart';
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:chrono_alpha/screens/profile_screen.dart';
//import 'package:chrono_alpha/utils/global_variables.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, required this.selfUser}) : super(key: key);

  final User selfUser;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const perPage = 20;

  final List<String> feedMenu = <String>[
    "date",
    "likes",
    "views",
    "visits",
  ];

  final TextEditingController searchController = TextEditingController();

  FeedService feed = FeedService();
  bool next = false;
  int page = 1;
  String selectedOrder = "date";
  List<String> tags = [];
  String text = '';

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

  _setOrder(String e) async {
    if (!feedMenu.contains(e)) {
      return;
    }
    selectedOrder = e;
  }

  _getPosts() async {
    Tuple check = Tuple(contents: [], nextPage: false);
    setState(() {
      _isLoading = true;
    });
    try {
      Tuple response =
          await feed.discoverFeed(page, perPage, selectedOrder, tags, text);
      check = response;
      setState(() {
        _posts.addAll(response.contents);
      });
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

  void _popupDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shrinkWrap: true,
                children: feedMenu
                    .map(
                      (e) => InkWell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Text(
                              'By $e',
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedOrder == e
                                    ? activeColor
                                    : Colors.black,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            _setOrder(e);
                          }),
                    )
                    .toList()),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: InkWell(
            onTap: () {
              _popupDialog(context);
            },
            borderRadius: BorderRadius.circular(65),
            hoverColor: const Color.fromARGB(255, 233, 230, 230),
            child: const Icon(
              Icons.sort,
              color: activeColor,
            ),
          ),
        ),
        title: Form(
          child: TextFormField(
            controller: searchController,
            cursorColor: activeColor,
            decoration: const InputDecoration(
              focusColor: activeColor,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: activeColor),
              ),
              labelText: 'Use # for tags or just type a name of an article',
              labelStyle: TextStyle(color: activeColor),
            ),
            onFieldSubmitted: (String submittedText) {
              List<String> submittedTags = [];
              RegExp exp = RegExp(r"\B#\w+");
              exp.allMatches(submittedText).forEach((match) {
                submittedTags.add(match.group(0) ?? "");
              });
              for (String tag in submittedTags) {
                submittedText = submittedText.replaceAll(tag, '');
                tags.add(tag.replaceAll('#', ''));
              }
              setState(() {
                tags = tags;
                text = submittedText.trim();
                page = 1;
                _posts.clear();
                searchController.text;
              });
              _getPosts();
            },
          ),
        ),
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
