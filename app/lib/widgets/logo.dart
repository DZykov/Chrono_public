import 'package:chrono_alpha/utils/colors.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
      Text(
        "CHRON",
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 55),
      ),
      Text(
        "O",
        style: TextStyle(
            fontWeight: FontWeight.bold, color: activeColor, fontSize: 55),
      ),
      //Container(width: 174,), // count width in app bar
    ]);
  }
}
