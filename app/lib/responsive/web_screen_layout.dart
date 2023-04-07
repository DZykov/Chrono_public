import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrono_alpha/constants/other_constants.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/global_variables.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  AuthService auth = AuthService();
  late Items items;
  late PageController pageController;
  String urlImage = EmptyConstants.noAvatar;

  bool _isLoading = false;
  int _page = 0;

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserAsync();
    pageController = PageController();
  }

  Future<void> getUserAsync() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User userN = await auth.getMineDetails();
      if (userN.photoUrl.isNotEmpty) {
        setState(() {
          urlImage = userN.photoUrl;
          items = Items(selfUser: userN);
        });
      }
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Logo(),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {
              navigationTapped(0);
            },
            borderRadius: BorderRadius.circular(65),
            hoverColor: const Color.fromARGB(255, 233, 230, 230),
            child: Icon(
              Icons.home,
              color: _page == 0 ? activeColor : secondaryColor,
            ),
          ),
          Container(
            width: 10,
          ),
          InkWell(
            onTap: () {
              navigationTapped(1);
            },
            borderRadius: BorderRadius.circular(65),
            hoverColor: const Color.fromARGB(255, 233, 230, 230),
            child: Icon(
              Icons.search,
              color: _page == 1 ? activeColor : secondaryColor,
            ),
          ),
          Container(
            width: 10,
          ),
          InkWell(
            onTap: () {
              navigationTapped(2);
            },
            borderRadius: BorderRadius.circular(65),
            hoverColor: const Color.fromARGB(255, 233, 230, 230),
            child: Icon(
              Icons.add,
              color: _page == 2 ? activeColor : secondaryColor,
            ),
          ),
          Container(
            width: 10,
          ),
          InkWell(
            onTap: () {
              navigationTapped(3);
            },
            borderRadius: BorderRadius.circular(65),
            hoverColor: const Color.fromARGB(255, 233, 230, 230),
            child: Icon(
              Icons.info,
              color: _page == 3 ? activeColor : secondaryColor,
            ),
          ),
          Container(
            width: 10,
          ),
          InkWell(
            onTap: () {
              navigationTapped(4);
            },
            borderRadius: BorderRadius.circular(65),
            hoverColor: const Color.fromARGB(255, 233, 230, 230),
            child: CircleAvatar(
              radius: 14.0,
              backgroundImage: CachedNetworkImageProvider(urlImage),
              backgroundColor: Colors.transparent,
            ),
          ),
          Container(
            width: 10,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: activeColor),
            )
          : PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              onPageChanged: onPageChanged,
              children: items.getItems(),
            ),
    );
  }
}
