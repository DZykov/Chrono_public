from flask import Blueprint, request, jsonify, send_file, flash
from werkzeug.security import check_password_hash, generate_password_hash
from werkzeug.utils import secure_filename
from flask_jwt_extended import get_jwt_identity, jwt_required, create_access_token, create_refresh_token
import validators
import base64
from src.constants.status_codes import *
from src.constants.routes import *
from src.database import User, db
import os
from src.services.do_spaces import *

auth = Blueprint("auth", __name__, url_prefix="/api/v1/auth/")


#####################################################
###                                               ###
###                 Post Functions                ###
###                                               ###
#####################################################


@auth.post('/register')
def register():
    username = request.json['username']
    email = request.json['email']
    password = request.json['password']

    if len(password) < 6:
        return jsonify({'error': 'Password has to be at least 6 characters!'}), HTTP_400_BAD_REQUEST

    if len(username) < 4:
        return jsonify({'error': 'Usename has to be at least 5 characters!'}), HTTP_400_BAD_REQUEST

    if not username.isidentifier() or " " in username:
        return jsonify({'error': 'Usename has to be alphanumeric and with no spaces!'}), HTTP_400_BAD_REQUEST

    if not validators.email(email):
        return jsonify({'error': 'Email is not valid!'}), HTTP_400_BAD_REQUEST

    if User.query.filter_by(email=email).first() is not None:
        return jsonify({'error': "Email is taken!"}), HTTP_409_CONFLICT

    if User.query.filter_by(username=username).first() is not None:
        return jsonify({'error': "Username is taken!"}), HTTP_409_CONFLICT

    pwd_hash = generate_password_hash(password)

    user = User(username=username, password=pwd_hash, email=email)

    if user.description == None:
        user.description = ''
    if user.tags == None:
        user.tags = ['']
    if user.followers_lst == None:
        user.followers_lst = []
    if user.following_lst == None:
        user.following_lst = []
    if user.liked_posts == None:
        user.liked_posts = []

    db.session.add(user)
    db.session.commit()

    access = create_access_token(identity=user.id)
    refresh = create_refresh_token(identity=user.id)

    return jsonify({
        'username': username,
        'email': email,
        'access': access,
        'refresh': refresh
    }), HTTP_201_CREATED


@auth.post('login')
def login():
    username = request.json.get('username', '')
    password = request.json.get('password', '')

    user = User.query.filter_by(username=username).first()
    if (user):
        is_pass_correct = check_password_hash(user.password, password)
        if is_pass_correct:
            if user.description == None:
                user.description = ''
            if user.tags == None:
                user.tags = ['']
            if user.followers_lst == None:
                user.followers_lst = [0]
            if user.following_lst == None:
                user.following_lst = [0]
            if user.liked_posts == None:
                user.liked_posts = [0]
            db.session.commit()
            access = create_access_token(identity=user.id)
            refresh = create_refresh_token(identity=user.id)
            return jsonify({
                'access': access,
                'refresh': refresh,
                'username': user.username,
                'email': user.email
            }), HTTP_200_OK

    return {'error': 'Wrong credentials!'}, HTTP_401_UNAUTHORIZED


@auth.post('update/avatar')
@jwt_required()
def update_avatar():
    current_user = get_jwt_identity()
    """ file = request.files.get('file', None)
    if file is None:
        return jsonify({
            'photo_url': "ERROR"
        }), HTTP_400_BAD_REQUEST
    file.filename = str(current_user) +".jpeg"
    filename = secure_filename(file.filename)
    file.save(os.path.join(save_folder, filename)) """
    image_base64 = request.json.get('image', None)
    if image_base64 is None:
        return jsonify({
            'photo_url': "ERROR"
        }), HTTP_400_BAD_REQUEST
    decoded_data = base64.b64decode((image_base64))
    upload_avatar(decoded_data, str(current_user) + ".jpeg")
    return jsonify({
        'photo_url': avatar_route+str(current_user) + ".jpeg"
    }), HTTP_201_CREATED


@auth.post('token/refresh')
@jwt_required(refresh=True)
def refresh_token():
    identity = get_jwt_identity()
    access_token = create_access_token(identity=identity)
    return jsonify({
        'access': access_token
    }), HTTP_200_OK


@auth.post('update/description')
@jwt_required()
def update_description():
    current_user = get_jwt_identity()
    user = User.query.filter_by(id=current_user).first()

    description = request.json.get('description', '')
    user.description = description

    db.session.commit()

    return jsonify({
        'description': user.description
    }), HTTP_201_CREATED


@auth.post('update/tags')
@jwt_required()
def update_tags():
    current_user = get_jwt_identity()
    user = User.query.filter_by(id=current_user).first()

    tags = request.json.get('tags', '')
    user.tags = tags

    db.session.commit()

    return jsonify({
        'tags': user.tags
    }), HTTP_201_CREATED


@auth.post('follow/<string:username>')
@auth.post('follow/<int:id>')
@auth.post('follow')
@jwt_required()
def follow(id=None, username=None):

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (id):
        user = User.query.filter_by(id=id).first()
    if (not user):
        return jsonify({
            'error': "User doesn't exists!"
        }), HTTP_404_NOT_FOUND

    current_user_id = get_jwt_identity()
    current_user = User.query.filter_by(id=current_user_id).first()

    if user.id in current_user.following_lst:
        return jsonify({
            'follower': current_user.username,
            'following': user.username
        }), HTTP_226_IM_USED

    current_user.following_lst = current_user.following_lst + [user.id]
    user.followers_lst = user.followers_lst + [current_user.id]

    current_user.following_num = len(current_user.following_lst)
    user.followers_num = len(user.followers_lst)

    db.session.commit()

    return jsonify({
        'follower': current_user.username,
        'following': user.username
    }), HTTP_200_OK


@auth.post('unfollow/<string:username>')
@auth.post('unfollow/<int:id>')
@auth.post('unfollow')
@jwt_required()
def unfollow(id=None, username=None):

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (id):
        user = User.query.filter_by(id=id).first()
    if (not user):
        return jsonify({
            'error': "User doesn't exists!"
        }), HTTP_404_NOT_FOUND

    current_user_id = get_jwt_identity()
    current_user = User.query.filter_by(id=current_user_id).first()

    if user.id not in current_user.following_lst:
        return jsonify({
            'follower': current_user.username,
            'following': user.username
        }), HTTP_204_NO_CONTENT

    try:
        save = [i for i in current_user.following_lst if i != user.id]
        current_user.following_lst = save
    except:
        return jsonify({
            'error': "You don't follow this user!"
        }), HTTP_404_NOT_FOUND
    try:
        save = [i for i in user.followers_lst if i != current_user.id]
        user.followers_lst = save
    except:
        return jsonify({
            'error': "You don't follow this user!"
        }), HTTP_404_NOT_FOUND

    current_user.following_num = len(current_user.following_lst)
    user.followers_num = len(user.followers_lst)

    db.session.commit()

    return jsonify({
        'unfollower': current_user.username,
        'unfollowing': user.username
    }), HTTP_200_OK


#####################################################
###                                               ###
###                 Get Functions                 ###
###                                               ###
#####################################################


@auth.get('/me')
@jwt_required()
def get_me():
    user_id = get_jwt_identity()
    user = User.query.filter_by(id=user_id).first()
    return jsonify({
        'username': user.username,
        'id': user.id,
        'description': user.description,
        'followers_num': user.followers_num,
        'following_num': user.following_num,
        'tags': user.tags,
        'photo_url': avatar_route+str(user.id) + ".jpeg",
    }), HTTP_200_OK


@auth.get('user')
@auth.get('user/<string:username>')
@auth.get('user/<int:id>')
def get_user(id=None, username=None):

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (id):
        user = User.query.filter_by(id=id).first()
    if (not user):
        return jsonify({
            'error': "User doesn't exists!"
        }), HTTP_404_NOT_FOUND

    return jsonify({
        'username': user.username,
        'id': user.id,
        'description': user.description,
        'followers_num': user.followers_num,
        'following_num': user.following_num,
        'photo_url': avatar_route+str(user.id)+'.jpeg',
    }), HTTP_200_OK


@auth.get('check/follow/<string:username>')
@auth.get('check/follow/<int:id>')
@auth.get('check/follow')
@jwt_required()
def check_follow(id=None, username=None):

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (id):
        user = User.query.filter_by(id=id).first()
    if (not user):
        return jsonify({
            'error': "User doesn't exists!"
        }), HTTP_404_NOT_FOUND

    current_user_id = get_jwt_identity()
    current_user = User.query.filter_by(id=current_user_id).first()

    if user.id in current_user.following_lst:
        return "", HTTP_200_OK

    return "", HTTP_404_NOT_FOUND


@auth.get('get/tags/<string:username>')
@auth.get('get/tags/<int:id>')
@auth.get('get/tags')
def get_tags(id=None, username=None):
    username = request.json.get('username', '')
    _id = request.json.get('id', '')

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (_id):
        user = User.query.filter_by(id=_id).first()
    if (not user):
        user = User.query.filter_by(id=id).first()
        if (not user):
            user = User.query.filter_by(username=username).first()
            if (not user):
                return jsonify({
                    'error': "User doesn't exists!"
                }), HTTP_404_NOT_FOUND

    return jsonify({
        'tags': user.tags
    }), HTTP_200_OK


@auth.get('get/followers/count/<string:username>')
@auth.get('get/followers/count/<int:id>')
@auth.get('get/followers/count')
def get_followers_count(id=None, username=None):
    username = request.json.get('username', '')
    _id = request.json.get('id', '')

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (_id):
        user = User.query.filter_by(id=_id).first()
    if (not user):
        user = User.query.filter_by(id=id).first()
        if (not user):
            user = User.query.filter_by(username=username).first()
            if (not user):
                return jsonify({
                    'error': "User doesn't exists!"
                }), HTTP_404_NOT_FOUND

    return jsonify({
        'followers_count': user.followers_num
    }), HTTP_200_OK


@auth.get('get/following/count/<string:username>')
@auth.get('get/following/count/<int:id>')
@auth.get('get/following/count')
def get_following_count(id=None, username=None):
    username = request.json.get('username', '')
    _id = request.json.get('id', '')

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (_id):
        user = User.query.filter_by(id=_id).first()
    if (not user):
        user = User.query.filter_by(id=id).first()
        if (not user):
            user = User.query.filter_by(username=username).first()
            if (not user):
                return jsonify({
                    'error': "User doesn't exists!"
                }), HTTP_404_NOT_FOUND

    return jsonify({
        'following_count': user.following_num
    }), HTTP_200_OK


@auth.get('get/followers/<string:username>')
@auth.get('get/followers/<int:id>')
@auth.get('get/followers')
def get_followers(id=None, username=None):
    username = request.json.get('username', '')
    _id = request.json.get('id', '')

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (_id):
        user = User.query.filter_by(id=_id).first()
    if (not user):
        user = User.query.filter_by(id=id).first()
        if (not user):
            user = User.query.filter_by(username=username).first()
            if (not user):
                return jsonify({
                    'error': "User doesn't exists!"
                }), HTTP_404_NOT_FOUND

    return jsonify({
        'followers': user.followers_lst
    }), HTTP_200_OK


@auth.get('get/following/<string:username>')
@auth.get('get/following/<int:id>')
@auth.get('get/following')
def get_following(id=None, username=None):
    username = request.json.get('username', '')
    _id = request.json.get('id', '')

    if (username):
        user = User.query.filter_by(username=username).first()
    elif (_id):
        user = User.query.filter_by(id=_id).first()
    if (not user):
        user = User.query.filter_by(id=id).first()
        if (not user):
            user = User.query.filter_by(username=username).first()
            if (not user):
                return jsonify({
                    'error': "User doesn't exists!"
                }), HTTP_404_NOT_FOUND

    return jsonify({
        'following': user.following_lst
    }), HTTP_200_OK


#####################################################
###                                               ###
###             General Functions                 ###
###                                               ###
#####################################################
