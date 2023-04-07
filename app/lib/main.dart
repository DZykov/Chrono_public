import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/responsive/mobile_screen_layout.dart';
import 'package:chrono_alpha/responsive/responsive_layout_screen.dart';
import 'package:chrono_alpha/responsive/web_screen_layout.dart';
import 'package:chrono_alpha/screens/login_screen.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chrono',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      themeMode: ThemeMode.light,
      home: const FutureChooseScreen(),
    );
  }
}

class FutureChooseScreen extends StatefulWidget {
  const FutureChooseScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FutureChooseScreen();
  }
}

class _FutureChooseScreen extends State<FutureChooseScreen> {
  late Future<String> _value;
  final AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();
    _value = auth.refreshToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<String>(
      future: _value,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error');
          } else if (snapshot.hasData) {
            if (snapshot.data == 'success') {
              return const ResponsiveLayout(
                webScreenLayout: WebScreenLayout(),
                mobileScreenLayout: MobileScreenLayout(),
              );
            } else {
              return const LoginScreen();
            }
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
        return Text('State: ${snapshot.connectionState}');
      },
    ));
  }
}
