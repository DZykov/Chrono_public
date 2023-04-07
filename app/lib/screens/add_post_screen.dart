import 'dart:async';
import 'dart:typed_data';
import 'package:chrono_alpha/models/user.dart';
import 'package:chrono_alpha/resources/auth_methods.dart';
import 'package:chrono_alpha/resources/posts_methods.dart';
import 'package:chrono_alpha/resources/upload_methods.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chrono_alpha/utils/colors.dart';
import 'package:chrono_alpha/utils/utils.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// ignore: implementation_imports
import 'package:quill_html_editor/src/widgets/input_url_widget.dart'; // needed for url widget
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:textfield_tags/textfield_tags.dart';
// ignore: unused_import
import 'package:universal_io/io.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final QuillEditorController controller = QuillEditorController();
  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    ToolBarStyle.strike,
    ToolBarStyle.size,
    ToolBarStyle.align,
    ToolBarStyle.background,
    ToolBarStyle.color,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.indentAdd,
    ToolBarStyle.indentMinus,
    ToolBarStyle.headerOne,
    ToolBarStyle.headerTwo,
    ToolBarStyle.blockQuote,
    ToolBarStyle.codeBlock,
    ToolBarStyle.link,
    ToolBarStyle.image,
  ];

  final List<String> draftMenu = <String>[
    "Draft",
    "Public",
  ];

  final ButtonStyle flatButtonStyleApprove = TextButton.styleFrom(
    backgroundColor: Colors.green,
    textStyle: const TextStyle(color: Colors.white10),
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  final ButtonStyle flatButtonStyleCancel = TextButton.styleFrom(
    backgroundColor: Colors.red,
    textStyle: const TextStyle(color: Colors.white),
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  AuthService auth = AuthService();
  String body = "";
  String description = "";
  bool draft = false;
  bool isLoading = false;
  String name = "";
  PostsService posts = PostsService();
  String selectedOrder = "Public";
  List<String> tags = [];
  UploadMethods upload = UploadMethods();
  String url = "";

  User? userProvider;

  final _backgroundColor = Colors.white70;
  final TextEditingController _descriptionController = TextEditingController();
  final _editorTextStyle = const TextStyle(
      fontSize: 18, color: Colors.black54, fontWeight: FontWeight.normal);

  final _hintTextStyle = const TextStyle(
      fontSize: 18, color: secondaryColor, fontWeight: FontWeight.normal);

  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextfieldTagsController _tagsController = TextfieldTagsController();
  final _toolbarColor = const Color.fromARGB(255, 207, 205, 205);
  final _toolbarIconColor = Colors.black87;

  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    //controller.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void postData() async {
    body = await controller.getText();
    setState(() {
      isLoading = true;
    });
    if (_image == null) {
      if (context.mounted) {
        showSnackBar(context, 'Please, choose image header!');
      }
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (name == '' ||
        description == '' ||
        body == '' ||
        tags == [] ||
        url == '') {
      if (context.mounted) {
        showSnackBar(context, 'Fill all the fields, please!');
      }
      setState(() {
        isLoading = false;
      });
      return;
    }
    // start the loading
    try {
      // upload to storage and db
      String res =
          await posts.uploadPost(name, description, body, tags, url, draft);
      int postId = int.tryParse(res) ?? -100;
      if (postId == -100) {
        if (context.mounted) showSnackBar(context, res);
        setState(() {
          isLoading = false;
        });
        return;
      }
      //debugPrint(res);
      if (postId >= 0) {
        res = await upload.uploadImagePost(_image!, int.parse(res));
        if (res == '') {
          await posts.deletePost(postId);
          if (context.mounted) showSnackBar(context, 'Error!');
        } else {
          if (context.mounted) showSnackBar(context, 'Posted!');
          _descriptionController.clear();
          _linkController.clear();
          _tagsController.clearTags();
          _nameController.clear();
          controller.clear();
          clearImage();
        }
      } else {
        if (context.mounted) showSnackBar(context, res);
      }
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      if (context.mounted) showSnackBar(context, err.toString());
    }
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  Widget textButton({required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.black;
              }
              return Colors.black;
            }),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          )),
    );
  }

  _setOrder(String e) async {
    if (e == 'Draft') {
      draft = true;
      selectedOrder = e;
      return;
    }
    selectedOrder = e;
    draft = false;
  }

  void _popupDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shrinkWrap: true,
                children: draftMenu
                    .map(
                      (e) => InkWell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Text(
                              e,
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedOrder == e
                                    ? activeColor
                                    : Colors.black,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            _setOrder(e);
                          }),
                    )
                    .toList()),
          );
        });
  }

  Future<void> _displayTextInputDialog(BuildContext context) {
    controller.enableEditor(false);
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PointerInterceptor(
              child: AlertDialog(
            title: const Text('Post info'),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        controller: _nameController,
                        decoration: const InputDecoration(hintText: "Name"),
                      ),
                      TextField(
                        minLines: 10,
                        maxLines: 30,
                        maxLength: 1500,
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(hintText: "Description"),
                      ),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            url = value;
                          });
                        },
                        controller: _linkController,
                        decoration: const InputDecoration(hintText: "Link"),
                      ),
                      TextFieldTags(
                        textfieldTagsController: _tagsController,
                        initialTags: tags,
                        textSeparators: const [' ', ','],
                        letterCase: LetterCase.small,
                        validator: (String tag) {
                          // CHANGE
                          if (tag == 'pidr') {
                            return 'Not allowed, sorry';
                          } else if (_tagsController.getTags!.contains(tag)) {
                            return 'Tag is already in the list';
                          } else {
                            setState(() {
                              tags = _tagsController.getTags!;
                              tags.add(tag);
                            });
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
                                  hintText: _tagsController.hasTags
                                      ? ''
                                      : "Enter tags...",
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
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                      InkWell(
                          onTap: () {
                            _popupDialog(context);
                          },
                          borderRadius: BorderRadius.circular(65),
                          hoverColor: const Color.fromARGB(255, 233, 230, 230),
                          child: const Text(
                            "Save as..",
                            style: TextStyle(color: activeColor, fontSize: 20),
                          )),
                    ]),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: flatButtonStyleCancel,
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  controller.enableEditor(true);
                  controller.focus();
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: flatButtonStyleApprove,
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  controller.enableEditor(true);
                  controller.focus();
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ));
        }).then((val) {
      controller.enableEditor(true);
      controller.focus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 200,
        bottomOpacity: 0.0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: mobileBackgroundColor,
        actions: [
          GestureDetector(
            onTap: () async {
              Uint8List file = await pickImage(ImageSource.gallery);
              setState(() {
                _image = file;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 1280,
              decoration: BoxDecoration(color: Colors.red[200]),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _image != null
                    ? Image.memory(
                        _image!,
                        width: MediaQuery.of(context).size.width,
                        height: 900,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(color: Colors.red[200]),
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      // POST FORM
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ToolBar(
            toolBarColor: _toolbarColor,
            //toolBarConfig: customToolBarList,
            padding: const EdgeInsets.all(8),
            iconSize: 25,
            iconColor: _toolbarIconColor,
            activeIconColor: activeColor,
            controller: controller,
            toolBarConfig: customToolBarList,
            customButtons: [
              InputUrlWidget(
                iconWidget: SizedBox(
                  width: 25,
                  height: 25,
                  child: Icon(
                    Icons.image_search,
                    color: _toolbarIconColor,
                  ),
                ),
                isActive: true,
                controller: controller,
                type: UrlInputType.hyperlink,
                onSubmit: (v) {
                  controller.embedImage(v);
                },
              ),
            ],
          ),
          Expanded(
            child: QuillHtmlEditor(
              text: "",
              hintText: 'Your text goes here...',
              controller: controller,
              isEnabled: true,
              height: MediaQuery.of(context).size.height * 0.6,
              textStyle: _editorTextStyle,
              hintTextStyle: _hintTextStyle,
              hintTextAlign: TextAlign.start,
              padding: const EdgeInsets.only(left: 10, top: 1),
              hintTextPadding: EdgeInsets.zero,
              backgroundColor: _backgroundColor,
              onFocusChanged: (hasFocus) => {},
              onTextChanged: (text) => {},
              onEditorCreated: () =>
                  showSnackBar(context, "Editor has been loaded!"),
            ),
          ),
          Visibility(
            visible: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: _toolbarColor,
                child: Row(
                  children: [
                    textButton(
                        text: 'Undo',
                        onPressed: () {
                          controller.undo();
                        }),
                    textButton(
                        text: 'Redo',
                        onPressed: () {
                          controller.redo();
                        }),
                    textButton(
                        text: 'Info',
                        onPressed: () async {
                          controller.unFocus();
                          //controller.enableEditor(false);
                          _displayTextInputDialog(context);
                          //controller.enableEditor(true);
                        }),
                    textButton(
                        text: 'Post!',
                        onPressed: () {
                          postData();
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
