from flask import Blueprint, request, jsonify, send_file
from sqlalchemy import asc, desc, or_, and_
from flask_jwt_extended import get_jwt_identity, jwt_required
import validators
import string
from src.constants.status_codes import *
from src.database import Post, User, db
from src.ads import choose_ad
from src.constants.routes import *


NUM_PAGE = 1
PER_PAGE = 20
AD_COEF = 2


feed = Blueprint("feed", __name__, url_prefix="/api/v1/feed")


@feed.get('/refresh')
@jwt_required()
def update_feed():
    page = request.args.get('page', NUM_PAGE, type=int)
    per_page = request.args.get('per_page', PER_PAGE, type=int)
    current_user = get_jwt_identity()

    user = User.query.filter_by(id=current_user).first()
    following = user.following_lst

    query = db.session.query(Post)

    if following is not None:
        for id_following in following:
            query = Post.query.filter_by(user_id=id_following)

    query = query.filter(Post.tags.overlap(user.tags))

    query = query.order_by(desc(Post.created_at))

    posts = query.paginate(page=page, per_page=per_page, error_out=False)
    if posts.total < per_page:
        query = db.session.query(Post)
        query = query.order_by(desc(Post.created_at))
        posts = query.paginate(page=page, per_page=per_page, error_out=False)

    data = []

    for post in posts.items:
        if post.draft == False:
            post.views += 1
            data.append({
                'id': post.id,
                'url': post.url,
                'short_url': post.short_url,
                'user': post.user_id,
                'name': post.name,
                'description': post.description,
                'body': '',
                'tags': post.tags,
                'visits': post.visits,
                'views': post.views,
                'likes': post.likes,
                'created_at': post.created_at,
                'updated_at': post.updated_at,
                'comments': len(post.comments),
                'draft': post.draft,
                'photo_url': header_route+str(post.id)+'.jpeg',
            })

    '''
    if posts.page % AD_COEF == 1:
        ad = choose_ad(user.tags)
        midpoint = len(data) // 2
        data = data[0:midpoint] + [ad] + lst[midpoint:]
    '''

    meta = {
        'page': posts.page,
        'pages': posts.pages,
        'total_count': posts.total,
        'prev_page': posts.prev_num,
        'next_page': posts.next_num,
        'has_prev': posts.has_prev,
        'has_next': posts.has_next,
    }

    db.session.commit()

    return jsonify({
        'data': data,
        'meta': meta
    }), HTTP_200_OK


# order = date, likes, views, visits
@feed.put('/discover/<string:order>')
def discover_feed(order=None):
    tags = request.get_json().get('tags', [])
    name = request.get_json().get('name', '')

    page = request.args.get('page', NUM_PAGE, type=int)
    per_page = request.args.get('per_page', PER_PAGE, type=int)

    posts = Post.query

    if name != '':
        posts = posts.filter(or_(Post.name.like(f'%{name}%'), Post.name.like(name), Post.description.like(
            f'%{name}%')))
    if tags != []:
        posts = posts.filter(Post.tags.overlap(tags))

    if order == "date":
        posts = posts.order_by(desc(Post.created_at))
    elif order == "likes":
        posts = posts.order_by(desc(Post.likes))
    elif order == "views":
        posts = posts.order_by(desc(Post.views))
    elif order == "visits":
        posts = posts.order_by(desc(Post.visits))

    posts = posts.paginate(page=page, per_page=per_page)

    data = []

    for post in posts.items:
        if post.draft == False:
            post.views += 1
            data.append({
                'id': post.id,
                'url': post.url,
                'short_url': post.short_url,
                'user': post.user_id,
                'name': post.name,
                'description': post.description,
                'body': '',
                'tags': post.tags,
                'visits': post.visits,
                'likes': post.likes,
                'views': post.views,
                'created_at': post.created_at,
                'updated_at': post.updated_at,
                'comments': len(post.comments),
                'draft': post.draft,
                'photo_url': header_route+str(post.id)+'.jpeg',
            })

    '''if posts.page % AD_COEF == 1:
        ad = choose_ad(tags)
        midpoint = len(data) // 2
        data = data[0:midpoint] + [ad] + lst[midpoint:]'''

    meta = {
        'page': posts.page,
        'pages': posts.pages,
        'total_count': posts.total,
        'prev_page': posts.prev_num,
        'next_page': posts.next_num,
        'has_prev': posts.has_prev,
        'has_next': posts.has_next,
    }

    db.session.commit()

    return jsonify({
        'data': data,
        'meta': meta
    }), HTTP_200_OK
