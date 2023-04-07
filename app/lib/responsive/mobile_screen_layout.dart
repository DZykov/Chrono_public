import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrono_alpha/constants/other_constants.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/utils/global_variables.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:chrono_alpha/utils/colors.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: items.getItems(),
            ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: (_page == 0) ? activeColor : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: (_page == 1) ? activeColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle,
                color: (_page == 2) ? activeColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.info,
              color: (_page == 3) ? activeColor : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14.0,
              backgroundImage: CachedNetworkImageProvider(urlImage),
              backgroundColor: Colors.transparent,
            ),
            label: '',
            backgroundColor: Colors.transparent,
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
