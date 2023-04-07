const path = require('path');
const http = require('http');
const https = require('https');
const express = require('express');
const favicon = require('express-favicon');
const cors = require('cors');
const mustacheExpress = require('mustache-express');

const baseUrl = 'API LINK';
const baseUrlAuth = baseUrl + 'v1/auth/';
const getUserUrl = baseUrlAuth + 'user/';

const baseUrlPosts = baseUrl + 'v1/posts/';
const getPostById = baseUrlPosts + 'id/';
const getPostByUrl = baseUrlPosts + 'url/';
const getAllPostsFromUser = baseUrlPosts + 'all/user/';

const baseUrlComments = baseUrl + 'v1/comments/';
const getCommentsByPost = baseUrlComments + 'get/';


const app = express();

app.set('port', (process.env.PORT || 3000));
app.use(express.json());
app.use(express.static(path.join("public")));
app.use(cors());
app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.engine('mustache', mustacheExpress());
app.set('views', 'public/views');
app.set('view engine', 'mustache');


const server = http.createServer(app);

app.use(favicon('/home/demid/Documents/Projects/Chrono/chrono_alpha/website/public/assets/favicon.png'));

app.get('/', function (request, response) {
    response.sendFile("index.html", { root: path.join("public") });
});

app.get('/about', function (request, response) {
    response.sendFile("about.html", { root: path.join("public") });
});

app.get('/:token', (request, response) => {
    const params = request.params

    let user = "";
    let posts = "";

    https.get(getUserUrl + params['token'], resp => {

        resp.on("data", chunk => {
            user += chunk;
        });

        resp.on("end", () => {

            https.get(getAllPostsFromUser + params['token'], resp1 => {

                resp1.on("data", chunk => {
                    posts += chunk;
                });
                resp1.on("end", () => {

                    response.render('profile', { 'user': JSON.parse(user), 'posts': JSON.parse(posts) })
                });

            }).on("error", err => {
                response.sendFile("error.html", { root: path.join("public") });
            });
        });
    }).on("error", err => {
        response.sendFile("error.html", { root: path.join("public") });
    });
});

app.get('/post/:token', (request, response) => {
    const params = request.params

    let post = "";
    let comments = ""

    https.get(getPostById + params['token'], resp => {

        resp.on("data", chunk => {
            post += chunk;
        });

        resp.on("end", () => {

            https.get(getCommentsByPost + params['token'], resp1 => {

                resp1.on("data", chunk => {
                    comments += chunk;
                });

                resp1.on("end", () => {
                    response.render('post', { 'post': JSON.parse(post), 'comments': JSON.parse(comments) })
                });

            }).on("error", err => {
                response.sendFile("error.html", { root: path.join("public") });
            });
        });
    }).on("error", err => {
        response.sendFile("error.html", { root: path.join("public") });
    });
});

app.get('/p/:token', (request, response) => {
    const params = request.params

    let post = "";
    let comments = ""

    https.get(getPostByUrl + params['token'], resp => {

        resp.on("data", chunk => {
            post += chunk;
        });

        resp.on("end", () => {
            https.get(getCommentsByPost + params['token'], resp1 => {

                resp1.on("data", chunk => {
                    comments += chunk;
                });

                resp1.on("end", () => {
                    response.render('post', { 'post': JSON.parse(post), 'comments': JSON.parse(comments) })
                });

            }).on("error", err => {
                response.sendFile("error.html", { root: path.join("public") });
            });
        });
    }).on("error", err => {
        response.sendFile("error.html", { root: path.join("public") });
    });
});

server.listen(process.env.PORT || 3000, () => {
    console.log('Server is running!');
});