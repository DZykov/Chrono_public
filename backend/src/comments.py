from flask import Blueprint, request, jsonify, send_file
from sqlalchemy import desc
from flask_jwt_extended import get_jwt_identity, jwt_required
import validators
import string
from src.constants.status_codes import *
from src.database import Comment, Post, User, db
from src.ads import choose_ad
from src.constants.routes import *


NUM_PAGE = 1
PER_PAGE = 20


comments = Blueprint("comments", __name__, url_prefix="/api/v1/comments")

#####################################################
###                                               ###
###                 Post Functions                ###
###                                               ###
#####################################################


@comments.post('/create')
@jwt_required()
def create_comment():
    user_id = get_jwt_identity()
    text = request.get_json().get('text', '')
    post_id = request.get_json().get('post_id', '')
    comment = Comment(post_id=post_id, user_id=user_id, text=text)

    user = User.query.filter_by(id=user_id).first()

    db.session.add(comment)
    db.session.commit()

    return jsonify({
        'message': "Comment created!",
        'comment': {
            'id': comment.id,
            'text': comment.text,
            'user_id': comment.user_id,
            'username': user.username,
            'photo_url': avatar_route+str(user.id) + ".jpeg",
            'post_id': comment.post_id
        }
    }), HTTP_201_CREATED


@comments.delete('/delete/<int:id>')
@jwt_required()
def delete_comment(id):
    current_user = get_jwt_identity()
    comment = Comment.query.filter_by(user_id=current_user, id=id).first()

    if not comment:
        return jsonify({
            'error': "Comment doesn't exists!"
        }), HTTP_404_NOT_FOUND

    db.session.delete(comment)
    db.session.commit()

    return jsonify({}), HTTP_204_NO_CONTENT

#####################################################
###                                               ###
###                  Get Functions                ###
###                                               ###
#####################################################


@comments.get('/get/<string:post_url>')
@comments.get('/get/<int:post_id>')
def get_comments(post_id=None, post_url=None):
    page = request.args.get('page', NUM_PAGE, type=int)
    per_page = request.args.get('per_page', PER_PAGE, type=int)
    post = Post.query.filter_by(id=post_id).first()
    if not post:
        post = Post.query.filter_by(short_url=post_url).first()
        if not post:
            post = Post.query.filter_by(url=post_url).first()
            if not post:
                return jsonify({
                    'error': "Post doesn't exists!"
                }), HTTP_404_NOT_FOUND

    comments = Comment.query.filter_by(post_id=post.id).order_by(Comment.id.desc()).paginate(
        page=page, per_page=per_page, error_out=False)

    data = []

    for comment in comments.items:
        user = User.query.filter_by(id=comment.user_id).first()
        data.append({
            'id': comment.id,
            'user_id': comment.user_id,
            'username': user.username,
            'photo_url': avatar_route+str(user.id) + ".jpeg",
            'post_id': comment.post_id,
            'text': comment.text
        })

    meta = {
        'page': comments.page,
        'pages': comments.pages,
        'total_count': comments.total,
        'prev_page': comments.prev_num,
        'next_page': comments.next_num,
        'has_prev': comments.has_prev,
        'has_next': comments.has_next,
    }

    db.session.commit()
    return jsonify({
        'data': data,
        'meta': meta
    }), HTTP_200_OK
