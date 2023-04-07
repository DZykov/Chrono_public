import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source, imageQuality: 25);
  if (file != null) {
    return await file.readAsBytes();
  }
  //print('No Image Selected');
}

// for displaying snackbars
showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(text),
      dismissDirection: DismissDirection.none,
      margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.90),
      duration: const Duration(seconds: 2),
    ),
  );
}
