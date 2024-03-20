import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

Future<Uint8List?> processImage(
    img.Image baseImage, img.Image coloredImage, Color color) async {
  int width = baseImage.width;
  int height = baseImage.height;

  // Ensure that the colored overlay image has the same dimensions as the base image
  coloredImage = img.copyResize(coloredImage, width: width, height: height);

  // Overlay colored image onto base image
  for (int y = 0; y < coloredImage.height; y++) {
    for (int x = 0; x < coloredImage.width; x++) {
      if (coloredImage.getPixel(x, y) & 0xff000000 != 0x00000000) {
        Color abgrColor = Color(0xFF000000 |
            ((color.value & 0x000000FF) << 16) |
            ((color.value & 0x00FF0000) >> 16) |
            (color.value & 0xFF00FF00));
        baseImage.setPixel(
            x,
            y,
            coloredImage.getPixel(x, y) &
                abgrColor.value &
                baseImage.getPixel(x, y));
      }
    }
  }

  // Return modified image
  return Uint8List.fromList(img.encodePng(baseImage));
}
