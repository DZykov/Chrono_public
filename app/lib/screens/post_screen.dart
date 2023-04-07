import 'package:chrono_alpha/models/post.dart';
import 'package:chrono_alpha/resources/posts_methods.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/screens/comments_screen.dart';
import 'package:chrono_alpha/screens/profile_screen.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/global_variables.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/like_animation.dart';
import 'package:flutter/material.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({
    Key? key,
    required this.snap,
    required this.owner,
    required this.selfUser,
  }) : super(key: key);

  final User owner;
  final User selfUser; // me
  final Post snap;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final QuillEditorController controller = QuillEditorController();

  AuthService auth = AuthService();
  bool isLikeAnimating = false;
  bool liked = false;
  PostsService posts = PostsService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setPostBody();
    checkPostlikedByUser();
  }

  setPostBody() async {
    setState(() {
      _isLoading = true;
    });
    Post postB = await posts.getPostById(widget.snap.id);
    await controller.setText(postB.body);
    setState(() {
      widget.snap.body = postB.body;
    });
  }

  deletePost(int postId) async {
    try {
      await posts.deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  likeOrDisPostById(int postId) async {
    if (liked) {
      await dislikePost(postId);
    } else {
      await likePost(postId);
    }
  }

  likePost(int postId) async {
    try {
      await posts.likePostById(postId);
      setState(() {
        liked = true;
        widget.snap.likes++;
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  dislikePost(int postId) async {
    try {
      await posts.dislikePostById(postId);
      setState(() {
        liked = false;
        widget.snap.likes--;
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  checkPostlikedByUser() async {
    try {
      bool liked1 = await posts.likedPostByUser(widget.snap.id);
      setState(() {
        liked = liked1;
      });
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const widthMax = 1300.00;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              foregroundColor: activeColor,
              title: const Text(
                'Post',
                style: TextStyle(
                  color: activeColor,
                ),
              ),
              centerTitle: false,
            ),
            body: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: width > webScreenSize
                          ? secondaryColor
                          : mobileBackgroundColor,
                    ),
                    color: mobileBackgroundColor,
                  ),
                  constraints: const BoxConstraints(maxWidth: widthMax),
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      // HEADER SECTION OF THE POST
                      Container(
                        constraints: const BoxConstraints(maxWidth: widthMax),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ).copyWith(right: 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CachedNetworkImage(
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.contain,
                              imageUrl: widget.owner.photoUrl,
                              imageBuilder: (context, imageProvider) {
                                // you can access to imageProvider
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          selfUser: widget.owner,
                                        ),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    // or any widget that use imageProvider like (PhotoView)
                                    backgroundImage: imageProvider,
                                    radius: 16,
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ProfileScreen(
                                              selfUser: widget.owner,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        widget.owner.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            widget.selfUser.id == widget.owner.id
                                ? IconButton(
                                    onPressed: () {
                                      showDialog(
                                        useRootNavigator: false,
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            child: ListView(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shrinkWrap: true,
                                                children: [
                                                  'Delete',
                                                ]
                                                    .map(
                                                      (e) => InkWell(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        12,
                                                                    horizontal:
                                                                        16),
                                                            child: Text(e),
                                                          ),
                                                          onTap: () {
                                                            deletePost(
                                                              widget.snap.id,
                                                            );
                                                            // remove the dialog box
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }),
                                                    )
                                                    .toList()),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.more_vert),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      // IMAGE SECTION OF THE POST
                      GestureDetector(
                        onDoubleTap: () {
                          likeOrDisPostById(widget.snap.id);
                          setState(() {
                            isLikeAnimating = true;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.loose,
                          children: [
                            Column(children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: primaryColor),
                                  children: [
                                    TextSpan(
                                      text: '${widget.snap.name}\n',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                width: widthMax,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.snap.photoUrl,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ]),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isLikeAnimating ? 1 : 0,
                              child: LikeAnimation(
                                isAnimating: isLikeAnimating,
                                duration: const Duration(
                                  milliseconds: 400,
                                ),
                                onEnd: () {
                                  setState(() {
                                    isLikeAnimating = false;
                                  });
                                },
                                child: const Icon(
                                  Icons.favorite,
                                  color: activeColor,
                                  size: 100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // LIKE, COMMENT SECTION OF THE POST
                      Container(
                        constraints: const BoxConstraints(maxWidth: widthMax),
                        child: IntrinsicHeight(
                          child: Row(
                            children: <Widget>[
                              LikeAnimation(
                                isAnimating: liked,
                                smallLike: true,
                                child: IconButton(
                                  icon: liked
                                      ? const Icon(
                                          Icons.favorite,
                                          color: activeColor,
                                        )
                                      : const Icon(
                                          Icons.favorite_border,
                                        ),
                                  onPressed: () =>
                                      likeOrDisPostById(widget.snap.id),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.comment_outlined,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CommentsScreen(
                                      selfUser: widget.selfUser,
                                      postId: widget.snap.id,
                                    ),
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                  width: 2,
                                  thickness: 1,
                                  color: Colors.black,
                                  indent: 10,
                                  endIndent: 10),
                              DefaultTextStyle(
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontWeight: FontWeight.w800),
                                child: Row(children: [
                                  Text(
                                    '\t${widget.snap.likes} likes',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${widget.snap.visits} visits',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${widget.snap.views} views',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //DESCRIPTION AND NUMBER OF COMMENTS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: QuillHtmlEditor(
                                    hintText: "",
                                    text: widget.snap.body,
                                    controller: controller,
                                    isEnabled: false,
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    hintTextPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'View all ${widget.snap.comments} comments',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CommentsScreen(
                                    selfUser: widget.selfUser,
                                    postId: widget.snap.id,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                widget.snap.createdAt,
                                style: const TextStyle(
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
