from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import backref
from sqlalchemy.dialects import postgresql
from sqlalchemy.sql import expression
from sqlalchemy import create_engine
from enum import unique
from datetime import datetime
import string
import random
import os

SHORT_URL_LEN = 5

db = SQLAlchemy()


class User(db.Model):

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.Text(), nullable=False)
    followers_num = db.Column(db.Integer, default=0)
    following_num = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.now())
    updated_at = db.Column(db.DateTime, onupdate=datetime.now())
    description = db.Column(db.Text(), nullable=True)
    tags = db.Column(db.ARRAY(db.Text), nullable=True)
    followers_lst = db.Column(db.ARRAY(db.Integer), default=[-1])
    following_lst = db.Column(db.ARRAY(db.Integer), default=[-1])
    liked_posts = db.Column(db.ARRAY(db.Integer), default=[-1])
    posts = db.relationship('Post', backref='user')

    def __repr__(self):
        return '''User >>> {self.username} \n
                  Id >>> {self.id} \n
                  Email >>> {self.email} \n
                  Description >>> {self.description} \n
                  Tags >>> {self.tags} \n
                  Following >>> {self.following_num} \n
                  Followers >>> {self.followers_num} \n
                  Following list >>> {self.following_lst} \n
                  Followers list >>> {self.followers_lst} \n
                  Password >>> {self.password} \n
                  Created >>> {self.created_at} \n
                  Updated >>> {self.updated} \n'''


class Post(db.Model):

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    url = db.Column(db.Text, unique=True, nullable=False)
    visits = db.Column(db.Integer, default=0)
    views = db.Column(db.Integer, default=0)
    likes = db.Column(db.Integer, default=0)
    short_url = db.Column(db.String(SHORT_URL_LEN), nullable=True)
    body = db.Column(db.Text, nullable=True)
    description = db.Column(db.Text, nullable=True)
    tags = db.Column(postgresql.ARRAY(db.Text), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.now())
    updated_at = db.Column(db.DateTime, onupdate=datetime.now())
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    comments = db.relationship('Comment', backref='post')
    draft = db.Column(
        db.Boolean, server_default=expression.true(), nullable=False)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.short_url = self.generate_short_url()

    def generate_short_url(self):
        characters = string.digits + string.ascii_letters
        picked_chars = ''.join(random.choices(characters, k=SHORT_URL_LEN))
        link = self.query.filter_by(short_url=picked_chars).first()

        if link:
            self.generate_short_url()
        else:
            return picked_chars

    def __repr__(self):
        return '''Post >>> {self.name} \n
                  Author Id >>> {self.user_id} \n
                  Id >>> {self.id} \n
                  Description >>> {self.description} \n
                  Body >>> {self.body} \n
                  Tags >>> {self.tags} \n
                  Url >>> {self.url} \n
                  Short url >>> {self.short_url} \n
                  Visits >>> {self.visits} \n
                  Views >>> {self.views} \n
                  Likes >>> {self.likes} \n
                  Created >>> {self.created_at} \n
                  Updated >>> {self.updated} \n'''


class Comment(db.Model):

    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.Text(), nullable=False)
    user_id = db.Column(db.Integer, nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey('post.id'))


class Advertisement(db.Model):

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), nullable=False)
    description = db.Column(db.Text(), nullable=False)
    url = db.Column(db.Text, nullable=False)
    tags = db.Column(db.ARRAY(db.Text), nullable=False)
    view_price = db.Column(db.Float, nullable=False)
    max_views = db.Column(db.Integer, nullable=False)
    total_price = db.Column(db.Float, nullable=False)
    authorized = db.Column(db.Integer, nullable=False)
    views = db.Column(db.Integer, default=0)
