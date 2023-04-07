# Chrono: blogging platform
    
This is a fully scaled project of a blogging platform in production.

## Index
   - [Demo](#Demo "Goto Demo")
   - [Great Idea](#Great-Idea "Goto great Idea")
   - [Features](#Features "Goto Features")
   - [Repo Structure](#Repo-Structure "Goto Repo Structure")
   - [Platform Architecture](#Platform-Architecture "Goto Platform Architecture")
   - [To-Do and Issues](#To-Do-and-Issues "Goto ToDo-and-Issues")

## Demo

[Web App](app.chrono.pw)

[Website with blogs](chrono.pw) 

[Example of a profile](chrono.pw/demid_zykov)

[Example of a post](https://chrono.pw/p/introducing_chrono)

## Great Idea

The idea was to create a blogging and publishing platform with a word processor. Moreover, the main goal was to develop an app that allows easily to make an article/blog and publish it not only within the platform but internet. Thus, each registered user has an SEO-friendly profile page; moreover, each published article/blog is SEO-friendly. Each article/blog is technically searchable. Additionally, all generated pages and the web app are responsive. 

## Features

### Web App
   - Likes
   - Comments
   - Tags
   - Search functionality
   - General statistics about posts/articles
   - Posts/articles could be editted or saved as draft
   - Word processor supports all basic manipulations with text: bold, italic, underline, cross, font sizes, text alignment, tables, lists, headers and quatations.
   - Word processor supports inline pictures and code blocks.
   - Supports multiple platforms: web, android, ios, etc.
   - Fully responsive

### Website
   - All pages are SEO friendly
   - Supports all devices and screens
   - Fully responsive

## Repo Structure

app - contains all files for the web app. Web app is written in dart with Flutte flamework.

backend - contains all files for the API server. API server is written in Python with Flask framework. Additionaly, this folder has small admin CLI tool.

website - contains all files for the server side rendering application. SSR is written js with Node.js framework and logic-less template syntax Mustache.

## Platform Architecture



## To-Do and Issues

### Web App
- [ ] Refractor the code for the web app
- [ ] Fix rendering bugs in the web app
    - [ ] Firefox will not render posts with large embeded images.
    - [ ] Fix "Create" and "Edit" tabs for mobiles: on some devices keyboard overlays the input field.

### Website
- [ ] Add normal index and about pages
- [ ] Reconfigure SEO
- [ ] Make the website more pleasant

### API
- [ ] Add documentation for public api
- [ ] Make admin panel
- [ ] Optimize search functionality
- [ ] Add functionality to search users (right now, only posts are searchable)

