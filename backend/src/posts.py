from flask import Blueprint, request, jsonify, send_file, send_file
from flask_jwt_extended import get_jwt_identity, jwt_required
from sqlalchemy import desc
import validators
import string
import base64
from src.constants.status_codes import *
from src.database import Post, User, db, Comment
from src.ads import choose_ad
from src.services.do_spaces import *
from src.constants.routes import *


MYURL = ""
URL_CHARS = string.ascii_letters + string.digits + "-_"

NUM_PAGE = 1
PER_PAGE = 25

posts = Blueprint("posts", __name__, url_prefix="/api/v1/posts")


#####################################################
###                                               ###
###                 Post Functions                ###
###                                               ###
#####################################################


@posts.post('/create')
@jwt_required()
def create_post():

    # TODO add 24 hour limit

    current_user = get_jwt_identity()

    name = request.get_json().get('name', '')
    description = request.get_json().get('description', '')
    body = request.get_json().get('body', '')
    tags = request.get_json().get('tags', [])
    draft = request.get_json().get('draft', True)
    url = request.get_json().get('url', '')
    url = MYURL + url

    if not all(ch in URL_CHARS for ch in url):
        return jsonify({
            'error': 'Enter a valid url.'
        }), HTTP_400_BAD_REQUEST
    if Post.query.filter_by(url=url).first() is not None:
        return jsonify({'error': "Url is taken! Please, choose another one."}), HTTP_409_CONFLICT

    post = Post(name=name, description=description, body=body,
                url=url, user_id=current_user, tags=tags, draft=draft)

    db.session.add(post)
    db.session.commit()

    return jsonify({
        'message': "Post created!",
        'post': {
            'id': post.id,
            'url': post.url,
            'short_url': post.short_url,
            'user': post.user_id,
            'name': post.name,
            'description': post.description,
            'body': post.body,
            'tags': post.tags,
            'visits': post.visits,
            'views': post.views,
            'created_at': post.created_at,
            'updated_at': post.updated_at,
            'likes': post.likes,
            'comments': len(post.comments),
            'draft': post.draft,
            'photo_url': header_route+str(post.id)+'.jpeg',
        }
    }), HTTP_201_CREATED


@posts.post('update/imgpost/<int:id>')
@posts.post('update/imgpost/<string:url>')
@jwt_required()
def update_img_post(id=None, url=None):

    current_user = get_jwt_identity()
    post = Post.query.filter_by(user_id=current_user, id=id).first()

    if not post:
        post = Post.query.filter_by(url=url).first()
        if not post:
            post = Post.query.filter_by(short_url=url).first()
            if not post:
                return jsonify({
                    'error': "Post doesn't exists!"
                }), HTTP_404_NOT_FOUND
    '''
    file = request.files['file']
    file.filename = str(current_user) +".jpeg"
    filename = secure_filename(file.filename)
    file.save(os.path.join(save_folder, filename))
    '''
    image_base64 = request.json.get('image', None)
    if image_base64 is None:
        return jsonify({
            'photo_url': "ERROR"
        }), HTTP_400_BAD_REQUEST
    decoded_data = base64.b64decode((image_base64))
    upload_header(decoded_data, str(post.id)+'.jpeg')
    return jsonify({
        'photo_url': header_route+str(post.id)+'.jpeg'
    }), HTTP_201_CREATED


@posts.delete('/delete/<int:id>')
@jwt_required()
def delete_post(id):
    current_user = get_jwt_identity()

    post = Post.query.filter_by(user_id=current_user, id=id).first()

    if not post:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    db.session.delete(post)
    db.session.commit()

    return jsonify({}), HTTP_204_NO_CONTENT


@posts.put('/update/<int:id>')
@posts.patch('/update/<int:id>')
@jwt_required()
def edit_post(id):
    current_user = get_jwt_identity()

    post = Post.query.filter_by(user_id=current_user, id=id).first()

    if not post:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    name = request.get_json().get('name', '')
    description = request.get_json().get('description', '')
    body = request.get_json().get('body', '')
    tags = request.get_json().get('tags', [])
    draft = request.get_json().get('draft', False)

    url = request.get_json().get('url', '')
    url = MYURL + url

    if not all(ch in URL_CHARS for ch in url):
        return jsonify({
            'error': 'Enter a valid url.'
        }), HTTP_400_BAD_REQUEST
    if Post.query.filter_by(url=url).first().url != url and Post.query.filter_by(url=url).first() is not None:
        return jsonify({'error': "Url is taken! Please, choose another one."}), HTTP_409_CONFLICT

    if name != "":
        post.name = name
    post.description = description
    post.body = body
    post.url = url
    post.tags = tags
    post.draft = draft

    db.session.commit()

    return jsonify({
        'message': "Post Updated!",
        'post': {
            'id': post.id,
            'url': post.url,
            'short_url': post.short_url,
            'user': post.user_id,
            'name': post.name,
            'description': post.description,
            'body': post.body,
            'tags': post.tags,
            'visits': post.visits,
            'created_at': post.created_at,
            'updated_at': post.updated_at,
            'likes': post.likes,
            'comments': len(post.comments),
            'draft': post.draft,
            'photo_url': header_route+str(post.id)+'.jpeg',
        }
    }), HTTP_200_OK


@posts.post('like/<int:id>')
@posts.post('like/<string:url>')
@jwt_required()
def like_post(id=None, url=None):
    current_user = get_jwt_identity()
    user = User.query.filter_by(id=current_user).first()

    post = Post.query.filter_by(id=id).first()

    if not post:
        post = Post.query.filter_by(url=url).first()
        if not post:
            post = Post.query.filter_by(short_url=url).first()
            if not post:
                return jsonify({
                    'error': "Post doesn't exists!"
                }), HTTP_404_NOT_FOUND

    if post.id in user.liked_posts:
        return "", HTTP_226_IM_USED

    user.liked_posts = user.liked_posts + [post.id]
    user.tags = user.tags + post.tags

    post.likes += 1
    db.session.add_all([user, post])
    db.session.commit()

    return "", HTTP_202_ACCEPTED


@posts.post('dislike/<int:id>')
@posts.post('dislike/<string:url>')
@jwt_required()
def dislike_post(id=None, url=None):
    post = Post.query.filter_by(id=id).first()
    current_user = get_jwt_identity()
    user = User.query.filter_by(id=current_user).first()

    if not post:
        post = Post.query.filter_by(url=url).first()
        if not post:
            post = Post.query.filter_by(short_url=url).first()
            if not post:
                return jsonify({
                    'error': "Post doesn't exists!"
                }), HTTP_404_NOT_FOUND

    if post.id not in user.liked_posts:
        return "", HTTP_204_NO_CONTENT

    save = [i for i in user.liked_posts if i != post.id]
    user.liked_posts = save

    n_tags = [e for e in user.tags if e not in post.tags]
    user.tags = n_tags

    post.likes -= 1
    db.session.commit()

    return "", HTTP_202_ACCEPTED


#####################################################
###                                               ###
###                 Get Functions                 ###
###                                               ###
#####################################################


# returns everything except body
@posts.get('/all/user/')
@posts.get('/all/user/<string:username>')
@posts.get('/all/user/<int:id>')
def get_all_by_user(id=None, username=None):
    page = request.args.get('page', NUM_PAGE, type=int)
    per_page = request.args.get('per_page', PER_PAGE, type=int)

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (id):
        user = User.query.filter_by(id=id).first()
    if (not user):
        return jsonify({
            'error': "User doesn't exists!"
        }), HTTP_404_NOT_FOUND

    posts = Post.query.filter_by(user_id=user.id).order_by(desc(Post.created_at)).paginate(
        page=page, per_page=per_page)

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
                'created_at': post.created_at,
                'updated_at': post.updated_at,
                'likes': post.likes,
                'comments': len(post.comments),
                'photo_url': header_route+str(post.id)+'.jpeg',
                'draft': post.draft,
            })

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


@posts.get('/private/all/user/')
@jwt_required()
def get_all_by_user_private():
    page = request.args.get('page', NUM_PAGE, type=int)
    per_page = request.args.get('per_page', PER_PAGE, type=int)

    current_user = get_jwt_identity()
    user = User.query.filter_by(id=current_user).first()

    if (not user):
        return jsonify({
            'error': "User doesn't exists!"
        }), HTTP_404_NOT_FOUND

    posts = Post.query.filter_by(user_id=user.id).order_by(desc(Post.created_at)).paginate(
        page=page, per_page=per_page)

    data = []

    for post in posts.items:
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
            'created_at': post.created_at,
            'updated_at': post.updated_at,
            'likes': post.likes,
            'comments': len(post.comments),
            'photo_url': header_route+str(post.id)+'.jpeg',
            'draft': post.draft,
        })

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


@posts.get('/pid/<int:id>')
def get_one_by_id_private(id):
    post = Post.query.filter_by(id=id).first()

    if not post:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    user = User.query.filter_by(id=post.user_id).first()

    db.session.commit()

    # ad = choose_ad(post.tags)
    # midpoint = len(data) // 2
    # data = data[0:midpoint] + [ad] + lst[midpoint:]

    return jsonify({
        'user': post.user_id,
        'username': user.username,
        'avatar': avatar_route+str(user.id) + ".jpeg",
        'id': post.id,
        'url': post.url,
        'short_url': post.short_url,
        'name': post.name,
        'description': post.description,
        'body': post.body,
        'tags': post.tags,
        'visits': post.visits,
        'views': post.views,
        'created_at': post.created_at,
        'updated_at': post.updated_at,
        'likes': post.likes,
        'comments': len(post.comments),
        'draft': post.draft,
        'photo_url': header_route+str(post.id)+'.jpeg',
    }), HTTP_200_OK


@posts.get('/id/<int:id>')
def get_one_by_id(id):
    post = Post.query.filter_by(id=id).first()

    if not post:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    if post.draft == True:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    user = User.query.filter_by(id=post.user_id).first()

    post.views += 1
    post.visits += 1
    db.session.commit()

    # ad = choose_ad(post.tags)
    # midpoint = len(data) // 2
    # data = data[0:midpoint] + [ad] + lst[midpoint:]

    return jsonify({
        'user': post.user_id,
        'username': user.username,
        'avatar': avatar_route+str(user.id) + ".jpeg",
        'id': post.id,
        'url': post.url,
        'short_url': post.short_url,
        'name': post.name,
        'description': post.description,
        'body': post.body,
        'tags': post.tags,
        'visits': post.visits,
        'views': post.views,
        'created_at': post.created_at,
        'updated_at': post.updated_at,
        'likes': post.likes,
        'comments': len(post.comments),
        'draft': post.draft,
        'photo_url': header_route+str(post.id)+'.jpeg',
    }), HTTP_200_OK


@posts.get('/url/<string:url>')
def get_one_by_url(url):
    post = Post.query.filter_by(url=url).first()
    if not post:
        post = Post.query.filter_by(short_url=url).first()
        if not post:
            return jsonify({
                'error': "Post doesn't exists!"
            }), HTTP_404_NOT_FOUND

    if post.draft == True:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    user = User.query.filter_by(id=post.user_id).first()

    post.views += 1
    post.visits += 1
    db.session.commit()

    # ad = choose_ad(post.tags)
    # midpoint = len(data) // 2
    # data = data[0:midpoint] + [ad] + lst[midpoint:]

    return jsonify({
        'user': post.user_id,
        'username': user.username,
        'avatar': avatar_route+str(user.id) + ".jpeg",
        'id': post.id,
        'url': post.url,
        'short_url': post.short_url,
        'name': post.name,
        'description': post.description,
        'body': post.body,
        'tags': post.tags,
        'visits': post.visits,
        'views': post.views,
        'created_at': post.created_at,
        'updated_at': post.updated_at,
        'likes': post.likes,
        'comments': len(post.comments),
        'draft': post.draft,
        'photo_url': header_route+str(post.id)+'.jpeg',
    }), HTTP_200_OK


@posts.get('get/user/likes/<int:id>')
@posts.get('get/user/likes/<string:url>')
@jwt_required()
def get_user_liked_post(id=None):
    current_user = get_jwt_identity()
    post = Post.query.filter_by(id=id).first()

    if not post:
        post = Post.query.filter_by(url=url).first()
        if not post:
            post = Post.query.filter_by(short_url=url).first()
            if not post:
                return jsonify({
                    'error': "Post doesn't exists!"
                }), HTTP_404_NOT_FOUND

    if post.draft == True:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    user = User.query.filter_by(id=current_user).first()
    if user.liked_posts is None:
        return "", HTTP_404_NOT_FOUND

    if post.id in user.liked_posts:
        return "", HTTP_200_OK

    return "", HTTP_404_NOT_FOUND


@posts.get('get/likes/<int:id>')
@posts.get('get/likes/<string:url>')
def get_like_post(id=None):
    post = Post.query.filter_by(id=id).first()

    if not post:
        post = Post.query.filter_by(url=url).first()
        if not post:
            post = Post.query.filter_by(short_url=url).first()
            if not post:
                return jsonify({
                    'error': "Post doesn't exists!"
                }), HTTP_404_NOT_FOUND

    if post.draft == True:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    return jsonify({
        'likes': post.likes
    }), HTTP_200_OK


@posts.get('get/tags/<int:id>')
@posts.get('get/tags/<string:url>')
def get_tags_post(id=None):
    post = Post.query.filter_by(id=id).first()

    if not post:
        post = Post.query.filter_by(url=url).first()
        if not post:
            post = Post.query.filter_by(short_url=url).first()
            if not post:
                return jsonify({
                    'error': "Post doesn't exists!"
                }), HTTP_404_NOT_FOUND

    if post.draft == True:
        return jsonify({
            'error': "Post doesn't exists!"
        }), HTTP_404_NOT_FOUND

    return jsonify({
        'tags': post.tags
    }), HTTP_200_OK


@posts.post('check/tags')
def check_tags():
    tags = request.get_json().get('tags', [])
    posts_num = Post.query.filter_by(tags=tags).count()
    return jsonify({
        'num': posts_num
    }), HTTP_200_OK
