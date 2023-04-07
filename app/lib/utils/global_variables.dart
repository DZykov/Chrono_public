import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/screens/add_post_screen.dart';
import 'package:chrono_alpha/screens/feed_screen.dart';
import 'package:chrono_alpha/screens/profile_screen.dart';
import 'package:chrono_alpha/screens/search_screen.dart';
import 'package:chrono_alpha/screens/stats_screen.dart';
import 'package:flutter/material.dart';

const webScreenSize = 600;

class Items {
  Items({required this.selfUser});

  User selfUser;

  List<Widget> getItems() {
    return [
      FeedScreen(selfUser: selfUser),
      SearchScreen(selfUser: selfUser),
      const AddPostScreen(),
      StatsScreen(selfUser: selfUser),
      ProfileScreen(selfUser: selfUser),
    ];
  }
}
