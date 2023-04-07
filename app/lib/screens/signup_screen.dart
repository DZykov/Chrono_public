import 'dart:typed_data';
import 'package:chrono_alpha/constants/other_constants.dart';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/upload_methods.dart';
import 'package:chrono_alpha/responsive/mobile_screen_layout.dart';
import 'package:chrono_alpha/responsive/responsive_layout_screen.dart';
import 'package:chrono_alpha/responsive/web_screen_layout.dart';
import 'package:chrono_alpha/screens/login_screen.dart';
import 'package:chrono_alpha/widgets/logo.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:chrono_alpha/widgets/text_field_input.dart';
import 'package:chrono_alpha/widgets/text_field_password.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextfieldTagsController _tagsController = TextfieldTagsController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;

  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    _tagsController.dispose();
  }

  @override
  void initState() {
    super.initState();
    //crutch();
  }

  crutch() async {
    http.Response response = await http.get(Uri.parse(EmptyConstants.noAvatar));
    setState(() {
      _image = response.bodyBytes;
    });
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });
    AuthService auth = AuthService();
    UploadMethods upload = UploadMethods();
    if (!(_image != null)) {
      showSnackBar(context, "Please, choose a profile image!");
      setState(() {
        _isLoading = false;
      });
    } else if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, "One of the fields is empty!");
    } else {
      // signup user using our authmethod
      String res = await auth.signUpUser(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text);
      // if string returned is sucess, user has been created
      if (res == "success") {
        User userN = await auth.getMineDetails();
        //print(user_n.id.toString());
        //print(_bioController.text);
        if (_bioController.text.isNotEmpty) {
          await auth.updateUserDescription(description: _bioController.text);
        }
        //print(_tagsController.getTags);
        if (_tagsController.hasTags) {
          await auth.updateUserTags(tags: _tagsController.getTags!);
        }
        if (_image != null) {
          await upload.uploadAvatar(_image!, userN.id);
        }
        setState(() {
          _isLoading = false;
        });
        // navigate to the home screen
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ResponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        // show the error
        if (context.mounted) showSnackBar(context, res);
      }
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32), // change?
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Flexible(flex: 2, child: Container()), // change
                  // icon
                  const Logo(),
                  //SvgPicture.asset('assets/icons/web_logo.svg', height: 64,),
                  // spacer
                  const SizedBox(
                    height: 15,
                  ),
                  // circular widget to accept and show selected file
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage:
                                  NetworkImage(EmptyConstants.noAvatar),
                              backgroundColor: Colors.grey,
                            ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // text field input username
                  TextFieldInput(
                    textEditingController: _usernameController,
                    hintText: "Enter your username",
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // text field input email
                  TextFieldInput(
                    textEditingController: _emailController,
                    hintText: "Enter your email",
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
                  TextField(
                    cursorColor: activeColor,
                    maxLength: 700,
                    maxLines: 5,
                    controller: _bioController,
                    decoration: const InputDecoration(
                      hintText: "Enter your biography",
                      filled: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // tags field
                  TextFieldTags(
                    textfieldTagsController: _tagsController,
                    initialTags: const ['updates', 'news'],
                    textSeparators: const [' ', ','],
                    letterCase: LetterCase.small,
                    validator: (String tag) {
                      if (tag == 'gachi') {
                        return 'Not allowed, sorry';
                      } else if (_tagsController.getTags!.contains(tag)) {
                        return 'Tag is already in the list';
                      }
                      return null;
                    },
                    inputfieldBuilder:
                        (context, tec, fn, error, onChanged, onSubmitted) {
                      return ((context, sc, tags, onTagDelete) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: tec,
                            focusNode: fn,
                            decoration: InputDecoration(
                              isDense: true,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 74, 137, 92),
                                  width: 3.0,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 74, 137, 92),
                                  width: 3.0,
                                ),
                              ),
                              helperText: 'Enter topic/theme/tag...',
                              helperStyle: const TextStyle(
                                color: Color.fromARGB(255, 74, 137, 92),
                              ),
                              hintText:
                                  _tagsController.hasTags ? '' : "Enter tag...",
                              errorText: error,
                              prefixIconConstraints: const BoxConstraints(
                                  maxWidth: double.infinity),
                              prefixIcon: tags.isNotEmpty
                                  ? SingleChildScrollView(
                                      controller: sc,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                          children: tags.map((String tag) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                            color: Color.fromARGB(
                                                255, 74, 137, 92),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: Text(
                                                  '#$tag',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onTap: () {
                                                  //print("$tag selected");
                                                },
                                              ),
                                              const SizedBox(width: 4.0),
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 14.0,
                                                  color: Color.fromARGB(
                                                      255, 233, 233, 233),
                                                ),
                                                onTap: () {
                                                  onTagDelete(tag);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                    )
                                  : null,
                            ),
                            onChanged: onChanged,
                            onSubmitted: onSubmitted,
                          ),
                        );
                      });
                    },
                  ),
                  // button login
                  InkWell(
                    onTap: signUpUser,
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
                                  color: primaryColor),
                            )
                          : const Text("Sign up"),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //Flexible(flex: 2, child: Container()),
                  // transition to signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child:
                            const Text("Do you want to go back to Login page?"),
                      ),
                      GestureDetector(
                        onTap: navigateToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            "Login",
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
            )),
      ),
    );
  }
}
