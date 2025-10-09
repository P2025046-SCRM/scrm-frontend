import 'dart:io';

import 'package:flutter/material.dart';

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({
    super.key,
    required this.imagePath,
    this.isAsset = false, // set default to false for gallery/taken images
  });
  final String imagePath;
  final bool isAsset;

  @override
  Widget build(BuildContext context) {

    ImageProvider imageProvider;

    if(isAsset) {
      imageProvider = AssetImage(imagePath);
    } else {
      imageProvider = FileImage(File(imagePath));
    }

    return Container(
      height: 75,
      width: 75,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}