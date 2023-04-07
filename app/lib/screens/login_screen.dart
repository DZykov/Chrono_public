import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/responsive/mobile_screen_layout.dart';
import 'package:chrono_alpha/responsive/responsive_layout_screen.dart';
import 'package:chrono_alpha/responsive/web_screen_layout.dart';
import 'package:chrono_alpha/screens/signup_screen.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/logo.dart';
import 'package:chrono_alpha/widgets/text_field_input.dart';
import 'package:chrono_alpha/widgets/text_field_password.dart';
import 'package:flutter/material.dart';

//import 'package:chrono_alpha/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthService auth = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, "One of the fields is empty!");
    } else {
      String res = await auth.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ResponsiveLayout(
                webScreenLayout: WebScreenLayout(),
                mobileScreenLayout: MobileScreenLayout(),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) showSnackBar(context, res);
      }
    }
  }

  void navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32), // change?
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(flex: 2, child: Container()), // change
              // icon CHANGE
              const Logo(),
              // SvgPicture.asset('web_logo.svg', height: 64, color: Colors.black,),
              // spacer
              const SizedBox(
                height: 15,
              ),
              // text field input email
              TextFieldInput(
                textEditingController: _emailController,
                hintText: "Enter your username",
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 15,
              ),
              // text field input password
              PasswordField(
                textEditingController: _passwordController,
              ),
              const SizedBox(
                height: 15,
              ),
              // button login
              InkWell(
                onTap: loginUser,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: activeColor,
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text("Log in"),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Flexible(flex: 2, child: Container()),
              // transition to signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text("Don't have an account?"),
                  ),
                  GestureDetector(
                    onTap: navigateToSignup,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        "Sign up!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
