import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrono_alpha/models/comment.dart';
import 'package:chrono_alpha/models/tuple.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/comments_methods.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/comment_card.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key, required this.postId, required this.selfUser})
      : super(key: key);

  final int postId;
  final User selfUser; // mer

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  static const perPage = 20;

  final TextEditingController commentEditingController =
      TextEditingController();

  CommentsServices comments = CommentsServices();
  bool next = false;
  int page = 1;

  final List<dynamic> _comments = [];

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
    _getComments();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoading) {
        if (next) {
          _getComments();
        }
      }
    });
  }

  void uploadComment() async {
    String text = commentEditingController.text;
    if (text.isEmpty) {
      showSnackBar(context, "Comment cannot be empty!");
      return;
    }
    try {
      String res = await comments.uploadComment(widget.postId, text);

      if (res == "Some error occurred") {
        if (context.mounted) {
          showSnackBar(context, res);
          return;
        }
      }
      setState(() {
        Comment c = Comment(
            id: int.parse(res),
            userId: widget.selfUser.id,
            postId: widget.postId,
            photoUrl: widget.selfUser.photoUrl,
            username: widget.selfUser.username,
            text: text);
        _comments.insert(0, c);
        commentEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  _getComments() async {
    Tuple check = Tuple(contents: [], nextPage: false);
    setState(() {
      _isLoading = true;
    });
    try {
      Tuple response =
          await comments.getAllPostsCommentById(widget.postId, page, perPage);
      check = response;
      _comments.addAll(response.contents);
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
    const widthMax = 1300.00;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        foregroundColor: activeColor,
        title: const Text(
          'Comments',
          style: TextStyle(
            color: activeColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: Center(
          child: ListView.separated(
            itemBuilder: (context, index) {
              if (index == _comments.length) {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: FittedBox(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return CommentCard(
                comment: _comments[index] as Comment,
                selfId: widget.selfUser.id,
              );
            },
            controller: _scrollController,
            separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
            itemCount: _comments.length + (next ? 1 : 0),
            addAutomaticKeepAlives: true,
            reverse: true,
          ),
        ),
      ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          width: widthMax,
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
          child: Row(
            children: [
              CachedNetworkImage(
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.contain,
                imageUrl: widget.selfUser.photoUrl,
                imageBuilder: (context, imageProvider) {
                  // you can access to imageProvider
                  return CircleAvatar(
                    // or any widget that use imageProvider like (PhotoView)
                    backgroundImage: imageProvider,
                    radius: 40,
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${widget.selfUser.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => uploadComment(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: activeColor),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
