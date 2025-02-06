import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_converter/flutter_image_converter.dart';

Future<Uint8List> removeWhiteBackground(Uint8List bytes) async {
  img.Image image = img.decodeImage(bytes)!;
  var pixels = image.getBytes();
  if (image.width > image.height) {
    return pixels;
  }
  if (pixels[3] == 0) {
    return pixels;
  }
  int red = pixels[0], green = pixels[1], blue = pixels[2];
  if (red != 255 && green != 255 && blue != 255) {
    return pixels;
  }
  for (int i = 0, len = pixels.length; i < len; i += 4) {
    if (pixels[i] == red && pixels[i + 1] == green && pixels[i + 2] == blue) {
      pixels[i + 3] = 0;
    }
  }
  return pixels;
}

Future<Uint8List> generateDemoBMP() async {
  const canvasWidth = 576;
  const canvasHeight = 136;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Draw background (black)
  final backgroundPaint = ui.Paint()
    ..color = const ui.Color.fromARGB(255, 255, 255, 255);
  canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
      backgroundPaint);

  // Draw text in white
  final textStyle =
      ui.TextStyle(color: ui.Color.fromARGB(255, 0, 0, 0), fontSize: 24);
  final paragraphStyle = ui.ParagraphStyle(textAlign: ui.TextAlign.center);
  final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
    ..pushStyle(textStyle)
    ..addText("Hello World!");

  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: canvasWidth.toDouble()));
  canvas.drawParagraph(paragraph, ui.Offset(0, canvasHeight / 2));

  // Convert to an image
  final picture = recorder.endRecording();
  final image = await picture.toImage(canvasWidth, canvasHeight);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final rgbaData = byteData!.buffer.asUint8List();

  // Convert RGBA to 1-bit monochrome (0=black, 1=white)
  final bmpData = _convertRgbaTo1Bit(rgbaData, canvasWidth, canvasHeight);

  // Build the BMP headers and combine
  final bmpBytes = _build1BitBmp(canvasWidth, canvasHeight, bmpData);

  // Save BMP temporarily to disk for debugging
  //_saveBitmapToDisk(bmpBytes, 'demo.bmp');

  return bmpBytes;
}

Future<Uint8List> generateNavigationBMP(
    String maneuver, double distance) async {
  const canvasWidth = 576;
  const canvasHeight = 136;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Draw background (black)
  final backgroundPaint = ui.Paint()..color = const ui.Color(0xFF000000);
  canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
      backgroundPaint);

  // Draw icon
  final iconData = await _loadManeuverIcon(maneuver);
  if (iconData != null) {
    final ui.Image image = await decodeImage(iconData);
    final iconSize = 80.0;
    final iconRect = ui.Rect.fromCenter(
      center: ui.Offset(canvasWidth / 2, canvasHeight / 3),
      width: iconSize,
      height: iconSize,
    );
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      iconRect,
      ui.Paint(),
    );
  }

  // Draw distance text in white
  final textStyle = ui.TextStyle(color: ui.Color(0xFFFFFFFF), fontSize: 24);
  final paragraphStyle = ui.ParagraphStyle(textAlign: ui.TextAlign.center);
  final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
    ..pushStyle(textStyle)
    ..addText("${distance.toStringAsFixed(1)} m");
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: canvasWidth.toDouble()));
  canvas.drawParagraph(paragraph, ui.Offset(0, canvasHeight * 0.7));

  // Convert to an image
  final picture = recorder.endRecording();
  final image = await picture.toImage(canvasWidth, canvasHeight);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final rgbaData = byteData!.buffer.asUint8List();

  // Convert RGBA to 1-bit monochrome (0=black, 1=white)
  final bmpData = _convertRgbaTo1Bit(rgbaData, canvasWidth, canvasHeight);

  // Build the BMP headers and combine
  final bmpBytes = _build1BitBmp(canvasWidth, canvasHeight, bmpData);

  // Save BMP temporarily to disk for debugging
  await _saveBitmapToDisk(bmpBytes, 'navigation.bmp');

  return bmpBytes;
}

// Load and decode image
Future<ui.Image> decodeImage(Uint8List imageData) async {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(imageData, completer.complete);
  return completer.future;
}

Future<Uint8List?> _loadManeuverIcon(String maneuver) async {
  final iconPath = 'assets/icons/$maneuver.png';
  try {
    final data = await rootBundle.load(iconPath);
    return data.buffer.asUint8List();
  } catch (e) {
    print("Error loading icon: $e");
    return null;
  }
}

/// Save bitmap to disk for debugging purposes
Future<void> _saveBitmapToDisk(Uint8List bmpData, String fileName) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bmpData);
    print('Bitmap saved temporarily at $filePath');
  } catch (e) {
    print('Error saving bitmap to disk: $e');
  }
}

Future<Uint8List> generateBMPForDisplay(Uint8List pngImage, int canvasWidth, int canvasHeight) async {
  // var rgbaData = await removeWhiteBackground(bmpData);
  final bmp32Image = await pngImage.bmpUint8List;
  // Bitmap bitmap32Data = Bitmap.fromHeadless(canvasWidth, canvasHeight, bmp32Image); // Not async
  final bmp1BitData = _convertRgbaTo1Bit(bmp32Image, canvasWidth, canvasHeight);
  final bmpBytes = _build1BitBmp(canvasWidth, canvasHeight, bmp1BitData);
  return bmpBytes;
}

/// Convert RGBA to 1-bit (threshold at ~50% brightness)
Uint8List _convertRgbaTo1Bit(Uint8List bmpData, int width, int height) {
  // Remove the first 40 bytes (BMP header) from bmpData and save it as rgba
  // Should be 320 bits (40 bytes), but when I remove 320 bits I get an error processing the remaining Uint8List.
  Uint8List rgba = bmpData.sublist(139); // Was 139, 11 or 12 pixels get trimmed from the top rows with this value...
  // Uint8List rgba = bmpData.sublist(139); // Was 139, 11 or 12 pixels get trimmed from the top rows with this value...
  final bytesPerRow = width ~/ 8;
  final output = Uint8List(bytesPerRow * height);

  for (int y = height - 1; y >= 0; y--) {
    for (int x = 0; x < width; x++) {
      final index = (y * width + x) * 4;
      final r = rgba[index];
      final g = rgba[index + 1];
      final b = rgba[index + 2];

      final brightness = (r + g + b) / 3;
      final bit = brightness > 128 ? 1 : 0;
      // final bit = brightness > (128/2) ? 1 : 0;

      // final invertedY = (height - 1 - y);
      final outRowStart = y * bytesPerRow;
      final byteIndex = outRowStart + (x ~/ 8);
      final bitOffset = 7 - (x % 8);
      output[byteIndex] |= (bit << bitOffset);
    }
  }
  return output;
}


/// Build a 1-bit BMP file with a monochrome palette
Uint8List _build1BitBmp(int width, int height, Uint8List bmpData) {
  // final headerSize = 62;
  final headerSize = 62;
  final bytesPerRow = width ~/ 8;
  final imageSize = bytesPerRow * height;
  final fileSize = headerSize + imageSize;

  final file = BytesBuilder();
  /* See https://www.ece.ualberta.ca/~elliott/ee552/studentAppNotes/2003_w/misc/bmp_file_format/bmp_file_format.htm
  For format specification */

  file.addByte(0x42); // 'B'
  file.addByte(0x4D); // 'M'
  file.add(_int32le(fileSize)); // FileSize
  file.add(_int16le(0)); // reserved
  file.add(_int16le(0)); // reserved
  file.add(_int32le(headerSize)); // offset to pixels

  file.add(_int32le(40)); // biSize
  file.add(_int32le(width)); // biWidth
  file.add(_int32le(height)); // biHeight
  file.add(_int16le(1)); // biPlanes
  file.add(_int16le(1)); // biBitCount Bits Per Pixel
  file.add(_int32le(0)); // biCompression
  file.add(_int32le(0)); // biSizeImage ImageSize It is valid to set this =0 if Compression = 0
  // file.add(_int32le(imageSize)); // biSizeImage ImageSize
  file.add(_int32le(0)); //x pixels per meter
  file.add(_int32le(0)); //y pixels per meter
  file.add(_int32le(2)); //colors used
  file.add(_int32le(2)); //important colors

  file.add([0x00, 0x00, 0x00, 0x00]); // Black palette entry
  file.add([0xFF, 0xFF, 0xFF, 0x00]); // White palette entry

  file.add(bmpData);

  return file.toBytes();
}

Uint8List _int32le(int value) {
  final b = Uint8List(4);
  final bd = b.buffer.asByteData();
  bd.setInt32(0, value, Endian.little);
  return b;
}

Uint8List _int16le(int value) {
  final b = Uint8List(2);
  final bd = b.buffer.asByteData();
  bd.setInt16(0, value, Endian.little);
  return b;
}
