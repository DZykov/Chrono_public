from flask import Flask, jsonify
import os
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from src.auth import auth
from src.posts import posts
from src.feed import feed
from src.comments import comments
from src.database import db
from src.constants.status_codes import *


def create_app(test_config=None):
    app = Flask(__name__, instance_relative_config=True)
    CORS(app)

    if test_config is None:
        app.config.from_mapping(
            SECRET_KEY=os.environ.get("SECRET_KEY"),
            SQLALCHEMY_DATABASE_URI=os.environ.get("SQLALCHEMY_DB_URI"),
            SQLALCHEMY_TRACK_MODIFICATIONS=False,
            JWT_SECRET_KEY=os.environ.get('JWT_SECRET_KEY'),
        )
    else:
        app.config.from_mapping(test_config)

    db.app = app
    db.init_app(app)

    JWTManager(app)

    app.register_blueprint(auth)
    app.register_blueprint(posts)
    app.register_blueprint(feed)
    app.register_blueprint(comments)

    @app.errorhandler(HTTP_404_NOT_FOUND)
    def handle_404(e):
        return jsonify({'error': 'Not Found'}), HTTP_400_BAD_REQUEST

    @app.errorhandler(HTTP_500_INTERNAL_SERVER_ERROR)
    def handle_500(e):
        return jsonify({'error': 'Something went wrong!'}), HTTP_404_NOT_FOUND

    return app
