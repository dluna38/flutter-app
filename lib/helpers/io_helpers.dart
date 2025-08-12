import 'dart:io';

import 'package:flutter/material.dart';

class IOHelpers {
  static CircleAvatar getAvatar(path) {
    return path != null
        ? CircleAvatar(backgroundImage: FileImage(File(path!)), radius: 30)
        : CircleAvatar(
          backgroundImage: AssetImage('resources/placeholder-img.jpg'),
          radius: 30,
        );
  }
}
