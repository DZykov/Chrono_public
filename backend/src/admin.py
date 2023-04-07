from src.database import Post, User, db, Comment


def delete_post(id):

    post = Post.query.filter_by(id=id).first()

    if not post:
        return "No post with id " + str(id)

    db.session.delete(post)
    db.session.commit()

    return "OK!"


def delete_user(id):

    user = User.query.filter_by(id=id).first()

    if not user:
        return "No user with id " + str(id)

    db.session.delete(user)
    db.session.commit()

    return "OK!"


def delete_comment(id):
    comment = Comment.query.filter_by(id).firs()

    if not comment:
        return "No comment with id " + str(id)

    db.session.delete(comment)
    db.session.commit()

    return "OK!"


def vanish_user(id):

    user = User.query.filter_by(id=id).first()

    if not user:
        return "No user with id " + str(id)

    posts = Post.query.filter_by(user_id=user.id)

    for post in posts:
        delete_post(post.id)

    comments = Comment.query.filter_by(user_id=user.id)

    for comment in comments:
        delete_comment(comment.id)

    db.session.delete(user)
    db.session.commit()

    return "OK!"
