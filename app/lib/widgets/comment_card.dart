import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrono_alpha/models/comment.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/comments_methods.dart';
import 'package:chrono_alpha/screens/profile_screen.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({Key? key, required this.comment, required this.selfId})
      : super(key: key);

  final Comment comment;
  final int selfId;

  @override
  State<StatefulWidget> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard>
    with AutomaticKeepAliveClientMixin {
  CommentsServices comments = CommentsServices();
  bool deleted = false;

  // ignore: unnecessary_overrides
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  deleteComment() async {
    try {
      await comments.deleteComment(widget.comment.id);
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (deleted) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    selfUser: User(
                        username: "-1",
                        id: widget.comment.userId,
                        photoUrl: "-1",
                        description: "-1",
                        followersNum: -1,
                        followingNum: -1),
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.comment.photoUrl,
              ),
              radius: 18,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            selfUser: User(
                                username: "-1",
                                id: widget.comment.userId,
                                photoUrl: "-1",
                                description: "-1",
                                followersNum: -1,
                                followingNum: -1),
                          ),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.comment.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.comment.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          widget.selfId == widget.comment.userId
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      useRootNavigator: false,
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              children: [
                                'Delete',
                              ]
                                  .map(
                                    (e) => InkWell(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(e),
                                        ),
                                        onTap: () {
                                          deleteComment();
                                          // remove the dialog box
                                          Navigator.of(context).pop();
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
    );
  }
}
