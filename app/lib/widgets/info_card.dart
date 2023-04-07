import 'package:chrono_alpha/models/post.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/resources/posts_methods.dart';
import 'package:chrono_alpha/screens/comments_screen.dart';
import 'package:chrono_alpha/screens/edit_post_screen.dart';
import 'package:chrono_alpha/screens/post_screen.dart';
import 'package:chrono_alpha/screens/profile_screen.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/global_variables.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/like_animation.dart';
import 'package:flutter/material.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InfoCard extends StatefulWidget {
  const InfoCard({
    Key? key,
    required this.snap,
    required this.selfUser,
  }) : super(key: key);

  final User selfUser; // me
  final Post snap;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard>
    with AutomaticKeepAliveClientMixin {
  AuthService auth = AuthService();
  bool deleted = false;
  bool isLikeAnimating = false;
  bool liked = false;
  PostsService posts = PostsService();

  @override
  void initState() {
    super.initState();
    checkPostlikedByUser();
  }

  @override
  bool get wantKeepAlive => true;

  deletePost(int postId) async {
    try {
      await posts.deletePost(postId);
      setState(() {
        deleted = true;
      });
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
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    const widthMax = 900.00;
    if (deleted) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Container(
        // boundary needed for web
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.5,
            color:
                width > webScreenSize ? secondaryColor : mobileBackgroundColor,
          ),
          color: mobileBackgroundColor,
        ),
        constraints: const BoxConstraints(maxWidth: widthMax),
        padding: const EdgeInsets.all(
          10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    imageUrl: widget.selfUser.photoUrl,
                    imageBuilder: (context, imageProvider) {
                      // you can access to imageProvider
                      return CircleAvatar(
                        // or any widget that use imageProvider like (PhotoView)
                        backgroundImage: imageProvider,
                        radius: 16,
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
                                    selfUser: widget.selfUser,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              widget.selfUser.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  widget.snap.user == widget.selfUser.id
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shrinkWrap: true,
                                      children: ['Delete', 'Edit']
                                          .map(
                                            (e) => InkWell(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  if (e == 'Delete') {
                                                    deletePost(
                                                      widget.snap.id,
                                                    );
                                                  } else if (e == 'Edit') {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditPostScreen(
                                                          postId:
                                                              widget.snap.id,
                                                        ),
                                                      ),
                                                    );
                                                  }
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
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: widthMax,
                    child: CachedNetworkImage(
                      imageUrl: widget.snap.photoUrl,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostScreen(
                            snap: widget.snap,
                            selfUser: widget.selfUser,
                            owner: widget.selfUser,
                          ),
                        ),
                      ),
                    ),
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
                        onPressed: () => likeOrDisPostById(widget.snap.id),
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.snap.visits} visits',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.snap.views} views',
                          style: Theme.of(context).textTheme.bodyMedium,
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
                  Text(
                    'Draft: ${widget.snap.draft}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Tags: ${widget.snap.tags.toString().replaceAll('[', '').replaceAll(']', '')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SelectableText(
                    'URL: chrono.pw/p/${widget.snap.url}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SelectableText(
                    'Short URL: chrono.pw/p/${widget.snap.shortUrl}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Created at: ${widget.snap.createdAt}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Updated at: ${widget.snap.updatedAt}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Container(
                    width: widthMax,
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: '${widget.snap.name}\n',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '\n${widget.snap.description}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
