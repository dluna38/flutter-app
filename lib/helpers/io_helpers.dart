import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class IOHelpers {

  static final String defaultPlaceholder= 'resources/placeholder-img.jpg';
  static final String _imagesFolderName='appImages';
  static final String _plantsImagesFolderName='plantsImages';

  static CircleAvatar getAvatar(path) {
    return path != null
        ? CircleAvatar(backgroundImage: FileImage(File(path!)), radius: 30)
        : CircleAvatar(
          backgroundImage: getImagePlaceHolder(),
          radius: 30,
        );
  }

  static AssetImage getImagePlaceHolder({String path = 'resources/placeholder-img.jpg'}){
    return AssetImage(path);
  }

  static String getImagePlaceHolderString({String path = 'resources/placeholder-img.jpg'}){
    return path;
  }

  static Future<File> saveImageToLocalStorage(String tempPath,{String imageName="image"}) async{

    final File imageFile = File(tempPath);
    final String fileName = imageName == "image" ? "image_${DateTime.now().millisecondsSinceEpoch}":"${imageName}_${DateTime.now().millisecondsSinceEpoch}"; //

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String newPath = "${appDir.path}/$_imagesFolderName/$_plantsImagesFolderName";
    await assureOrCreatePath(newPath);
    final File localImage = await imageFile.copy('$newPath/$fileName');

    return localImage;
  }


  static Future<void> assureOrCreatePath(path) async{
    Directory directory = Directory(path);
    if(! await Directory(path).exists()){
      await directory.create(recursive: true);
    }
  }

}
